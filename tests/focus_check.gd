extends Node
## Odak kaybı denetimi (v0.99.116): pencere odağı kaybedilince (Alt+Tab, bildirim) duraklatma menüsü GERÇEKTEN açılır
## ve "devam" ile oyun sürer. Eskiden menü, bildirimin yayılması sırasında eklenmeye çalışıldığı için ağaca giremiyordu
## ("Parent node is busy setting up children"): oyun duraklamış, menüsüz ve çıkışsız kalıyordu (siyah ekran).
## Testlerde odak duraklatması kapalı olduğundan bu sahne autotest'siz çalışır. Çıktı: FOCUSCHECK PASS / FAIL.

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var errs: Array[String] = []
	var world := Node3D.new()
	add_child(world)
	var hud := Hud.new()
	world.add_child(hud)
	for i in 5:
		await get_tree().process_frame
	# Anlık odak titremesi (pencere kısa sürede yeniden odaklı): oyun duraklamaz
	get_tree().root.propagate_notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	await get_tree().create_timer(0.8, true, false, true).timeout
	if get_tree().paused or hud.get("_menu") != null:
		errs.append("anlık odak titremesi oyunu duraklattı")
		get_tree().paused = false
	# Gerçek odak kaybı. Motorun yaptığı gibi: bildirim kökten bütün ağaca yayılır
	hud.set("focus_test_unfocused", true)
	get_tree().root.propagate_notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	await get_tree().create_timer(0.8, true, false, true).timeout
	var menu: Node = hud.get("_menu")
	if not get_tree().paused:
		errs.append("odak kaybında oyun duraklamadı")
	if menu == null:
		errs.append("duraklatma menüsü kurulmadı")
	elif not menu.is_inside_tree():
		errs.append("duraklatma menüsü ağaca girmedi (oyun menüsüz duraklı kalır)")
	else:
		# İkinci odak kaybı ikinci menü açmaz
		get_tree().root.propagate_notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		await get_tree().create_timer(0.8, true, false, true).timeout
		var n := 0
		for c in hud.get_children():
			if c is GameMenu:
				n += 1
		if n != 1:
			errs.append("iki odak kaybında %d menü" % n)
		menu.emit_signal("picked", "resume", 0)
		for i in 5:
			await get_tree().process_frame
		if get_tree().paused:
			errs.append("'devam'dan sonra oyun duraklı kaldı")
		if hud.get("_menu") != null:
			errs.append("'devam'dan sonra menü kapanmadı")
	get_tree().paused = false
	print("FOCUSCHECK %s%s" % ["PASS" if errs.is_empty() else "FAIL", "" if errs.is_empty() else "  " + " | ".join(errs)])
	get_tree().quit(0 if errs.is_empty() else 1)
