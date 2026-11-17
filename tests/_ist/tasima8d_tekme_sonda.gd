extends Node
## tasima8d_tekme.tscn'in kalıcı sondası (kök altında; sahne değişince yaşar). Açıklama tasima8d_tekme.gd'de.

var dizi_n := 3
var bekle := 6.0
var _hata: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		match kv[0]:
			"dizi": dizi_n = int(kv[1])
			"bekle": bekle = float(kv[1])
	_kos.call_deferred()


func _oyuncu() -> Player:
	return get_tree().get_first_node_in_group("player") as Player


func _bekle(sn: float) -> void:
	var t := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t < int(sn * 1000.0):
		await get_tree().process_frame


func _kos() -> void:
	var t := 0.0
	while t < 90.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		var sc := get_tree().current_scene
		if sc and String(sc.name).begins_with("Chapter") and _oyuncu() != null:
			break
	var sc := get_tree().current_scene
	print("T8DTEKME sahne=%s" % (sc.name if sc else "yok"))
	await _bekle(bekle)
	var ef := EsyaFizik.ben()
	var sur = sc.get("sur") if sc else null
	if ef == null or sur == null or sur.eski_mi:
		print("T8DTEKME FAIL esya=%s sur=%s" % [ef != null, sur != null])
		get_tree().quit(1)
		return
	ef.denetim_acik = true
	# dış sur yolundaki fıçılar, x'e göre dizilere
	var yy: float = sur.dis_yol_y()
	var fici: Array = []
	for e in ef.items:
		if String(e["tur"]) == "fici" and e["durum"] == "uyur" and absf(float(e["zemin_y"]) - yy) < 0.35:
			var c: Vector3 = ef._merkez(e)
			if absf(c.z - sur.dis_yol_z()) < 2.0:
				fici.append(e)
	fici.sort_custom(func(a, b): return ef._merkez(a).x < ef._merkez(b).x)
	var diziler: Array = []
	for e in fici:
		var x: float = ef._merkez(e).x
		if diziler.is_empty() or x - ef._merkez((diziler.back() as Array).back()).x > 1.2:
			diziler.append([e])
		else:
			(diziler.back() as Array).append(e)
	# oyuncunun bölümde gittiği yere yakın diziler önce (gedik çevresi)
	diziler.sort_custom(func(a, b): return absf(ef._merkez(a[0]).x) < absf(ef._merkez(b[0]).x))
	print("T8DTEKME fici=%d dizi=%d" % [fici.size(), diziler.size()])
	var pl := _oyuncu()
	pl.frozen = false
	var n := 0
	for d: Array in diziler:
		if n >= dizi_n:
			break
		if d.size() < 2:
			continue
		n += 1
		var e: Dictionary = d[0]          # dizinin -x ucundaki fıçı
		await _tekme(n, 1, e, Vector3(1, 0, 0), sur)
		await _tekme(n, 2, e, Vector3(0, 0, 1), sur)
		await _tekme(n, 3, e, Vector3(1, 0, 0), sur)
		await _tekme(n, 4, d[1], Vector3(0, 0, -1), sur, true)
	var s: int = ef.sorun()
	if n == 0:
		_hata.append("dizi yok")
	if s > 0:
		_hata.append("ESYAAUDIT sorun=%d" % s)
	print("T8DTEKME OZET dizi=%d sayac=%s" % [n, str(ef.sayac)])
	print("T8DTEKME %s %s" % ["PASS" if _hata.is_empty() else "FAIL", "; ".join(_hata)])
	get_tree().quit(0 if _hata.is_empty() else 1)


## Oyuncuyu fıçının yon'un tersi yanına koyup (sur yolunun içinde) tekmeletir, donmasını bekler, yanlarını ölçer
func _tekme(dizi: int, adim: int, e: Dictionary, yon: Vector3, sur, savur := false) -> void:
	var ef := EsyaFizik.ben()
	var pl := _oyuncu()
	var c: Vector3 = ef._merkez(e)
	var r: float = ef._yaricap(e)
	var pp := c - yon * (r + 0.85)
	# oyuncu sur yolunun içinde kalır (korkuluğa yaslı fıçının arkası korkuluk)
	pp.z = clampf(pp.z, sur.dis_yol_ic_z() - 0.1, sur.dis_yol_on_z())
	pp.y = sur.dis_yol_y() + 0.05
	for i in 6:
		pl.global_position = pp
		pl.velocity = Vector3.ZERO
		pl.face(Vector3(c.x, pp.y + 1.5, c.z))
		await get_tree().physics_frame
	var c0 := c
	var once: int = ef.sorun()
	if savur:
		# 4. adım: korkuluk yanında oyuncu duramaz; gülle benzetimi: fıçı sur yolunun ortasına doğru savrulur (yatık,
		# yuvarlanır). Donma kuralı onu yolun ortasında bırakmamalı.
		pl.global_position = Vector3(c.x - 4.0, sur.dis_yol_y() + 0.05, sur.dis_yol_z())
		ef._uyandir(e)
		ef._itki(e, yon * 70.0 + Vector3.UP * 25.0, Vector3(0, 0.3, 0))
	else:
		pl.kick(c, 0.75, func() -> void: pass)
	var t := 0.0
	while e["durum"] == "uyur" and t < 2.0:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
	if OS.has_environment("T8D_IZ") and e.get("govde") != null:
		var g1 := e["govde"] as RigidBody3D
		print("T8DTEKME iz0 p=%s v=%s kutle=%.1f kare=%d bekleyen=%s" % [g1.global_position, g1.linear_velocity, g1.mass, int(e.get("kare", -1)), str(e.get("bekleyen", []))])
	var uyandi: bool = e["durum"] != "uyur"
	t = 0.0
	var iz_t := 0.0
	while e["durum"] == "uyanik" and t < 12.0:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
		var gz = e.get("govde")
		if OS.has_environment("T8D_IZ") and (t >= iz_t or t < 0.15) and gz != null and is_instance_valid(gz):
			if t >= iz_t:
				iz_t += 0.25
			var cb := ""
			for b in (gz as RigidBody3D).get_colliding_bodies():
				cb += " " + str(b.name) + ("@" + str((b as Node3D).global_position.snapped(Vector3.ONE * 0.01)))
			print("T8DTEKME iz t=%.2f p=%s v=%s w=%s kare=%d temas=%s" % [t, (gz as Node3D).global_position.snapped(Vector3.ONE * 0.01), (gz as RigidBody3D).linear_velocity.snapped(Vector3.ONE * 0.01), (gz as RigidBody3D).angular_velocity.snapped(Vector3.ONE * 0.01), int(e.get("kare", -1)), cb])
	var g0 = e.get("govde")
	if e["durum"] == "uyanik" and g0 != null and is_instance_valid(g0):
		var rb0 := g0 as RigidBody3D
		print("T8DTEKME uyanik t=%.1f dur_t=%.2f lv=%.3f av=%.3f uyur=%s yasla=%s kare=%d" % [float(e["t"]), float(e["dur_t"]),
			rb0.linear_velocity.length(), rb0.angular_velocity.length(), rb0.sleeping, str(e.get("yasla", Vector3.ZERO)), int(e.get("kare", 0))])
	# tekme hareketi bitsin (bacak görünürken Player.kick gövdeyi tween'le geri çeker)
	t = 0.0
	while pl.leg != null and pl.leg.visible and t < 3.0:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
	await _bekle(0.3)
	# ölçüme karışmasın: oyuncu 4 m öteye; fıçı yeniden uyandıysa donmasını bekle
	pl.global_position = Vector3(c.x - 4.0, sur.dis_yol_y() + 0.05, sur.dis_yol_z())
	t = 0.0
	while (e["durum"] == "uyanik" or t < 0.2) and t < 12.0:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
	print("T8DTEKME oyuncu=%s durum=%s" % [pl.global_position.snapped(Vector3.ONE * 0.01), e["durum"]])
	var g = e.get("govde")
	var bos_a := -1.0
	var bos_b := -1.0
	var gp := c0
	var yan := Vector3.ZERO
	if g != null and is_instance_valid(g):
		var rb := g as RigidBody3D
		gp = rb.global_position
		var space := rb.get_world_3d().direct_space_state
		var ax := Vector3.BACK
		var ra: float = ef._yari_en(rb, ax, r)
		bos_a = ef._duvar(space, rb, gp, ax, 2.6) - ra
		bos_b = ef._duvar(space, rb, gp, -ax, 2.6) - ra
		yan = ef._gecit_yan(rb, gp, r)
	var gecer := maxf(bos_a, bos_b) >= 0.75
	print("T8DTEKME dizi=%d adim=%d id=%d uyandi=%s durum=%s once=%s sonra=%s yol=%.2f bos_on=%.2f bos_ic=%.2f gecer=%s yan=%s denetim=%d" % [
		dizi, adim, e["id"], uyandi, e["durum"], c0.snapped(Vector3.ONE * 0.01), gp.snapped(Vector3.ONE * 0.01),
		Vector2(gp.x - c0.x, gp.z - c0.z).length(), bos_a, bos_b, gecer, yan.snapped(Vector3.ONE * 0.01), ef.sorun() - once])
	if e["durum"] == "uyanik":
		_hata.append("dizi %d adim %d: donmadı" % [dizi, adim])
	# Ölçüt: oyuncu tekmesi (1–3) sur yolunu tıkamaz (bir yanında ≥ 0,75 m); savrulmada (4) donma kuralı fıçıyı yolun
	# ortasında bırakmaz (yanında yaslanacak yer kalmaz: _gecit_yan ZERO) ve denetim satırı çıkmaz. Savrulan fıçının
	# geniş yanı ayrıca yazılır (enine yatınca 0,65–0,75 m kalabiliyor: raporda "hâlâ kötü").
	if adim < 4 and not gecer and g != null:
		_hata.append("dizi %d adim %d: sur yolu tıkalı (iki yanı < 0,75 m)" % [dizi, adim])
	if adim == 4 and yan != Vector3.ZERO:
		_hata.append("dizi %d adim %d: yolun ortasında dondu" % [dizi, adim])
	if ef.sorun() - once > 0:
		_hata.append("dizi %d adim %d: ESYAAUDIT satırı" % [dizi, adim])
