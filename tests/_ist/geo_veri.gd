extends SceneTree
## Python üreticisinin (tests/_ist/geo_veri_*.py) ham çıktısını Godot kaynağına çevirir:
##   godot --headless --path . -s res://tests/_ist/geo_veri.gd -- KLASÖR   (KLASÖR/h.bin float32, KLASÖR/reg.bin uint8)
func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var dir: String = args[0] if args.size() > 0 else "."
	var hb := FileAccess.get_file_as_bytes(dir.path_join("h.bin"))
	var bb := FileAccess.get_file_as_bytes(dir.path_join("reg.bin"))
	if hb.size() != 1201 * 1001 * 4 or bb.size() != 1201 * 1001:
		print("GEOVERI HATA boyut ", hb.size(), " ", bb.size())
		quit(1)
		return
	var ih := Image.create_from_data(1201, 1001, false, Image.FORMAT_RF, hb)
	var ib := Image.create_from_data(1201, 1001, false, Image.FORMAT_L8, bb)
	var e1 := ResourceSaver.save(ih, "res://assets/ist2/arazi_h.res", ResourceSaver.FLAG_COMPRESS)
	var e2 := ResourceSaver.save(ib, "res://assets/ist2/arazi_b.res", ResourceSaver.FLAG_COMPRESS)
	print("GEOVERI kaydedildi ", e1, " ", e2)
	quit(0)
