extends Node
## Bütün betikleri yükler: ayrıştırma hatası olan betiği adıyla yazar (ayrıştırılamayan bölüm oyunda açılmaz, test de
## beş dakika boyunca sessizce bekler). Autoload'lar (GameState...) yüklü olsun diye sahne olarak çalışır:
##   godot --headless --path . res://tests/parse_check.tscn   → "PARSECHECK PASS" ya da "PARSECHECK FAIL <yol>"


func _ready() -> void:
	var bad: Array = []
	var n := 0
	for dir in ["res://scripts"]:
		for path in _walk(dir):
			n += 1
			var s: Variant = load(path)
			if s == null or (s is GDScript and not (s as GDScript).can_instantiate()):
				bad.append(path)
	for b in bad:
		print("PARSECHECK FAIL ", b)
	print("PARSECHECK %s scripts=%d" % ["PASS" if bad.is_empty() else "FAIL", n])
	get_tree().quit(0 if bad.is_empty() else 1)


func _walk(dir: String) -> Array:
	var out: Array = []
	var d := DirAccess.open(dir)
	if d == null:
		return out
	for f in d.get_files():
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for sub in d.get_directories():
		out.append_array(_walk(dir.path_join(sub)))
	return out
