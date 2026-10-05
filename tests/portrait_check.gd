extends Node
## Canlı portre denetimi (v0.83): konuşan her karakterin (docs/voice/VOICE_MAP.csv) stüdyo kopyası kurulur. Kopya
## sahnenin işlerine karışmaz (konuşmacı aramasında, kalabalıkta, görsel denetimde görünmez), kafası çerçevededir,
## konuşurken ağzı açılır. Eski düz çizimlere dönen konuşmacı yoktur; görünüşü tanımsız (rastgele yüz) olanlar
## yalnız birkaç replikli figüranlar olabilir. Tolga'nın kopyası sahnedeki hâliyle (fes) kurulur. Sonuç: PORTRAITCHECK PASS/FAIL.

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
