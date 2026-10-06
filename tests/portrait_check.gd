extends Node
## Canlı portre denetimi (v0.83): konuşan her karakterin (docs/voice/VOICE_MAP.csv) stüdyo kopyası kurulur. Kopya
## sahnenin işlerine karışmaz (konuşmacı aramasında, kalabalıkta, görsel denetimde görünmez), kafası çerçevededir,
## konuşurken ağzı açılır. Eski düz çizimlere dönen konuşmacı yoktur; görünüşü tanımsız (rastgele yüz) olanlar
## yalnız birkaç replikli figüranlar olabilir. Tolga'nın kopyası sahnedeki hâliyle (fes, kaftan) kurulur. Sonuç: PORTRAITCHECK PASS/FAIL.

## Görünüşü tanımsız kalabilecek (iki replikten az) konuşmacı yok; tanımsız olanların en çok bu kadar repliği olabilir
const GENERIC_MAX_LINES := 1
## Kameranın bakılan noktaya uzaklığı (en az, en çok): insan kafası ve çocuk, tavuk, cihaz
const FRAME_DIST := {"person": Vector2(1.0, 1.8), "hikmet": Vector2(1.0, 1.8), "chicken": Vector2(0.7, 1.3),
	"radio": Vector2(1.2, 2.0), "loudspeaker": Vector2(1.2, 2.0)}


func _ready() -> void:
	GameState.autotest = true
	var counts := _speakers()
	var studio := PortraitStudio.new()
	add_child(studio)
	await get_tree().process_frame
	var ok := true
	var generic: Array = []
	for k: String in counts:
		var lk := PortraitLooks.look(k)
		var known: bool = PortraitLooks.LOOKS.has(k) or PortraitLooks.SIDED.has(k) or PortraitLooks.DEVICES.has(k) \
			or k in ["SPK_TOLGA", "SPK_HIKMET", "SPK_SINERJI"]
		if not known:
			generic.append("%s:%d" % [k, counts[k]])
			if int(counts[k]) > GENERIC_MAX_LINES:
				print("PORTRAITCHECK tanımsız görünüş %s (%d replik)" % [k, counts[k]])
				ok = false
		if not studio.show_for(k):
			print("PORTRAITCHECK kurulamadı %s" % k)
			ok = false
			continue
		await get_tree().process_frame
		var n: Node3D = studio.get("_cur")
		if n == null or not is_instance_valid(n) or not n.visible:
			print("PORTRAITCHECK kopya yok %s" % k)
			ok = false
			continue
		for g in ["persons", "persons_hikmet", "soldiers"]:
			if n.is_in_group(g):
				print("PORTRAITCHECK kopya sahnede aranır %s (%s)" % [k, g])
				ok = false
		# Kafa (ya da cihaz) kameranın önünde, çerçevenin ortasında; ne kareyi taşıracak kadar yakın ne kaybolacak kadar uzak
		var cam: Camera3D = studio.get("_cam")
		var kind := str(lk["kind"])
		var aim: Vector3
		match kind:
			"person", "hikmet":
				aim = LivePortrait.head_of(n)
			"chicken":
				aim = n.global_position + PortraitStudio.CHICKEN_AIM
			_:
				aim = n.global_position + PortraitStudio.DEVICE_AIM
		var span: Vector2 = FRAME_DIST.get(kind, Vector2(1.0, 1.8))
		var to := aim - cam.global_position
		if to.length() < span.x or to.length() > span.y or to.normalized().dot(-cam.global_transform.basis.z) < 0.97:
			print("PORTRAITCHECK çerçeve dışı %s d=%.2f" % [k, to.length()])
			ok = false
		if str(lk["kind"]) in ["person", "hikmet"] and not bool(n.get("talking")):
			print("PORTRAITCHECK konuşmuyor %s" % k)
			ok = false
	studio.stop()
	# Tolga'nın kopyası o anki hâliyle: "fez" bayrağı açık olsa da (1453'te takacağı) sahnede fes yoksa kopyada da yok;
	# sinematikte birinci şahıs fes katmanı gizlenir ama fes baştadır (ayna ve fotoğraf modu da aynı kuralı kullanır)
	var hud := Hud.new()
	add_child(hud)
	await get_tree().process_frame
	GameState.flags["fez"] = true
	var hats: Array = []
	hud.set_fez(false)
	hats.append(str(PortraitLooks.look("SPK_TOLGA")["p"]["hat"]))
	hud.set_fez(true)
	hud.set_cinematic(true)
	hats.append(str(PortraitLooks.look("SPK_TOLGA")["p"]["hat"]))
	hud.set_cinematic(false)
	if hats != ["none", "fez"]:
		print("PORTRAITCHECK Tolga'nın fesi sahneye uymuyor %s" % [hats])
		ok = false
	# Kaftan 1453 kılığıyla: 2026 sahnesinde (fes kalkmış, bayrak açık) dolapta; fes baştayken ya da Tolga fesi 1453'te
	# kendi çıkardıysa (bayrak da kapalı) üstünde
	GameState.flags["has_kaftan"] = true
	var robes: Array = []
	hud.set_fez(false)
	robes.append(PortraitLooks.look("SPK_TOLGA")["p"].has("robe"))
	hud.set_fez(true)
	robes.append(PortraitLooks.look("SPK_TOLGA")["p"].has("robe"))
	GameState.flags["fez"] = false
	hud.set_fez(false)
	robes.append(PortraitLooks.look("SPK_TOLGA")["p"].has("robe"))
	GameState.flags["fez"] = true
	GameState.flags["has_kaftan"] = false
	if robes != [false, true, true]:
		print("PORTRAITCHECK Tolga'nın kaftanı sahneye uymuyor %s" % [robes])
		ok = false
	# Sahnedeki yatan konuşan (kirişin altındaki azap, kızaktaki yaralı): kamera yüzün üstünden bakar, kafa ortada ve
	# kartta dik (başın tepesi yukarıda); ayakta duranın kamerası yüzün önünde
	var live := LivePortrait.new()
	add_child(live)
	for lying: bool in [true, false]:
		var pr := Person.new({"coat": Color("8a3a2e"), "hat": "azap", "mustache": true})
		add_child(pr)
		pr.position = Vector3(30.0, 0.15 if lying else 0.0, 0.0)
		pr.rotation = Vector3(-PI * 0.5, PI * 0.5, 0.0) if lying else Vector3(0.0, 0.6, 0.0)
		await get_tree().process_frame
		live.show_for(pr, get_viewport())
		var lc: Camera3D = live.get("_cam")
		var head := LivePortrait.head_of(pr)
		var lto := head - lc.global_position
		var b := pr.global_transform.basis.orthonormalized()
		var upright := lc.global_transform.basis.y.dot(b.y) > 0.7
		var placed := (lc.global_position.y - head.y > 0.9) if lying else ((lc.global_position - head).dot(b.z) > 0.9)
		if not placed or not upright or lto.normalized().dot(-lc.global_transform.basis.z) < 0.97:
			print("PORTRAITCHECK %s konuşanın çerçevesi bozuk cam=%s head=%s" % ["yatan" if lying else "ayakta", lc.global_position, head])
			ok = false
		live.stop()
		pr.queue_free()
	# Yüzü duvara dönük konuşan (tünelde kayayı kazan lağımcı): yüzün önü kapalı; kart kamerası başın çevresinde açık bir
	# yere döner (eskiden kayanın içinde kalıyor, kartta yüz yerine kaya görünüyordu)
	var digger := Person.new({"coat": Color("6a5040"), "hat": "bork", "mustache": true})
	add_child(digger)
	digger.position = Vector3(40.0, 0.0, 0.0)
	var rock := Node3D.new()
	add_child(rock)
	Props.solid(rock, Vector3(3.0, 3.0, 0.3), Vector3(40.0, 1.5, 0.7), Color("6a6a6a"))
	await get_tree().physics_frame
	await get_tree().process_frame
	var front: Vector3 = LivePortrait.pose(digger)[0]
	live.show_for(digger, get_viewport())
	var dc: Camera3D = live.get("_cam")
	var dh := LivePortrait.head_of(digger)
	if LivePortrait.blocker(digger, front, dh) == null:
		print("PORTRAITCHECK duvar denemesi kurulamadı (yüzün önü açık)")
		ok = false
	elif LivePortrait.blocker(digger, dc.global_position, dh) != null:
		print("PORTRAITCHECK duvara dönük konuşanın yüzü duvarın ardında kaldı cam=%s" % dc.global_position)
		ok = false
	live.stop()
	digger.queue_free()
	rock.queue_free()
	# Çarpışması olmayan, yalnız görünen bir duvar (33o'da yapımı süren kulenin silindiri): yalnız çizimli çalışmada
	# denenir (çizim motorunun ışın sorgusu başsız çalışmada boş döner)
	if DisplayServer.get_name() != "headless":
		var mason := Person.new({"coat": Color("6a5040"), "hat": "turban", "mustache": true})
		add_child(mason)
		mason.position = Vector3(50.0, 0.0, 0.0)
		var tower := Node3D.new()
		add_child(tower)
		Props.box(tower, Vector3(3.0, 3.0, 0.4), Vector3(50.0, 1.5, 0.8), Color("8a8070"))
		await get_tree().process_frame
		await get_tree().process_frame
		var mfront: Vector3 = LivePortrait.pose(mason)[0]
		live.show_for(mason, get_viewport())
		var mc: Camera3D = live.get("_cam")
		var mh := LivePortrait.head_of(mason)
		if LivePortrait.blocker(mason, mfront, mh) == null:
			print("PORTRAITCHECK görünen duvar denemesi kurulamadı")
			ok = false
		elif LivePortrait.blocker(mason, mc.global_position, mh) != null:
			print("PORTRAITCHECK çarpışmasız duvara dönük konuşanın yüzü duvarın ardında kaldı cam=%s" % mc.global_position)
			ok = false
		live.stop()
		mason.queue_free()
		tower.queue_free()
	# Kalabalıkta konuşan (bölükte arka sıradaki): önünde duran kişinin çarpışması yok ama kart kamerası onu da engel sayar,
	# ensesini değil konuşanın yüzünü çeker. Omuz omuza duran yanındaki engel sayılmaz (kamera önde kalır).
	var rank := Person.new({"coat": Color("8a3a2e"), "hat": "azap", "mustache": true})
	add_child(rank)
	rank.position = Vector3(60.0, 0.0, 0.0)
	var mate := Person.new({"coat": Color("3a5a8a"), "hat": "bork"})
	add_child(mate)
	mate.position = Vector3(60.0, 0.0, 0.85)
	var side := Person.new({"coat": Color("5a8a3a"), "hat": "bork"})
	add_child(side)
	side.position = Vector3(59.45, 0.0, 0.0)
	await get_tree().process_frame
	var rfront: Vector3 = LivePortrait.pose(rank)[0]
	var rh := LivePortrait.head_of(rank)
	live.show_for(rank, get_viewport())
	var rc: Camera3D = live.get("_cam")
	if LivePortrait.blocker(rank, rfront, rh) != mate:
		print("PORTRAITCHECK önde duran kişi kart kamerasının engeli sayılmadı")
		ok = false
	elif LivePortrait.blocker(rank, rc.global_position, rh) != null:
		print("PORTRAITCHECK kalabalıktaki konuşanın yüzü öndekinin ardında kaldı cam=%s" % rc.global_position)
		ok = false
	mate.position.x += 4.0
	live.show_for(rank, get_viewport())
	if rc.global_position.distance_to(rfront) > 0.05:
		print("PORTRAITCHECK yanındaki kişi yüzünden kamera boş yere döndü cam=%s front=%s" % [rc.global_position, rfront])
		ok = false
	live.stop()
	for q in [rank, mate, side]:
		q.queue_free()
	# Başın yanında kaya (21o'da tünelde kazan lağımcı): yüzün ortasına giden ışın açık ama kaya karenin yarısını kapatır;
	# kare başın çevresiyle birlikte açık olmalı
	var miner := Person.new({"coat": Color("6a5040"), "hat": "bork", "mustache": true})
	add_child(miner)
	miner.position = Vector3(70.0, 0.0, 0.0)
	var stone := Node3D.new()
	add_child(stone)
	Props.solid(stone, Vector3(0.5, 0.6, 0.5), Vector3(70.3, 1.65, 0.6), Color("6a6a6a"))
	await get_tree().physics_frame
	await get_tree().process_frame
	var sfront: Vector3 = LivePortrait.pose(miner)[0]
	var sh := LivePortrait.head_of(miner)
	live.show_for(miner, get_viewport())
	var sc: Camera3D = live.get("_cam")
	if LivePortrait.blocker(miner, sfront, sh) == null:
		print("PORTRAITCHECK başın yanındaki kaya kareyi kapatırken engel sayılmadı")
		ok = false
	elif LivePortrait.blocker(miner, sc.global_position, sh) != null:
		print("PORTRAITCHECK yanında kaya olan konuşanın karesi kapalı kaldı cam=%s" % sc.global_position)
		ok = false
	live.stop()
	miner.queue_free()
	stone.queue_free()
	var mat := load("res://assets/shaders/radio_portrait.gdshader")
	if mat == null:
		print("PORTRAITCHECK telsiz gölgelendiricisi yok")
		ok = false
	print("PORTRAITCHECK %s speakers=%d generic=%s" % ["PASS" if ok else "FAIL", counts.size(), ",".join(generic)])
	get_tree().quit(0 if ok else 1)


## Replik haritasındaki konuşmacılar ve replik sayıları
func _speakers() -> Dictionary:
	var out := {}
	var f := FileAccess.open("res://docs/voice/VOICE_MAP.csv", FileAccess.READ)
	if f == null:
		return {"SPK_TOLGA": 1}
	f.get_csv_line()
	while not f.eof_reached():
		var r := f.get_csv_line()
		if r.size() < 3 or not r[2].begins_with("SPK_"):
			continue
		out[r[2]] = int(out.get(r[2], 0)) + 1
	return out
