#!/usr/bin/env bash
# Çizim bütçesi ölçümü (v0.99.108): her bölüm sanal ekranda test botuyla oynanır, takılma denetçisi iki saniyede bir
# çizim çağrısı ve üçgen sayısını (ana görüntü ve gölge geçişi ayrı) yazar (RINFO). tools/perf_report.py bunlardan
# docs/PERF.md tablosunu kurar: sahne başına ortanca ve en yüksek değer, bütçeyi (6.000 çizim, 5 M üçgen) aşanlar.
# Sayılar ekran kartından bağımsızdır (kaç nesne, kaç üçgen çizildiği); kare süresi yazılımla çizimde anlamsızdır.
# Kullanım: GODOT=... [PERF_TIMEOUT=sn] tests/perf_run.sh [paralel=2] [bölüm...]   (xvfb-run gerekir). PERF_TIMEOUT: bölüm başına
# süre sınırı (varsayılan 1500); yazılımla çizimde ağır sahneler çok yavaş, kısa sınırla sahnenin ilk bölümü ölçülür.
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
PAR="${1:-2}"; shift 2>/dev/null
CHAPTERS=("$@")
if [ ${#CHAPTERS[@]} -eq 0 ]; then
  CHAPTERS=(0 1 2 3 4 5 6 7 8 9 10 10a 10b 10g 10h 10l 10z 11 12 12b 13 14 15 16 17 17o 18 18b 19 19o 20 20o 21 21o 22 22o
            23 24 24o 25 26 26o 27 28o 29 29o 30 30o 31o 32o 33o 34o 35o 36b 37o 38o 39o 41o 42b 43o)
fi
OUT="${PERF_OUT:-tests/out/perf}"; mkdir -p "$OUT"     # PERF_OUT: başka klasöre (taban ölçümleri ezilmesin)
# Örnekli üçgen (RTRI): RINFO'nun üçgen sayacı çoklu ağda (MultiMesh) çizim başına ağı bir kez sayar, örnek sayısını
# saymaz (bir Crowd figürü ~20 bin üçgen; 200 örnekli ağ sayaçta 1 figür). Ölçüm koşusu oyunu küçük bir sarmalayıcı
# sahneyle açar; sarmalayıcı RINFO ile aynı aralıkta kameranın gördüğü çoklu ağların örnek × seçilen LOD üçgenini
# toplar ve "RTRI ... real=" yazar (real = RINFO üçgeni + sayılmayan örnekler). Sarmalayıcı koşu boyunca
# tests/_tmp altına yazılır, sonunda silinir.
WRAP=tests/_tmp/perf_tris
mkdir -p tests/_tmp
cat > "$WRAP.gd" <<'GD'
extends Node
## perf_run.sh'ın geçici sarmalayıcısı: oyunu olağan açılıştan başlatır, iki saniyede bir RTRI satırı yazar.
## Çoklu ağ başına: görünür örnek × (Godot'nun seçeceği LOD'un üçgeni) × geçiş (renk + dış çizgi); gölge düşürüyorsa
## bir gölge bölmesi daha (yaklaşık). LOD katmanları oyundaki ayarla (generate_lods 25, 60) yeniden üretilip ölçülür.
var _scene := ""
var _t := 0.0
var _next := 0.0
var _mmis: Array = []
var _lodtab := {}

func _ready() -> void:
	if name != "PerfTrisKeep":
		var keep: Node = (get_script() as Script).new()
		keep.name = "PerfTrisKeep"
		keep.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child.call_deferred(keep)
		get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")


func _process(delta: float) -> void:
	var sc := get_tree().current_scene
	if sc == null:
		return
	var nm := sc.scene_file_path.get_file().get_basename()
	if nm != _scene:
		_scene = nm
		_t = 0.0
		_next = 0.0
		_mmis.clear()
	_t += delta
	if _t < 0.5 or _t < _next:
		return
	_next = _t + 2.0
	if _mmis.is_empty() or int(_t) % 10 == 0:
		_mmis = sc.find_children("*", "MultiMeshInstance3D", true, false)
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var planes := cam.get_frustum()
	var cpos := cam.global_position
	var back := cam.global_basis.z
	var vs := get_viewport().get_visible_rect().size
	var vfov := deg_to_rad(cam.fov)
	var hfov := 2.0 * atan(tan(vfov * 0.5) * vs.x / maxf(vs.y, 1.0)) if cam.keep_aspect == Camera3D.KEEP_HEIGHT else vfov
	var mult := 2.0 * tan(hfov * 0.5)
	var thr := get_viewport().mesh_lod_threshold / maxf(vs.x, 1.0)
	var sh_dist := 0.0
	for l in sc.find_children("*", "DirectionalLight3D", true, false):
		if (l as DirectionalLight3D).shadow_enabled and (l as Node3D).is_visible_in_tree():
			sh_dist = maxf(sh_dist, (l as DirectionalLight3D).directional_shadow_max_distance)
	var ev := 0
	var es := 0
	for n in _mmis:
		if not is_instance_valid(n):
			continue
		var mi := n as MultiMeshInstance3D
		if not mi.is_visible_in_tree() or mi.multimesh == null or mi.multimesh.mesh == null:
			continue
		var mm := mi.multimesh
		var cnt := mm.instance_count if mm.visible_instance_count < 0 else mm.visible_instance_count
		if cnt <= 1:
			continue
		var box: AABB = mi.global_transform * mi.get_aabb()
		var dc := cpos.distance_to(box.get_center())
		if (mi.visibility_range_end > 0.0 and dc > mi.visibility_range_end) or dc < mi.visibility_range_begin:
			continue
		var inside := true
		for p: Plane in planes:
			if p.is_point_over(box.get_support(-p.normal)):
				inside = false
				break
		if not inside:
			continue
		var dist := 0.0
		if not box.has_point(cpos):
			dist = minf(cpos.distance_to(box.get_support(back)), cpos.distance_to(box.get_support(-back)))
		var tris := _lod_tris(mm.mesh, mi.global_transform.basis.get_scale().abs().x * mi.lod_bias, dist * mult, thr)
		var mat := mi.material_override
		var passes := 2 if (mat and mat.next_pass) else 1
		ev += (cnt - 1) * tris * passes
		if mi.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF and dc < sh_dist:
			es += (cnt - 1) * tris
	var prims := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	print("RTRI scene=%s t=%.0f real=%dk prims=%dk extra_vis=%dk extra_shadow=%dk" % [_scene, _t, (prims + ev + es) / 1000, prims / 1000, ev / 1000, es / 1000])


## Ağın seçilecek katmandaki üçgeni (Godot: kenar uzunluğu × ölçek / (uzaklık × çarpan) <= eşik olan en kaba katman)
func _lod_tris(m: Mesh, scale: float, dmult: float, thr: float) -> int:
	if not _lodtab.has(m):
		var tab: Array = []
		for s in m.get_surface_count():
			var a := m.surface_get_arrays(s)
			var ix = a[Mesh.ARRAY_INDEX]
			var base: int = (ix.size() if ix != null and ix.size() > 0 else (a[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
			var lv: Array = []
			if m is ArrayMesh and (RenderingServer.mesh_get_surface(m.get_rid(), s).get("lods", []) as Array).size() > 0:
				var im := ImporterMesh.new()
				im.add_surface(Mesh.PRIMITIVE_TRIANGLES, a)
				im.generate_lods(25.0, 60.0, [])
				for l in im.get_surface_lod_count(0):
					lv.append([im.get_surface_lod_size(0, l), im.get_surface_lod_indices(0, l).size() / 3])
			tab.append([base, lv])
		_lodtab[m] = tab
	var t := 0
	for sf: Array in _lodtab[m]:
		var cur: int = sf[0]
		for l: Array in sf[1]:
			if dmult <= 0.0 or float(l[0]) * scale / dmult > thr:
				break
			cur = l[1]
		t += cur
	return t
GD
printf '[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://%s.gd" id="1"]\n\n[node name="PerfTris" type="Node"]\nscript = ExtResource("1")\n' "$WRAP" > "$WRAP.tscn"
trap 'rm -f "$WRAP.gd" "$WRAP.gd.uid" "$WRAP.tscn"' EXIT
one() {
  local c=$1
  RINFO=1 timeout "${PERF_TIMEOUT:-1500}" xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path . --resolution 1280x720 --max-fps 60 \
    "res://$WRAP.tscn" -- --chapter="$c" --autotest --hitchaudit 2>&1 | grep -E "^RINFO|^RTRI|AUTOTEST PASS" > "$OUT/$c.txt"
  echo "bitti $c: $(grep -c '^RINFO' "$OUT/$c.txt") ölçüm"
}
export -f one; export GODOT OUT WRAP
printf '%s\n' "${CHAPTERS[@]}" | xargs -P "$PAR" -I{} bash -c 'one {}'
python3 tools/perf_report.py "$OUT" "${PERF_MD:-docs/PERF.md}"     # PERF_MD: tablo başka dosyaya
