extends SceneTree
## CANLI sonda: kit üçgen sayıları (tür × katman) ve Bld'ye ekleme denetimi.
const CK = preload("res://scripts/world/ist/canli_kit.gd")
const K = preload("res://scripts/world/ist/ordugah_kit.gd")

func _init() -> void:
	for tur in ["okuz", "manda", "at", "katir", "esek", "deve", "koyun", "keci", "kopek", "kedi", "tavuk", "marti", "guvercin"]:
		var s := "CANLIUCGEN tur=%s" % tur
		for lod in 3:
			s += " l%d=%d" % [lod, CK.ucgen(tur, lod)]
		s += " yat0=%d" % CK.ucgen(tur, 0, {"poz": "yat"})
		print(s)
	var b := K.Bld.new("")
	b.box(Vector3.ZERO, Vector3.ONE, Color.WHITE)
	var n0 := b.v.size()
	CK.bld_ekle(b, "okuz", Vector3.ZERO, 0.0)
	print("CANLIBLD once=%d sonra=%d tris=%d" % [n0, b.v.size(), b.tris])
	quit()
