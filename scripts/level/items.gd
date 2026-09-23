class_name Items
## Garajdaki 10 eşyanın tanımları ve low-poly modelleri (GDD §8).
## Eşyalar gerçek boyutlarından biraz büyük yapılır: uzaktan okunur, komik durur.

const IDS: Array[String] = [
	"phone", "lighter", "book", "chickpeas", "powerbank",
	"tape", "thermos", "selfie", "cologne", "cube",
]

## Çanta arayüzünde eşyanın rengi.
const COLORS := {
	"phone": Color("2b2f3a"),
	"lighter": Color("d8342c"),
	"book": Color("2f5fa8"),
	"chickpeas": Color("e2b85a"),
	"powerbank": Color("1c1c1c"),
	"tape": Color("c98a3a"),
	"thermos": Color("b8322b"),
	"selfie": Color("8a8f99"),
	"cologne": Color("b9e3a8"),
	"cube": Color("f2c230"),
}


static func name_key(id: String) -> String:
	return "ITEM_" + id.to_upper()


static func comment_key(id: String) -> String:
	return "HIKMET_ITEM_" + id.to_upper()


## Eşyanın modelini kurar. Dönen düğümün kökeni eşyanın tabanıdır.
static func build(id: String) -> Node3D:
	var n := Node3D.new()
	n.name = "Item_" + id
	match id:
		"phone":
			Props.box(n, Vector3(0.16, 0.02, 0.3), Vector3(0, 0.01, 0), Color("2b2f3a"))
			Props.box(n, Vector3(0.14, 0.004, 0.26), Vector3(0, 0.022, 0), Color("7fd3ff"), Vector3.ZERO, 1.2)
		"lighter":
			Props.box(n, Vector3(0.06, 0.16, 0.03), Vector3(0, 0.08, 0), Color("d8342c"))
			Props.box(n, Vector3(0.06, 0.03, 0.032), Vector3(0, 0.175, 0), Color("c9ccd1"))
		"book":
			Props.box(n, Vector3(0.3, 0.06, 0.4), Vector3(0, 0.03, 0), Color("2f5fa8"))
			Props.box(n, Vector3(0.28, 0.05, 0.02), Vector3(0.01, 0.03, 0.195), Color("f1ead8"))
			Props.box(n, Vector3(0.302, 0.062, 0.06), Vector3(0, 0.03, -0.1), Color("e8e3d3"))
		"chickpeas":
			Props.ball(n, 0.13, Vector3(0, 0.12, 0), Color("e2b85a"), Vector3(1.0, 0.9, 0.8), 8)
			Props.cyl(n, 0.02, 0.1, Vector3(0, 0.26, 0), Color("c79a3e"), Vector3.ZERO, 6, 0.05)
			Props.box(n, Vector3(0.12, 0.05, 0.005), Vector3(0, 0.12, 0.105), Color("c0392b"))
		"powerbank":
			Props.box(n, Vector3(0.12, 0.04, 0.22), Vector3(0, 0.02, 0), Color("1c1c1c"))
			Props.box(n, Vector3(0.02, 0.005, 0.02), Vector3(0.03, 0.043, 0.08), Color("3dff6a"), Vector3.ZERO, 3.0)
		"tape":
			Props.ring(n, 0.07, 0.14, Vector3(0, 0.05, 0), Color("c98a3a"))
		"thermos":
			Props.cyl(n, 0.08, 0.4, Vector3(0, 0.2, 0), Color("b8322b"), Vector3.ZERO, 10)
			Props.cyl(n, 0.085, 0.08, Vector3(0, 0.44, 0), Color("9aa0a8"), Vector3.ZERO, 10)
		"selfie":
			Props.cyl(n, 0.015, 0.8, Vector3(0, 0.02, 0), Color("8a8f99"), Vector3(0, 0, 90), 6)
			Props.box(n, Vector3(0.05, 0.08, 0.1), Vector3(0.42, 0.03, 0), Color("2b2f3a"))
			Props.cyl(n, 0.025, 0.12, Vector3(-0.42, 0.02, 0), Color("1c1c1c"), Vector3(0, 0, 90), 6)
		"cologne":
			Props.cyl(n, 0.07, 0.26, Vector3(0, 0.13, 0), Color(0.72, 0.9, 0.66, 0.75), Vector3.ZERO, 8)
			Props.cyl(n, 0.03, 0.06, Vector3(0, 0.29, 0), Color("e3c35a"), Vector3.ZERO, 8)
			Props.box(n, Vector3(0.09, 0.08, 0.005), Vector3(0, 0.13, 0.07), Color("f7f2d8"))
		"cube":
			var faces := [Color("f2c230"), Color("2e7d32"), Color("c62828"), Color("1565c0"), Color("ffffff"), Color("ef6c00")]
			var rng := RandomNumberGenerator.new()
			rng.seed = 1453
			for x in 3:
				for y in 3:
					for z in 3:
						var c: Color = faces[rng.randi_range(0, 5)]
						Props.box(n, Vector3(0.058, 0.058, 0.058), Vector3((x - 1) * 0.062, 0.062 + y * 0.062, (z - 1) * 0.062), c)
	return n


## Eşyanın etkileşim kutusunun boyutu.
static func hit_size(id: String) -> Vector3:
	match id:
		"selfie":
			return Vector3(0.95, 0.25, 0.3)
		"thermos":
			return Vector3(0.3, 0.55, 0.3)
		"book":
			return Vector3(0.4, 0.2, 0.5)
		_:
			return Vector3(0.35, 0.35, 0.35)
