extends Node3D
## EŞYA FİZİĞİ deney sahnesi: düz zemin, eğim, merdiven, sur yolu; oyundaki kurucuların KENDİLERİ (Dressing.barrel/crate/
## crates/barrels, IstSurlarAyrinti._barrel) + küçük eşyalar (testi, gülle, kalas); gerçek Player tekmeler (kick eylemi),
## koşarak çarpar; Vfx.explosion; EsyaFizik.dusur (düşen yük).
##   başsız: timeout 600 godot --headless --path . res://tests/_ist/esya_fizik.tscn
##   kareli: xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --rendering-driver opengl3 --resolution 1280x720 \
##           res://tests/_ist/esya_fizik.tscn -- --kare=<klasör>
## Satırlar: ESYATEST <senaryo> … ; ESYATEST KARE <dosya> <cümle> ; ESYATEST PASS|FAIL … ; ESYAAUDIT OZET …

const SA = preload("res://scripts/world/ist/surlar_ayrinti.gd")

var pl: Player
var cam: Camera3D
var dir := ""
var hatalar: Array = []
var _kare_n := 0


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--kare="):
			dir = a.get_slice("=", 1)
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("8fb4d8")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("b8b0a0")
	e.ambient_light_energy = 0.55
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 35, 0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	add_child(sun)
	_dunya()
	_esyalar()
	_kos.call_deferred()


# ---------------------------------------------------------------- dünya

func _blok(s: Vector3, p: Vector3, col: Color, rot := Vector3.ZERO) -> StaticBody3D:
	var b := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = s
	cs.shape = bs
	b.add_child(cs)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = s
	mi.mesh = bm
	mi.material_override = Props.mat(col)
	b.add_child(mi)
	b.position = p
	b.rotation_degrees = rot
	add_child(b)
	return b


func _dunya() -> void:
	_blok(Vector3(220, 1, 220), Vector3(0, -0.5, 0), Color("8a7a5e"))
	# eğim: x=20'de 2,5 m'lik düzlük, +z yönüne 14° iniş
	_blok(Vector3(6, 2.5, 4), Vector3(20, 1.25, -6), Color("8f8070"))
	var a := deg_to_rad(14.0)
	var l := 2.5 / sin(a)
	_blok(Vector3(6, 0.3, l + 0.3), Vector3(20, 1.25 - 0.15 / cos(a), -4.0 + l * 0.5 * cos(a)), Color("9a8a70"), Vector3(14, 0, 0))
	# merdiven: x=-20'de 1,25 m'lik sahanlık, +z yönüne 5 basamak
	_blok(Vector3(4, 1.25, 3), Vector3(-20, 0.625, -3.5), Color("a09888"))
	for k in 5:
		var h := 1.25 - (k + 1) * 0.25
		if h > 0.0:
			_blok(Vector3(4, h, 0.45), Vector3(-20, h * 0.5, -2.0 + 0.225 + k * 0.45), Color("a8a090"))
	# sur yolu: x=40, 3 m yüksek, 2,4 m geniş, iki yanda 1,1 m korkuluk
	_blok(Vector3(2.4, 3, 24), Vector3(40, 1.5, 0), Color("b0a48c"))
	for sx: float in [-1, 1]:
		_blok(Vector3(0.5, 1.1, 24), Vector3(40 + sx * 1.45, 3.55, 0), Color("a0947c"))


var A: Vector3 = Vector3(0, 0, 0)          # tek fıçı (dik)
var B: Vector3 = Vector3(5, 0, 0)          # tek sandık
var C: Vector3 = Vector3(10, 0, 0)         # sandık yığını
var D: Vector3 = Vector3(0, 0, 12)         # fıçı kümesi (koşarak)
var E: Vector3 = Vector3(20, 2.5, -4.7)    # eğimin başında fıçı
var F: Vector3 = Vector3(-20, 1.25, -2.6)  # merdivenin başında fıçı
var G: Vector3 = Vector3(40, 3.0, -3.0)    # sur yolu fıçıları
var H: Vector3 = Vector3(-8, 0, -12)       # küçük eşyalar (patlama)


func _esyalar() -> void:
	var d := Dressing.new(7)
	d.at(A).barrel(Vector3.ZERO)
	d.at(B).crate(Vector3.ZERO, 0.62, 10.0)
	d.at(C).crates(Vector3.ZERO)
	d.at(D).barrels(Vector3.ZERO)
	d.at(E).barrel(Vector3.ZERO)
	d.at(F).barrel(Vector3.ZERO)
	d.build(self)
	# sur yolu: korkuluğa yaslı toprak dolu fıçılar (oyundaki _stauroma'nın fıçısı)
	for i in 3:
		SA._barrel(self, Vector3(G.x + 1.2 - 0.36, G.y, G.z + i * 0.8), 0.7, true)
	# küçük eşyalar: testi, gülle, kalas (kayıt kurucunun yaptığı gibi: görünen düğüm + durağan gövde)
	for i in 3:
		var t := Props.cyl(self, 0.14, 0.42, H + Vector3(i * 0.5, 0.21, 0), Color("b8683a"), Vector3.ZERO, 10, 0.08)
		EsyaFizik.kaydet_dugum(t, Props.make_solid(t), "testi")
	for i in 2:
		var g := Props.ball(self, 0.15, H + Vector3(0.2 + i * 0.4, 0.15, 0.8), Color("6a6660"))
		EsyaFizik.kaydet_dugum(g, Props.make_solid(g), "gulle")
	var k := Props.box(self, Vector3(0.24, 0.1, 2.4), H + Vector3(-0.8, 0.05, 0.5), Color("8a6440"))
	EsyaFizik.kaydet_dugum(k, Props.make_solid(k), "kalas")


# ---------------------------------------------------------------- koşu

func _kos() -> void:
	pl = Player.new()
	add_child(pl)
	pl.show_remote(false)
	pl.fall_guard = false
	cam = Camera3D.new()
	cam.fov = 65.0
	add_child(cam)
	cam.make_current()
	for i in 20:
		await get_tree().physics_frame
	var ef := EsyaFizik.ben()
	if ef == null:
		_hata("EsyaFizik kurulmadı")
		_bitir()
		return
	print("ESYATEST kayit=%d" % ef.items.size())
	if ef.items.size() < 15:
		_hata("kayıt az: %d" % ef.items.size())
	await _s_tekme_fici()
	await _s_tekme_sandik()
	await _s_yigin()
	await _s_kosu()
	await _s_egim()
	await _s_merdiven()
	await _s_sur_yolu()
	await _s_patlama()
	await _s_dusur()
	await _s_sinir()
	await _genel_denetim()
	_bitir()


func _bitir() -> void:
	var ef := EsyaFizik.ben()
	if ef:
		print("ESYATEST sayac %s en_cok_uyanik=%d" % [str(ef.sayac), ef.olcum["en_cok_uyanik"]])
	if hatalar.is_empty():
		print("ESYATEST PASS")
	else:
		print("ESYATEST FAIL %d: %s" % [hatalar.size(), "; ".join(hatalar)])
	get_tree().quit(0 if hatalar.is_empty() else 1)


func _hata(s: String) -> void:
	hatalar.append(s)
	print("ESYATEST HATA " + s)


func _esya_at(p: Vector3, r := 0.8) -> Dictionary:
	var ef := EsyaFizik.ben()
	var en: Dictionary = {}
	var ed := r
	for e in ef.items:
		var c: Vector3 = ef._merkez(e)
		var dd := Vector2(c.x - p.x, c.z - p.z).length()
		if dd < ed and absf(c.y - p.y) < 1.5:
			ed = dd
			en = e
	return en


func _tp(p: Vector3, bak: Vector3) -> void:
	pl.global_position = p
	pl.velocity = Vector3.ZERO
	var dd := bak - p
	pl.rotation = Vector3(0, atan2(-dd.x, -dd.z), 0)
	if pl.traversal:
		pl.traversal.cancel()
	for i in 8:
		await get_tree().physics_frame


func _tekme() -> void:
	Input.action_press("kick")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("kick")


func _bekle(sn: float) -> void:
	var t := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t < int(sn * 1000.0):
		await get_tree().physics_frame


## Eşya uyanana kadar bekle (en çok sn), sonra kare dizisi: 0,3 sn / 1 sn / durunca
func _dizi(ad: String, e: Dictionary, sn := 2.0) -> void:
	var t := 0.0
	while e["durum"] == "uyur" and t < sn:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
	await _bekle(0.3)
	await _kare(ad + "_2_03sn", e)
	await _bekle(0.7)
	await _kare(ad + "_3_1sn", e)
	t = 0.0
	while e["durum"] == "uyanik" and t < 12.0:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
	await _bekle(0.2)
	await _kare(ad + "_4_durunca", e)


func _kamera(hedef: Vector3, uzak := Vector3(3.2, 2.0, 3.2)) -> void:
	cam.look_at_from_position(hedef + uzak, hedef + Vector3(0, 0.3, 0), Vector3.UP)


func _kare(ad: String, e: Dictionary) -> void:
	var ef := EsyaFizik.ben()
	var cumle := _durum_cumle(e)
	if dir == "":
		print("ESYATEST DURUM %s %s" % [ad, cumle])
		return
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var f := dir.path_join("%s.jpg" % ad)
	img.save_jpg(f, 0.85)
	print("ESYATEST KARE %s %s" % [f.get_file(), cumle])


func _durum_cumle(e: Dictionary) -> String:
	if e.is_empty():
		return "eşya yok"
	var ef := EsyaFizik.ben()
	var g = e.get("govde")
	if g == null or not is_instance_valid(g):
		return "uyuyor (durağan dekor)"
	var rb := g as RigidBody3D
	var bos := ef._zemin_boslugu(rb)
	var dik := absf(rb.global_basis.y.normalized().y)
	var dur := "yuvarlanıyor/kayıyor v=%.1f m/s" % rb.linear_velocity.length() if e["durum"] == "uyanik" else "durdu ve dondu"
	var yon := "dik" if dik > 0.9 else ("yan yatık" if dik < 0.3 else "eğik")
	return "%s, %s, zemin boşluğu %.2f m%s" % [dur, yon, bos, " (HAVADA)" if bos > 0.06 and e["durum"] != "uyanik" else ""]


# ---------------------------------------------------------------- senaryolar

func _s_tekme_fici() -> void:
	var e := _esya_at(A)
	if e.is_empty():
		_hata("A fıçı kayıtta yok")
		return
	var c0: Vector3 = EsyaFizik.ben()._merkez(e)
	await _tp(A + Vector3(0, 0.05, 1.3), A)
	_kamera(A, Vector3(3.0, 1.6, -0.6))
	await _kare("a_fici_1_once", e)
	await _tekme()
	await _dizi("a_fici", e)
	var g := e["govde"] as RigidBody3D
	if g == null:
		_hata("A fıçı tekmede uyanmadı")
		return
	var yol := Vector2(g.global_position.x - c0.x, g.global_position.z - c0.z).length()
	var dik := absf(g.global_basis.y.normalized().y)
	print("ESYATEST tekme_fici yol=%.2f dik=%.2f durum=%s" % [yol, dik, e["durum"]])
	if yol < 0.2 and dik > 0.9:
		_hata("A fıçı tekmede kıpırdamadı")


func _s_tekme_sandik() -> void:
	var e := _esya_at(B)
	var c0: Vector3 = EsyaFizik.ben()._merkez(e)
	await _tp(B + Vector3(0, 0.05, 1.25), B)
	_kamera(B, Vector3(3.0, 1.6, -0.6))
	await _kare("b_sandik_1_once", e)
	await _tekme()
	await _dizi("b_sandik", e)
	var g := e["govde"] as RigidBody3D
	if g == null:
		_hata("B sandık tekmede uyanmadı")
		return
	var yol := Vector2(g.global_position.x - c0.x, g.global_position.z - c0.z).length()
	print("ESYATEST tekme_sandik yol=%.2f durum=%s" % [yol, e["durum"]])
	if yol < 0.15:
		_hata("B sandık tekmede kaymadı")


func _s_yigin() -> void:
	# yığın: üstteki sandık tekmelenir (alttakinin üstünde bir şey varken alttaki tekmelenmez)
	var ef := EsyaFizik.ben()
	var ust: Dictionary = {}
	for e in ef.items:
		var c: Vector3 = ef._merkez(e)
		if Vector2(c.x - C.x, c.z - C.z).length() < 1.4 and (ust.is_empty() or c.y > ef._merkez(ust).y):
			ust = e
	if ust.is_empty():
		_hata("C yığın yok")
		return
	var uc: Vector3 = ef._merkez(ust)
	print("ESYATEST yigin ust_y=%.2f" % uc.y)
	await _tp(Vector3(uc.x, 0.05, uc.z + 1.3), uc)
	_kamera(C, Vector3(3.2, 1.8, -0.8))
	await _kare("c_yigin_1_once", ust)
	await _tekme()
	await _dizi("c_yigin", ust)
	if ust["durum"] == "uyur":
		_hata("C yığının üstü tekmede uyanmadı")


func _s_kosu() -> void:
	var ef := EsyaFizik.ben()
	var once := int(ef.sayac["kosu"])
	var e := _esya_at(D + Vector3(-0.4, 0, 0.15))
	await _tp(D + Vector3(-0.4, 0.05, 7.0), D + Vector3(-0.4, 0, 0))
	_kamera(D, Vector3(3.6, 2.0, 2.6))
	await _kare("d_kosu_1_once", e)
	Input.action_press("move_forward")
	Input.action_press("sprint")
	var t := 0.0
	while int(ef.sayac["kosu"]) == once and t < 3.0:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
	Input.action_release("move_forward")
	Input.action_release("sprint")
	print("ESYATEST kosu hiz=%.1f kosu_sayac=%d" % [pl.horizontal_speed(), int(ef.sayac["kosu"]) - once])
	if int(ef.sayac["kosu"]) == once:
		_hata("D koşarak çarpma uyandırmadı")
	await _dizi("d_kosu", e)


func _s_egim() -> void:
	# 1) yandan tekme: fıçı yokuşa dik eksenle yan yatar; 2) yatan fıçı arkasından tekmelenir: yuvarlanır, yokuştan iner
	var ef := EsyaFizik.ben()
	var e := _esya_at(E)
	var c0: Vector3 = ef._merkez(e)
	await _tp(E + Vector3(1.3, 0.05, 0), E)
	_kamera(E + Vector3(0, -1.0, 3.0), Vector3(6.0, 2.5, 1.0))
	await _kare("e_egim_1_once", e)
	await _tekme()
	await _dizi("e_egim_a", e, 2.0)
	var g := e["govde"] as RigidBody3D
	if g == null:
		_hata("E eğim fıçısı uyanmadı")
		return
	var c1 := g.global_position
	print("ESYATEST egim_yan dik=%.2f eksen=%s" % [absf(g.global_basis.y.normalized().y), str(g.global_basis.y.normalized())])
	await _tp(Vector3(c1.x, E.y + 0.05, c1.z - 1.2), c1)
	await _tekme()
	await _dizi("e_egim_b", e, 2.0)
	print("ESYATEST egim dz=%.2f dy=%.2f" % [g.global_position.z - c0.z, g.global_position.y - c0.y])
	if g.global_position.z - c0.z < 2.0:
		_hata("E fıçı eğimden aşağı yuvarlanmadı (dz=%.2f)" % (g.global_position.z - c0.z))


func _s_merdiven() -> void:
	var e := _esya_at(F)
	var c0: Vector3 = EsyaFizik.ben()._merkez(e)
	await _tp(F + Vector3(0, 0.05, -1.3), F)
	_kamera(F + Vector3(0, -0.6, 1.5), Vector3(5.0, 2.2, 1.5))
	await _kare("f_merdiven_1_once", e)
	await _tekme()
	await _dizi("f_merdiven", e, 2.0)
	var g := e["govde"] as RigidBody3D
	if g == null:
		_hata("F merdiven fıçısı uyanmadı")
		return
	print("ESYATEST merdiven dy=%.2f dz=%.2f" % [g.global_position.y - c0.y, g.global_position.z - c0.z])
	if g.global_position.y - c0.y > -0.4:
		_hata("F fıçı merdivenden inmedi")


func _s_sur_yolu() -> void:
	# sur yolu: korkuluğa yaslı fıçı yol boyunca tekmelenir; durduğunda oyuncunun geçeceği yer kalmalı
	var e := _esya_at(Vector3(G.x + 0.84, G.y + 0.4, G.z + 1.6))
	var c0: Vector3 = EsyaFizik.ben()._merkez(e)
	await _tp(Vector3(G.x - 0.1, G.y + 0.05, G.z + 1.6 + 1.15), c0)
	e = EsyaFizik.ben()._tekme_hedefi(pl)
	c0 = EsyaFizik.ben()._merkez(e)
	print("ESYATEST suryolu esya=%s c0=%s pl=%s tekme_var=%s serbest=%s" % [str(not e.is_empty()), str(c0), str(pl.global_position), EsyaFizik.tekme_var(pl), EsyaFizik.ben()._tekme_serbest(pl)])
	_kamera(Vector3(G.x, G.y, G.z), Vector3(-2.6, 2.4, -3.0))
	await _kare("g_suryolu_1_once", e)
	await _tekme()
	await _dizi("g_suryolu", e, 2.0)
	var g := e["govde"] as RigidBody3D
	if g == null:
		_hata("G sur yolu fıçısı uyanmadı")
		return
	var r: float = EsyaFizik.ben()._yaricap(e)
	var x := g.global_position.x
	var sol := (x - r) - (G.x - 1.2)
	var sag := (G.x + 1.2) - (x + r)
	print("ESYATEST suryolu x=%.2f sol_bos=%.2f sag_bos=%.2f y=%.2f" % [x, sol, sag, g.global_position.y])
	if maxf(sol, sag) < 0.7:
		_hata("G sur yolu fıçısı yolu tıkıyor (boşluk %.2f)" % maxf(sol, sag))
	if g.global_position.y < G.y - 0.5:
		_hata("G sur yolu fıçısı surdan düştü")


func _s_patlama() -> void:
	var ef := EsyaFizik.ben()
	var e := _esya_at(H + Vector3(0.5, 0.2, 0))
	_kamera(H, Vector3(4.5, 2.6, 4.5))
	await _tp(Vector3(H.x + 8, 0.05, H.z + 8), H)
	await _kare("h_patlama_1_once", e)
	Vfx.explosion(self, H + Vector3(0.6, 0, -1.6), 0.6)
	await _dizi("h_patlama", e, 1.0)
	var n := 0
	for o in ef.items:
		var c: Vector3 = ef._merkez(o)
		if Vector2(c.x - H.x, c.z - H.z).length() < 6.0 and o["durum"] != "uyur":
			n += 1
	print("ESYATEST patlama uyanan=%d" % n)
	if n < 5:
		_hata("H patlamada az eşya uyandı: %d" % n)


func _s_dusur() -> void:
	# düşen yük (Bölüm 20 _fall_load gibi): 1,6 m'den yan hızla bırakılan fıçı ve kalas
	var yuk := Node3D.new()
	add_child(yuk)
	yuk.global_position = Vector3(-10, 1.6, 6)
	Props.cyl(yuk, 0.3, 0.8, Vector3.ZERO, Color("7a5432"), Vector3(0, 0, 0), 12)
	var kal := Node3D.new()
	add_child(kal)
	kal.global_position = Vector3(-12, 1.4, 6)
	Props.box(kal, Vector3(0.24, 0.1, 2.6), Vector3.ZERO, Color("8a6440"), Vector3(0, 12, 0))
	_kamera(Vector3(-11, 0.5, 7), Vector3(3.5, 2.0, 4.0))
	await _kare("i_dusur_1_once", {})
	var ok1 := EsyaFizik.dusur(yuk, "", Vector3(2.0, 1.0, 0.5), Vector3(0, 0, -3))
	var ok2 := EsyaFizik.dusur(kal, "", Vector3(1.0, 1.2, 0.0), Vector3(1.5, 0, 0))
	if not ok1 or not ok2:
		_hata("dusur başarısız")
		return
	var ef := EsyaFizik.ben()
	var e1: Dictionary = ef.items[ef.items.size() - 2]
	var e2: Dictionary = ef.items[ef.items.size() - 1]
	print("ESYATEST dusur turler=%s,%s" % [e1["tur"], e2["tur"]])
	await _dizi("i_dusur", e1, 0.1)
	for e in [e1, e2]:
		var g := e["govde"] as RigidBody3D
		if g == null or e["durum"] != "donmus":
			_hata("düşen %s donmadı" % e["tur"])
			continue
		var bos: float = ef._zemin_boslugu(g)
		print("ESYATEST dusur %s y=%.2f bosluk=%.3f" % [e["tur"], g.global_position.y, bos])
	# düğüm silinince gövde de kalkar
	yuk.queue_free()
	await get_tree().physics_frame
	await get_tree().physics_frame
	if is_instance_valid(e1["govde"]) if e1["govde"] != null else false:
		_hata("düşen düğüm silinince gövde kalmadı")


func _s_sinir() -> void:
	# büyük patlama: çok eşya aynı anda uyanır; uyanık sayısı 12'yi aşmamalı
	var ef := EsyaFizik.ben()
	var d := Dressing.new(11)
	for i in 16:
		d.at(Vector3(-30 + (i % 4) * 1.2, 0, 20 + (i / 4) * 1.2)).barrel(Vector3.ZERO)
	d.build(self)
	await _bekle(0.8)
	_kamera(Vector3(-28, 0, 22), Vector3(6, 4, 6))
	Vfx.explosion(self, Vector3(-28.2, 0, 21.8), 1.2)
	var en := 0
	for i in 90:
		await get_tree().physics_frame
		en = maxi(en, ef.uyanik.size())
	await _kare("j_sinir_1_patlama", {})
	print("ESYATEST sinir en_cok=%d" % en)
	if en > EsyaFizik.AZAMI_UYANIK:
		_hata("uyanık sınırı aşıldı: %d" % en)
	var t := 0.0
	while not ef.uyanik.is_empty() and t < 14.0:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
	await _kare("j_sinir_2_durunca", {})


func _genel_denetim() -> void:
	var ef := EsyaFizik.ben()
	await _bekle(0.5)
	var havada := 0
	var dusuk := 0
	for e in ef.items:
		var g = e.get("govde")
		if g == null or not is_instance_valid(g):
			continue
		var rb := g as RigidBody3D
		if e["durum"] == "uyanik":
			continue
		var bos: float = ef._zemin_boslugu(rb)
		if bos > 0.06:
			havada += 1
			print("ESYATEST havada %s id=%d at=%s bos=%.2f" % [e["tur"], e["id"], str(rb.global_position), bos])
		if ef._zemin_alti(rb):
			dusuk += 1
	print("ESYATEST genel havada=%d dusuk=%d uyanik=%d sorun=%d" % [havada, dusuk, ef.uyanik.size(), ef.sorun()])
	if havada > 0:
		_hata("donmuş ama havada: %d" % havada)
	if dusuk > 0:
		_hata("zemin altında: %d" % dusuk)
	if int(ef.sayac["dusme"]) + int(ef.sayac["gomuk"]) + int(ef.sayac["havada"]) > 0:
		_hata("denetim düzeltmesi gerekti: %s" % str(ef.sayac))
