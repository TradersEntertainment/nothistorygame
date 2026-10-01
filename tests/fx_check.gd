extends Node
## Fx denetimi: donma ve ağır çekim zaman ölçeğini düşürür ve süre sonunda tabana (bölümün 3× hızlandırması dahil)
## geri döndürür; bölüm etki sürerken ölçeği değiştirirse yeni taban odur; sahne değişimi etkiyi sıfırlar.

func _ready() -> void:
	await get_tree().process_frame
	var ok := true
	for base: float in [1.0, 3.0]:
		Engine.time_scale = base
		await get_tree().process_frame
		Fx.hitstop(0.1)
		await get_tree().process_frame
		await get_tree().process_frame
		var during := Engine.time_scale
		await get_tree().create_timer(0.4, true, false, true).timeout
		var after := Engine.time_scale
		Fx.slowmo(0.3, 0.3, 0.2)
		await get_tree().process_frame
		await get_tree().process_frame
		var slow := Engine.time_scale
		await get_tree().create_timer(0.8, true, false, true).timeout
		var back := Engine.time_scale
		var good := during < base * 0.1 and is_equal_approx(after, base) and slow < base * 0.5 and is_equal_approx(back, base) \
			and is_equal_approx(AudioServer.playback_speed_scale, 1.0)
		print("FXCHECK base=%.1f during=%.3f after=%.2f slow=%.2f back=%.2f %s" % [base, during, after, slow, back, "ok" if good else "BAD"])
		ok = ok and good
	# Etki sürerken bölüm ölçeği değiştirirse yeni taban o olur
	Engine.time_scale = 1.0
	await get_tree().process_frame
	Fx.slowmo(0.3, 0.5, 0.1)
	await get_tree().process_frame
	await get_tree().process_frame
	Engine.time_scale = 2.0
	await get_tree().create_timer(0.9, true, false, true).timeout
	var taken := is_equal_approx(Engine.time_scale, 2.0)
	print("FXCHECK override=%.2f %s" % [Engine.time_scale, "ok" if taken else "BAD"])
	ok = ok and taken
	Engine.time_scale = 1.0
	print("FXCHECK %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit()
