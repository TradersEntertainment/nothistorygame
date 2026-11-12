extends RefCounted
## BİRLİK ölçümü: kategori kimlik geçişi. Ekrandaki her yüzey kategorisinin düz rengiyle (ışıksız, sissiz, ton
## eşlemesiz) bir kare daha çizilir; tests/_ist/birlik_olc.py asıl kareyi bu maskeyle kategori kategori ölçer.
## Sınıflandırıcı oyunla aynı (gorsel_dil.gd kategori()); yayındaki bölümlerde de aynı kural (desen, gölgelendirici, ad).

const GD := preload("res://scripts/world/ist/gorsel_dil.gd")
const RENK := {
	"tas": Color8(255, 0, 0), "siva": Color8(0, 255, 0), "kiremit": Color8(0, 0, 255), "ahsap": Color8(255, 255, 0),
	"zemin": Color8(255, 0, 255), "bitki": Color8(0, 255, 255), "kumas": Color8(255, 128, 0), "kisi": Color8(128, 0, 255),
	"metal": Color8(0, 128, 0), "yapi": Color8(128, 128, 128),
}
static var _m := {}


## Arayüzü (CanvasLayer: diyalog, HUD, harita) gizle/geri aç: ölçüm yalnız 3B sahne
static func ui(tree: SceneTree, acik: bool) -> void:
	for c in tree.root.find_children("*", "CanvasLayer", true, false):
		var cl := c as CanvasLayer
		if not acik:
			cl.set_meta("birlik_vis", cl.visible)
			cl.visible = false
		elif cl.has_meta("birlik_vis"):
			cl.visible = bool(cl.get_meta("birlik_vis"))


static func _mat(k: String) -> StandardMaterial3D:
	if _m.has(k):
		return _m[k]
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = RENK.get(k, Color.BLACK)
	m.disable_fog = true
	_m[k] = m
	return m


## Kategori kimlik karesini çek ve kaydet (png). Sahne olduğu gibi geri kurulur.
static func cek(tree: SceneTree, yol: String) -> void:
	var geri: Array = []
	for c in tree.root.find_children("*", "GeometryInstance3D", true, false):
		var gi := c as GeometryInstance3D
		if not gi.is_visible_in_tree():
			continue
		var m: Material = gi.material_override
		if m == null:
			if gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null and (gi as MeshInstance3D).mesh.get_surface_count() > 0:
				m = (gi as MeshInstance3D).get_active_material(0)
			elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh != null and (gi as MultiMeshInstance3D).multimesh.mesh != null:
				m = (gi as MultiMeshInstance3D).multimesh.mesh.surface_get_material(0)
		var k := ""
		if m != null:
			k = String(m.get_meta("birlik_kat")) if m.has_meta("birlik_kat") else GD.kategori(gi, m)
		var surf: Array = []
		if gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null and gi.material_override == null:
			# yüzey başına kategori (çok yüzeyli ağ: duvar + çatı ayrı)
			var mi := gi as MeshInstance3D
			for si in mi.mesh.get_surface_count():
				var sm := mi.get_active_material(si)
				var ks := k
				if sm != null:
					ks = String(sm.get_meta("birlik_kat")) if sm.has_meta("birlik_kat") else GD.kategori(gi, sm)
				surf.append([si, mi.get_surface_override_material(si)])
				mi.set_surface_override_material(si, _mat(ks))
			geri.append([gi, gi.material_override, surf, gi.cast_shadow])
		else:
			geri.append([gi, gi.material_override, surf, gi.cast_shadow])
			gi.material_override = _mat(k)
	var envs: Array = []
	for w in tree.root.find_children("*", "WorldEnvironment", true, false):
		var e := (w as WorldEnvironment).environment
		if e == null:
			continue
		envs.append([e, e.fog_enabled, e.adjustment_enabled, e.tonemap_mode, e.glow_enabled, e.background_mode, e.ssao_enabled, e.ssil_enabled, e.tonemap_exposure])
		e.fog_enabled = false
		e.adjustment_enabled = false
		e.tonemap_mode = Environment.TONE_MAPPER_LINEAR
		e.tonemap_exposure = 1.0
		e.glow_enabled = false
		e.background_mode = Environment.BG_CLEAR_COLOR
		e.ssao_enabled = false
		e.ssil_enabled = false
	var bg := RenderingServer.get_default_clear_color()
	RenderingServer.set_default_clear_color(Color.BLACK)
	await tree.process_frame
	await RenderingServer.frame_post_draw
	tree.root.get_viewport().get_texture().get_image().save_png(yol)
	RenderingServer.set_default_clear_color(bg)
	for e: Array in envs:
		var en: Environment = e[0]
		en.fog_enabled = e[1]
		en.adjustment_enabled = e[2]
		en.tonemap_mode = e[3]
		en.glow_enabled = e[4]
		en.background_mode = e[5]
		en.ssao_enabled = e[6]
		en.ssil_enabled = e[7]
		en.tonemap_exposure = e[8]
	for g: Array in geri:
		var gi = g[0]
		if not is_instance_valid(gi):
			continue
		(gi as GeometryInstance3D).material_override = g[1]
		for s: Array in g[2]:
			(gi as MeshInstance3D).set_surface_override_material(s[0], s[1])
	await tree.process_frame
