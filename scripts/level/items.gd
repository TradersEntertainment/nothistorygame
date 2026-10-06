class_name Items
## Garajdaki 10 eşyanın tanımları ve low-poly modelleri (GDD §8).
## Eşyalar gerçek boyutlarından biraz büyük yapılır: uzaktan okunur, komik durur.

const IDS: Array[String] = [
	"phone", "lighter", "book", "chickpeas", "powerbank",
	"tape", "thermos", "selfie", "cologne", "cube",
]

## Cepteki 1453 eşyaları (çantanın beş gözüne girmez, docs/BRANCHING_V2.md §2.3): Haliç'te bulunan yedek fes,
## Theodoros'un Misafir İzni, Sultan'ın tezkiresi.
const POCKET_IDS: Array[String] = ["spare_fez", "guest_pass", "tezkire"]

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
			# Ucundaki kutu Hikmet'in koli bandıyla tutturduğu eski bir kamera: objektif ve iki bant şeridi
			Props.cyl(n, 0.022, 0.03, Vector3(0.42, 0.04, -0.062), Color("1c1c1c"), Vector3(90, 0, 0), 12)
			Props.cyl(n, 0.016, 0.004, Vector3(0.42, 0.04, -0.078), Color("4a6a8a"), Vector3(90, 0, 0), 12, -1.0, 0.5)
			for bz in [-0.03, 0.03]:
				Props.box(n, Vector3(0.056, 0.086, 0.014), Vector3(0.42, 0.03, bz), Color("c98a3a"))
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
		# Cep eşyaları. Kâğıtlar dik durur (yüzü +Z): elde tutulunca okunur
		"spare_fez":
			Props.cyl(n, 0.11, 0.14, Vector3(0, 0.07, 0), Color("b3262d"), Vector3.ZERO, 10, 0.085)
			Props.cyl(n, 0.014, 0.012, Vector3(0, 0.146, 0), Color("1a1a1a"), Vector3.ZERO, 6)
			Props.cyl(n, 0.006, 0.1, Vector3(0.05, 0.115, 0.0), Color("1a1a1a"), Vector3(0, 0, -40), 4)
		"guest_pass":
			# Theodoros'un tek mühürlü izni: parşömen, üç satır Rumca, sağ altta kırmızı balmumu mühür
			Props.box(n, Vector3(0.15, 0.1, 0.004), Vector3(0, 0.05, 0), Color("ead9b0"))
			for k in 3:
				Props.box(n, Vector3(0.1 - k * 0.02, 0.006, 0.001), Vector3(-0.015 - k * 0.01, 0.08 - k * 0.018, 0.0025), Color("5a4a3a"))
			Props.cyl(n, 0.017, 0.006, Vector3(0.045, 0.025, 0.004), Color("a8182a"), Vector3(90, 0, 0), 12)
		"tezkire":
			# Sultan'ın tezkiresi: uzun kâğıt, başında altın tuğra (iki ilmek, üç dikey çizgi), altında satırlar ve mühür
			Props.box(n, Vector3(0.11, 0.19, 0.004), Vector3(0, 0.095, 0), Color("f2e8d0"))
			var gold := Color("c8a040")
			Props.ring(n, 0.011, 0.019, Vector3(-0.022, 0.155, 0.003), gold, Vector3(90, 0, 0))
			Props.ring(n, 0.007, 0.013, Vector3(-0.022, 0.155, 0.003), gold, Vector3(90, 0, 0))
			for k in 3:
				Props.box(n, Vector3(0.003, 0.04, 0.001), Vector3(0.0 + k * 0.009, 0.165, 0.003), gold)
			Props.box(n, Vector3(0.05, 0.003, 0.001), Vector3(0.012, 0.142, 0.003), gold)
			for k in 4:
				Props.box(n, Vector3(0.08, 0.004, 0.001), Vector3(0, 0.11 - k * 0.016, 0.003), Color("3a3028"))
			Props.cyl(n, 0.013, 0.005, Vector3(0.03, 0.03, 0.004), Color("8a1a20"), Vector3(90, 0, 0), 12)
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


## Açık lise tarih kitabı (Bölüm 12 ve fragman: Fatih'in sorusunda Tolga kitabı karıştırır). Sırt yerel Z ekseninde,
## sayfalar +Y'ye bakar. "Flip" düğümü sırt çevresinde döndürülünce bir sayfa soldan sağa çevrilir (flip_pages).
static func open_book() -> Node3D:
	var n := Node3D.new()
	var cover := Color("2f5fa8")
	for sx: float in [-1.0, 1.0]:
		Props.box(n, Vector3(0.2, 0.008, 0.27), Vector3(sx * 0.1, 0.0, 0), cover, Vector3(0, 0, sx * -4.0))
		Props.box(n, Vector3(0.19, 0.022, 0.26), Vector3(sx * 0.097, 0.014, 0), Color("f1ead8"), Vector3(0, 0, sx * -4.0))
		# Satırlar ve bir resim (fetih gravürü) sayfada
		for k in 9:
			Props.box(n, Vector3(0.14 - (k % 3) * 0.02, 0.001, 0.006), Vector3(sx * 0.1, 0.027, -0.1 + k * 0.022), Color("5a5048"))
	Props.box(n, Vector3(0.07, 0.001, 0.06), Vector3(0.1, 0.028, 0.085), Color("8a6a4a"))
	Props.box(n, Vector3(0.012, 0.03, 0.27), Vector3(0, 0.0, 0), cover.darkened(0.3))
	var flip := Node3D.new()
	flip.name = "Flip"
	n.add_child(flip)
	flip.position = Vector3(0, 0.03, 0)
	Props.box(flip, Vector3(0.185, 0.003, 0.255), Vector3(-0.094, 0, 0), Color("f7f1e2"))
	Props.strip_outlines(n)
	return n


## Kitabın sayfalarını hızla çevirir (count sayfa, her biri dur saniye): Flip sayfası soldan sağa döner.
static func flip_pages(book: Node3D, count: int, dur := 0.32) -> void:
	var flip := book.get_node_or_null("Flip") as Node3D
	if flip == null:
		return
	var tw := book.create_tween()
	for k in count:
		tw.tween_callback(func(): flip.rotation.z = 0.0)
		tw.tween_property(flip, "rotation:z", -PI, dur).set_trans(Tween.TRANS_SINE)
		tw.tween_interval(0.12 if k % 3 != 2 else 0.45)


## Büro'nun tespit makinesi (Z-0): anlık baskılı, krem gövde, siyah deri kuşak, objektif, flaş penceresi, kırmızı
## deklanşör, altta baskı yuvası. Objektif -Z'ye bakar, vizör arkada; gerçek boyda (16 x 10 x 8,5 cm).
## Nihat Büro'da verir (Bölüm 17 önsözü), tespit karelerinde elde durur (Player.camera_hold).
static func bureau_camera() -> Node3D:
	var n := Node3D.new()
	n.name = "BureauCamera"
	Props.box(n, Vector3(0.16, 0.105, 0.085), Vector3.ZERO, Color("e9dfc6"))
	Props.box(n, Vector3(0.162, 0.046, 0.087), Vector3(0, -0.014, 0), Color("2a2622"))
	Props.box(n, Vector3(0.15, 0.012, 0.075), Vector3(0, 0.058, 0.002), Color("cfc5ad"))
	# Vizör (üstte, arkaya açılır) ve gözlük camı
	Props.box(n, Vector3(0.036, 0.026, 0.032), Vector3(-0.045, 0.072, 0.03), Color("2a2622"))
	Props.box(n, Vector3(0.024, 0.015, 0.004), Vector3(-0.045, 0.073, 0.047), Color("6f9fc4"), Vector3.ZERO, 0.4)
	# Objektif: siyah halka, mavi cam, cam üstünde parlama
	Props.cyl(n, 0.034, 0.03, Vector3(0.012, -0.008, -0.055), Color("1c1c1c"), Vector3(90, 0, 0), 18)
	Props.cyl(n, 0.025, 0.006, Vector3(0.012, -0.008, -0.071), Color("3d5a78"), Vector3(90, 0, 0), 18, -1.0, 0.6)
	Props.cyl(n, 0.009, 0.002, Vector3(0.004, 0.0, -0.0745), Color("dcecff"), Vector3(90, 0, 0), 10, -1.0, 1.4)
	# Flaş penceresi (önde, üst köşe)
	var flash := Props.box(n, Vector3(0.05, 0.022, 0.006), Vector3(-0.042, 0.03, -0.0445), Color("f4f1ea"), Vector3.ZERO, 0.25)
	flash.name = "Flash"
	# Deklanşör (üstte sağ)
	Props.cyl(n, 0.009, 0.01, Vector3(0.055, 0.068, -0.015), Color("c8262e"), Vector3.ZERO, 10)
	# Baskı yuvası (önde altta) ve yazılar
	Props.box(n, Vector3(0.11, 0.005, 0.004), Vector3(0, -0.048, -0.0445), Color("111111"))
	Props.label(n, "Z-0", Vector3(0.05, 0.031, -0.0436), 28, Color("8a2b22"), Vector3(0, 180, 0), 0.03)
	Props.label(n, "ZAMAN BÜROSU", Vector3(0.0, -0.016, -0.0436), 18, Color("e9dfc6"), Vector3(0, 180, 0), 0.075)
	Props.label(n, "Z-0 · TESPİT", Vector3(0.02, 0.031, 0.0436), 18, Color("6a5230"), Vector3.ZERO, 0.06)
	return n


## Makineden çıkan baskı: beyaz çerçeveli kare, ortası koyu (henüz banyo olmamış film).
static func camera_print() -> Node3D:
	var n := Node3D.new()
	n.name = "CameraPrint"
	Props.box(n, Vector3(0.088, 0.002, 0.106), Vector3.ZERO, Color("f4f1ea"))
	Props.box(n, Vector3(0.076, 0.0025, 0.076), Vector3(0, 0, -0.008), Color("3a3530"))
	return n

