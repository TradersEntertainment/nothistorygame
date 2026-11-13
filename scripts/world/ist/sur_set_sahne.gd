class_name SurSetSahne
extends LandWalls
## YENİ SUR SAHNESİ — LandWalls'ın yerine bölümün kurduğu set (bölüm bağdaştırıcısı SurSet ile; docs/SUR_SOZLESME.md).
##
## LandWalls'tan türer: bölümün kullandığı örnek işlevleri (fire_flash, impact, make_dawn/dawn_to, make_day, lights, env,
## moon, field, far_gun, gun_present, gun_screen, build_great_gun) aynen çalışır. Kurduğu:
##   · gece ortamı ve ay (LandWalls ile aynı)
##   · SurOyun.kur(kesim): oyun dilimi + yan dilimler + uzak katman + parçalar (poterna, kalas, dolgu, gedik onarımı)
##     bölüm çerçevesine (SurSet.cerceve: gedik x 0, peribolos y 0, dış surun iç yüzü z 14) konur
##   · ova: SiegeField (ordugâh, siper, bataryalar, büyük top) SurSet.ova_ofs kaydırmasıyla; sur uzantısı ve şehir KURULMAZ
##     (yeni kesimin kendi yan dilimleri ve şehir önü var)
##   · set dekoru: depo (yük yığınları + etkileşim), gedik teslim alanı, tekerlekli siperler, meşaleler
##   · onarım: oyunun 10'luk sayacı → GedikOnarim'ın 4 aşaması (SurSet.asama_of; karar 5-B)
## Sur görünüşüne (taş, renk, kule, hendek) dokunmaz.

const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")

var sur: SurSet
var kesim_id := "mesoteikhion"
## Kurulum seçenekleri (SurOyun.kur'a): dolgu 0..1, kalas, poterna_acik
var dolgu := 1.0
var kalas := true
var poterna_acik := false
var kesim: Dictionary = {}            # SurOyun.kur dönüşü
var gedik_onarim: Node3D              # GedikOnarim
var ova: Node3D                       # ova düğümü (SurSet.ova_ofs)
var ms := {}                          # kurulum ölçümü (karar 12)
var onarim := 0


func _enter_tree() -> void:
	if sur == null:
		sur = SurSet.yeni(kesim_id)
	SurSet.etkin = sur


func _exit_tree() -> void:
	super._exit_tree()
	if SurSet.etkin == sur:
		SurSet.etkin = null


func _ready() -> void:
	var t0 := Time.get_ticks_usec()
	Audio.voice_space("outdoor")
	moon = Night.environment(self, 0.006)
	moon.rotation_degrees = Vector3(-34, 160, 0)
	for c in get_children():
		if c is WorldEnvironment:
			env = c
	var cer := Node3D.new()
	cer.name = "SurCerceve"
	cer.transform = sur.cerceve()
	add_child(cer)
	kesim = SurOyun.kur(kesim_id, {"ebeveyn": cer, "dunya": false, "asama": 1, "dolgu": dolgu, "kalas": kalas,
		"poterna_acik": poterna_acik, "merdiven": []})
	ms = (kesim["ms"] as Dictionary).duplicate()
	gedik_onarim = kesim["parca"].get("gedik")
	# Kesimin düz ova levhası görünmez (çarpışması kalır): ova görüntüsü SiegeField'in arazisidir (aynı düzlemde iki yüzey
	# titreşirdi)
	var ovl := (kesim["kok"] as Node).find_child("Toprak_ZeminOva", true, false)
	if ovl and ovl.get_child_count() > 0 and ovl.get_child(0) is Node3D:
		(ovl.get_child(0) as Node3D).visible = false
	var t1 := Time.get_ticks_usec()
	_build_depot()
	_build_breach_set()
	_build_field()
	ms["set_ms"] = (Time.get_ticks_usec() - t1) / 1000.0
	ms["sahne_ms"] = (Time.get_ticks_usec() - t0) / 1000.0
	print("SURSET kesim=%s kurulum_ms=%.0f sur_ms=%.0f set_ms=%.0f" % [kesim_id, float(ms["sahne_ms"]), float(ms["toplam_ms"]), float(ms["set_ms"])])


## Depo: LandWalls._build_depot'un aynısı, yeni yerinde (SurSet.depo)
func _build_depot() -> void:
	var d := sur.depo()
	for i in 5:
		Props.cyl(self, 0.36, 0.95, d + Vector3(-2.6 + (i % 3) * 0.8, 0.48 + (i / 3) * 0.95, -0.6), C_WOOD.darkened((i % 2) * 0.1), Vector3.ZERO, 10)
	var pile := Props.ball(self, 1.3, d + Vector3(0.4, 0.2, 0.2), Color("5a4630"), Vector3(1.2, 0.6, 1.0), 8)
	pile.create_convex_collision()
	for c in pile.get_children():
		if c is StaticBody3D:
			c.set_meta("ground", true)
	for i in 4:
		Props.cyl(self, 0.28, 0.45, d + Vector3(1.8 + (i % 2) * 0.6, 0.23, 0.9 + (i / 2) * 0.6), Color("9a7a48"), Vector3.ZERO, 8, 0.32)
	for i in 6:
		Props.box(self, Vector3(3.2, 0.12, 0.3), d + Vector3(3.8, 0.1 + i * 0.13, -0.4 + (i % 2) * 0.05), Color("8a6440"))
	for b: Array in [[Vector3(2.0, 1.9, 0.76), Vector3(-1.8, 0.95, -0.6)], [Vector3(1.16, 0.45, 1.16), Vector3(2.1, 0.23, 1.2)],
			[Vector3(3.2, 0.82, 0.36), Vector3(3.8, 0.41, -0.38)]]:
		var body := Props.solid(self, b[0], d + b[1], Color.WHITE)
		body.get_child(0).visible = false
	Props.interactable(self, "pile_barrel", Vector3(2.4, 2.0, 1.6), d + Vector3(-1.8, 1.0, -0.4))
	Props.interactable(self, "pile_earth", Vector3(2.4, 1.6, 2.4), d + Vector3(0.9, 0.8, 0.5))
	Props.interactable(self, "pile_plank", Vector3(3.4, 1.2, 1.4), d + Vector3(3.8, 0.6, -0.3))


## Gedikte: teslim alanı, tekerlekli siperler (LandWalls._build_breach'teki modelin aynısı), gediğin iki yanında meşale.
## Gediğin kendisi (moloz, kırık kenar, 4 aşama) kesimin GedikOnarim parçasıdır.
func _build_breach_set() -> void:
	var b := sur.gedik()
	var on := sur.gedik_onu()
	Props.interactable(self, "breach", Vector3(sur.gedik_en(), 3.0, 3.0), Vector3(0, 1.5, on.z + 1.4))
	for m: Vector3 in sur.siperler():
		var mn := Node3D.new()
		mn.position = m
		mn.add_to_group("mantlet")
		add_child(mn)
		var sh := Props.solid(mn, Vector3(2.4, 2.2, 0.2), Vector3(0, 1.3, 1.0), C_WOOD.darkened(0.35))
		sh.set_meta("no_climb", true)
		for k in 8:
			Props.box(mn, Vector3(0.27, 2.3 + (k % 3) * 0.08, 0.08), Vector3(-1.05 + k * 0.3, 1.3 + (k % 3) * 0.04, 1.12), C_WOOD.darkened(0.1 + (k % 2) * 0.12))
		for y: float in [0.6, 2.0]:
			Props.box(mn, Vector3(2.5, 0.14, 0.1), Vector3(0, y, 1.2), Color("4a3422"))
		for sx: float in [-0.8, 0.8]:
			Props.box(mn, Vector3(0.1, 2.0, 0.1), Vector3(sx, 1.0, 0.45), Color("4a3422"), Vector3(-28, 0, 0))
			Props.cyl(mn, 0.32, 0.12, Vector3(sx * 1.25, 0.32, 1.0), Color("3a2a1c"), Vector3(0, 0, 90), 10)
	for sx: float in [-1.0, 1.0]:
		lights.append(Night.torch(self, Vector3(sx * 6.6, 0, on.z - 1.2), 2.4))
	# Dış surun iç yüzü boyunca peribolosu aydınlatan meşaleler (eski setin kule dibindekileri gibi; sur dibi eteğinin önünde)
	for x: float in [-26.0, 20.0]:
		lights.append(Night.torch(self, Vector3(x, 0, sur.peribolos().end.y - 0.2), 2.2))


## Ova: SiegeField, eski ova koordinatında kurulur, ova düğümüyle yeni ovaya iner. Sur uzantısı/şehir kurulmaz.
func _build_field() -> void:
	ova = Node3D.new()
	ova.name = "Ova"
	ova.position = sur.ova_ofs()
	add_child(ova)
	field = SiegeField.new()
	field.near_works = near_works and not assault_mode
	field.assault = assault_mode
	field.lite = lite
	field.gun_gate = gun_gate
	field.world = false
	field.sur_yeni = true
	field.keep = [Rect2(-8.0, 104.0, 34.0, 30.0)] + field_keep
	field.open = [Rect2(-36.0, 17.0, 72.0, 66.0)]
	ova.add_child(field)
	field.build()
	far_gun = _great_gun_model()
	_flash = OmniLight3D.new()
	_flash.position = CANNON + Vector3(0, 1.0, -6.0)
	_flash.light_color = Color("ffb060")
	_flash.light_energy = 0.0
	_flash.omni_range = 60.0
	add_child(_flash)
	# büyük top ve parlaması ova düğümünde (CANNON eski ova koordinatıdır)
	for n: Node3D in [far_gun, _flash]:
		remove_child(n)
		ova.add_child(n)


## LandWalls.fire_flash'in aynısı; namlu ağzı ova düğümünde (yeni ovada)
func fire_flash() -> void:
	if auto_cover and is_inside_tree() and get_tree().get_nodes_in_group("battle_extras").any(func(b): return b.get("side") == "byz"):
		preload("res://scripts/level/battle_extras.gd").cover_briefly(get_tree().current_scene, 3.5)
	_flash.light_energy = 16.0
	create_tween().tween_property(_flash, "light_energy", 0.0, 0.6)
	Fx.edge(Color("fff4dc"), 0.55, 0.4)
	Audio.duck(-10.0, 1.2)
	Vfx.gun_blast(self, sur.top() + Vector3(0, 1.5, -6.0), 1.6, sur.gedik() + Vector3(0, 14.0, 30.0), is_day)
	var screen := far_gun.get_node_or_null("Screen") as Node3D if far_gun else null
	if screen:
		if screen.rotation.x < deg_to_rad(60.0):
			screen.rotation.x = deg_to_rad(78.0)
		var tw := screen.create_tween()
		tw.tween_interval(2.5)
		tw.tween_property(screen, "rotation:x", 0.0, 1.6).set_trans(Tween.TRANS_SINE)


## Oyunun 10'luk onarım sayacı → 4 görsel aşama. Sıçrama, sayacın değiştiği anda (oyuncu yükü bıraktığında) olur.
func set_repair(n: int) -> void:
	onarim = n
	if gedik_onarim and gedik_onarim.has_method("asama"):
		var k := SurSet.asama_of(n)
		if int(gedik_onarim.get("asama_n")) != k:
			gedik_onarim.call("asama", k)


## Eski setin "sağlam" (28o) ve dolgu (26o) seçenekleri bu sahnede yok: bölüm taşınırken ayrıca bağlanır.
func open_inner_gate() -> void:
	push_warning("SurSetSahne: iç kapı Mesoteikhion kesiminde yok (karar 11: Romanos)")
