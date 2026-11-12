extends Node
## BAĞLAMA-4 kanıt sahnesi: Tolga'nın şehir bölümünü (ByzCity "walls" hub'ı) GERÇEK akışında açar (otomatik test değil) ve
## hub'ın YEREL çerçevesinde sabit altı bakıştan HUD'lu oyun içi kare alır. Bakışlar yerel olduğu için eski dünyada
## (`--eski-dunya`) ve v2'de aynı yerden aynı yöne bakılır: ÖNCE | SONRA.
##   godot --path . --resolution 1280x720 res://tests/_ist/hub_kare.tscn -- bolum=12b shots=KLASÖR [--eski-dunya]
##       [--ist2-deneme=12b]
## Satırlar: HUBKARE_YUKLE ms=… · HUBKARE ad=… cizim=… ucgen=… · HUBKARE_BITTI

var bolum := "12b"
var shots := ""
var ch: Node3D
var city: Node3D
var cam: Camera3D
var _n := 0

## [ad, göz (yerel), bakılan (yerel)] — hub yereli: iç sur x 34 (dış yüz +x), kapı z ≈ −31,5, cadde z 12 → −40
const BAKISLAR := [
	["cadde_sura", Vector3(-20.0, 1.7, -14.0), Vector3(34.0, 6.0, -14.0)],
	["sur_ici_kapiya", Vector3(22.0, 1.7, -12.0), Vector3(34.0, 7.0, -42.0)],
	["surdan_sehre", Vector3(31.0, 14.0, -6.0), Vector3(-160.0, 0.0, -6.0)],
	["tepeden_sura", Vector3(-70.0, 45.0, -13.0), Vector3(60.0, 0.0, -20.0)],
	["disaridan_sur", Vector3(120.0, 25.0, -13.0), Vector3(34.0, 6.0, -13.0)],
	["disaridan_sehre", Vector3(90.0, 55.0, 30.0), Vector3(-90.0, 0.0, -40.0)],
]


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"bolum": bolum = kv[1]
			"shots": shots = kv[1]
	if shots != "":
		DirAccess.make_dir_recursive_absolute(shots)
	GameState.autotest = false
	if bolum == "7":
		GameState.chapter_outcomes[6] = "6b.1"
	_surus.call_deferred()


func _surus() -> void:
	var sc := load("res://scenes/chapter%s.tscn" % bolum) as PackedScene
	var t0 := Time.get_ticks_msec()
	ch = sc.instantiate() as Node3D
	get_tree().root.add_child(ch)
	get_tree().current_scene = ch
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	print("HUBKARE_YUKLE bolum=%s v2=%s ms=%d" % [bolum, IstBaglama.aktif(), Time.get_ticks_msec() - t0])
	var t := 0.0
	while city == null and t < 30.0:
		city = _bul(ch)
		await get_tree().process_frame
		t += get_process_delta_time()
	if city == null:
		print("HUBKARE_HATA hub yok")
		get_tree().quit()
		return
	# bölümün açılış kartı ve kararması geçsin
	await _bekle(14.0)
	cam = Camera3D.new()
	cam.fov = 75.0
	cam.far = 4000.0
	city.add_child(cam)
	for b: Array in BAKISLAR:
		cam.position = b[1]
		cam.look_at(city.to_global(b[2]) , Vector3.UP)
		cam.make_current()
		var pl := get_tree().get_first_node_in_group("player") as Node3D
		if pl != null:
			# akış (v2 yakın katmanı, yaşam) izleyiciye göre: oyuncu kameranın altına
			pl.global_position = city.to_global(Vector3(b[1].x, maxf(b[1].y - 1.7, 0.0), b[1].z))
		await _bekle(4.0)
		await _akis_bekle(8.0)
		cam.make_current()
		await _cek(String(b[0]))
	print("HUBKARE_BITTI")
	get_tree().quit()


func _bul(n: Node) -> Node3D:
	if n is ByzCity:
		return n
	for c in n.get_children():
		var r := _bul(c)
		if r != null:
			return r
	return null


func _bekle(sn: float) -> void:
	var t := 0.0
	while t < sn:
		await get_tree().process_frame
		t += get_process_delta_time()
		if cam != null:
			cam.make_current()


func _akis_bekle(en_cok: float) -> void:
	var t := 0.0
	while t < en_cok:
		await get_tree().process_frame
		t += get_process_delta_time()
		var s := IstSehir.active
		if not IstBaglama.aktif() or s == null:
			break
		var q = s.get("_queue")
		if q is Array and (q as Array).is_empty():
			break


func _cek(ad: String) -> void:
	await RenderingServer.frame_post_draw
	_n += 1
	var dosya := "%02d_%s" % [_n, ad]
	print("HUBKARE ad=%s cizim=%d ucgen=%d v2=%s" % [dosya,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME), IstBaglama.aktif()])
	if shots != "":
		get_viewport().get_texture().get_image().save_png(shots.path_join(dosya + ".png"))
