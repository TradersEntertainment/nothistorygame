extends Node
## ordugah-merkez gezi sondası: plan() öğelerinin gerçek koordinatları.
func _ready() -> void:
	var p: Array = IstOrdugah.plan()
	for it: Dictionary in p:
		var pos: Vector2 = it["pos"] if it.has("pos") else Vector2.ZERO
		var r := IstGeo.real(pos.x, pos.y)
		print("PLAN %s|%s|%s e=%.0f n=%.0f r=%s" % [it.get("kind", "?"), it.get("id", "?"), it.get("ad", "?"), r.x, r.y, str(it.get("r", ""))])
	get_tree().quit(0)
