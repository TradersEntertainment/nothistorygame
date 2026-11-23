extends "res://tests/_ist/tasima10_kare.gd"
## TAŞIMA-12 kare aracı (Taşıma 10'unkinin üstüne): aynı sürüş, yeni bölümlerin bakışları.
##   xvfb-run … godot --path . --resolution 1280x720 res://tests/_ist/tasima12_kare.tscn -- bolum=8y shots=KLASÖR [yalniz=a,b] [--eskisur=8y]
## Satırlar: T10KARE_YUKLE · T10KARE ad=… cizim=… ilkel=… · T10KARE_BITTI


func _hazirla() -> void:
	match bolum:
		"13", "23", "24":
			GameState.chapter_outcomes[8] = "8.1"
		_:
			super._hazirla()


func _bakislar() -> Array:
	var c := city as Node3D
	match bolum:
		"8y":
			var b: Array = super._bakislar()
			var g := func(x: float, z: float) -> float: return float(ch.call("_gy", x, z))
			var cr: Vector3 = (ch.get_script() as Script).get_script_constant_map()["BATTERY"] + Vector3(3.2, 0, 4.4)
			var y := float(g.call(cr.x, cr.z))
			b.append(["08_halatci_yakin", ch.to_global(Vector3(cr.x - 1.3, y + 0.75, cr.z + 0.9)), ch.to_global(Vector3(cr.x, y + 0.15, cr.z)), ch.to_global(Vector3(cr.x - 3.0, y, cr.z - 2.0))])
			b.append(["09_halatci_yan", ch.to_global(Vector3(cr.x + 0.2, y + 0.35, cr.z + 1.6)), ch.to_global(Vector3(cr.x, y + 0.1, cr.z)), ch.to_global(Vector3(cr.x - 3.0, y, cr.z - 2.0))])
			b.append(["10_batarya", ch.to_global(Vector3(cr.x - 7.0, y + 1.8, cr.z - 6.0)), ch.to_global(Vector3(cr.x - 2.0, y + 0.6, cr.z)), ch.to_global(Vector3(cr.x - 7.0, y, cr.z - 6.0))])
			return b
		"13", "23", "24":
			var gz := 5.5
			return [
				["01_caddeden_sur", c.to_global(Vector3(-20.0, 1.7, -14.0)), c.to_global(Vector3(34.0, 7.0, -10.0)), null],
				["02_kapi_sehir_yani", c.to_global(Vector3(22.0, 1.7, 0.5)), c.to_global(Vector3(33.0, 3.5, gz)), null],
				["03_ufuk", c.to_global(Vector3(0.0, 2.0, 10.0)), c.to_global(Vector3(60.0, 6.0, -30.0)), null],
				["04_ic_mekan_kapisi", c.to_global(Vector3(-6.0, 1.7, 8.0)), c.to_global(Vector3(-22.0, 2.0, 0.0)), null],
				["05_tepeden", c.to_global(Vector3(-10.0, 140.0, -10.0)), c.to_global(Vector3(45.0, 0.0, -10.0)), null],
			]
	return super._bakislar()
