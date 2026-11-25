extends SceneTree
## CI #344 (38o VISAUDIT float, iki devriye eri aynı y'de 0,8 m havada) sondası. Bölümü açar, 6 sn bekler; sonra
## (1) DOGUS: her etkin devriyeyi tek numaralı karede (CityLife._frame tek) 75 kez yeniden doğurur ve erlerin
##     yüksekliğini doğduğu anda yüzeyle (World1453.surface_h) karşılaştırır (eski kodda iz noktası reisin yüksekliğinde);
## (2) IZLE: 20 sn boyunca her karede etkin erlerin yüksekliğini karşılaştırır.
## Kullanım: godot --headless --path . -s tests/_ci344/devriye_yamac.gd -- res://scenes/chapter38o.tscn
func _initialize() -> void:
	_run()


func _run() -> void:
	var sp: String = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "res://scenes/chapter38o.tscn"
	root.get_node("GameState").settings["auto_advance"] = false
	change_scene_to_file(sp)
	await create_timer(6.0).timeout
	var sc := current_scene
	if sc == null:
		print("DEVRIYEYAMAC sahne_yok")
		quit(1)
		return
	var W = load("res://scripts/world/world1453.gd")
	var cls := sc.find_children("CityLife", "", true, false)
	# (1) Doğuş
	var dogus := 0
	var d_hata := 0
	var d_enb := 0.0
	for cl in cls:
		for tur in 75:
			for ld in cl.get("agents"):
				if ld == null or ld.kind != "patrol" or ld.slot != 0:
					continue
				var fl: Array = cl.call("_followers", ld)
				if fl.is_empty():
					continue
				var kuruldu := true
				for m in [ld] + fl:
					kuruldu = cl.call("_ensure_body", m) and kuruldu
					if m.active:
						cl.call("_deactivate", m)
				if not kuruldu:
					continue
				cl.set("_frame", 2 * tur + 1)
				if not cl.call("_spawn_patrol", ld, fl, true):
					continue
				for f in fl:
					dogus += 1
					var e: float = absf(f.pos.y - W.surface_h(f.pos.x, f.pos.z))
					d_enb = maxf(d_enb, e)
					if e > 0.35:
						d_hata += 1
	# (2) İzleme
	var t0 := Time.get_ticks_msec()
	var er_kare := 0
	var hata := 0
	var enb := 0.0
	while Time.get_ticks_msec() - t0 < 20000:
		await process_frame
		for cl in cls:
			if not is_instance_valid(cl):
				continue
			for ag in cl.get("agents"):
				if ag == null or not ag.active or ag.kind != "patrol" or ag.slot == 0:
					continue
				er_kare += 1
				var e: float = absf(ag.pos.y - W.surface_h(ag.pos.x, ag.pos.z))
				enb = maxf(enb, e)
				if e > 0.35:
					hata += 1
	print("DEVRIYEYAMAC scene=%s citylife=%d DOGUS er=%d hata(>0.35)=%d en_buyuk=%.2f IZLE er_kare=%d hata=%d en_buyuk=%.2f" % [
		sp.get_file(), cls.size(), dogus, d_hata, d_enb, er_kare, hata, enb])
	quit(0)
