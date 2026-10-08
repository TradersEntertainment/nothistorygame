class_name ObjectiveMarker
extends Control

## Hedef işaretçisi: hedefin ekrandaki yerinde altın bir baklava ve uzaklık ("12 m").
## Hedef ekranın dışında ya da arkadaysa kenara yapışır ve hedefi gösteren bir oka döner.
## Hedef: Node3D (yerinden izlenir) ya da Vector3. Yakına gelince (HIDE_NEAR) kaybolur.
## Seçimli görevlerde (teklifler, iki yol) her seçenek kendi renginde ayrı bir işaret alır (`choices`): ekrandaysa renkli
## baklava ve adı, dışındaysa kenarda renkli ok; kenarda üst üste binenler yana kayar. Hepsi aynı anda görünür.

## Hedeften bu kadar uzaktaysa uzaklık yazısına "görev geride" eklenir
const FAR_HINT := 250.0
const GOLD := Color("ffd24a")
const EDGE := 46.0
const HIDE_NEAR := 4.0   # hedefe bu kadar yakınken (m) işaret gizlenir: yüzlere binmesin
## Seçenek renkleri (altın ana hedefe ayrılmış): birbirinden ve altından ayırt edilir
const CHOICE_COLORS := [Color("4ad8ff"), Color("ff6ad5"), Color("7dff6a"), Color("ff9a3a"), Color("b48aff"), Color("ff5a5a"), Color("f2f2f2")]

var target: Variant = null          # Node3D | Vector3 | Callable (-> Node3D/Vector3/null) | null
## Bu kadar yakında gizlenir; bölüm küçültebilir (34o: kaçışan kalabalıkta hedef insanlar yakında da görünsün)
var hide_near := HIDE_NEAR
var height := 1.6                   # Node3D hedeflerde baklavanın yerden yüksekliği
var _screen := Vector2.ZERO
var _arrow := false
var _angle := 0.0
var _dist := 0.0
var _font: Font
## Seçenekler: [{"target": Node3D|Vector3|Callable, "label": String, "color": Color, "h": float}]
var choices: Array = []
var main_label := ""                # seçenekler varken altın ana hedefin adı (ör. "Otağ Kapısı")
var _items: Array = []              # bu karede çizilecekler: {screen, arrow, angle, dist, color, label}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = ThemeDB.fallback_font


func set_target(t: Variant, h := 1.6) -> void:
	target = t
	height = h
	queue_redraw()


## Seçenekleri ver: [[hedef, ad], ...] ya da [[hedef, ad, yükseklik], ...]; renkler sırayla. Boş dizi: seçenek yok.
## Döner: her seçeneğin rengi (HUD'daki açıklama satırı için).
func set_choices(list: Array) -> Array:
	choices.clear()
	var cols: Array = []
	for i in list.size():
		var it: Array = list[i]
		var c: Color = CHOICE_COLORS[i % CHOICE_COLORS.size()]
		# İşaretin üstünde kısa ad ("Kadri: Ziyafet" → "Kadri"); tamamı hedef kutusunun altındaki satırda
		choices.append({"target": it[0], "label": str(it[1]).split(":")[0].strip_edges(), "color": c, "h": float(it[2]) if it.size() > 2 else 1.6})
		cols.append(c)
	queue_redraw()
	return cols


## Hedefin dünyadaki yeri (mini harita ve büyük harita): Vector3 ya da null
func target_position() -> Variant:
	return _world_pos()


## Seçeneklerin dünyadaki yerleri ve renkleri (haritalar da aynı renkle işaretler): [[Vector3, Color], ...]
func choice_positions() -> Array:
	var out: Array = []
	if not GameState.settings.get("markers", true):
		return out
	for c: Dictionary in choices:
		var p = _pos_of(c["target"], c["h"])
		if p is Vector3:
			out.append([p, c["color"]])
	return out


func _world_pos() -> Variant:
	return _pos_of(target, height)


static func _pos_of(target: Variant, height: float) -> Variant:
	# Silinmiş hedef düğüm: "is" sınaması bile hata verir (mini harita bunu _update'in null denetimi olmadan sorar)
	if typeof(target) == TYPE_OBJECT and not is_instance_valid(target):
		return null
	if target is Callable:
		# Değişen hedef (ör. en yakın kalan ipucu): her karede sorulur; Node3D, Vector3 ya da null döner
		var r = (target as Callable).call() if (target as Callable).is_valid() else null
		if typeof(r) == TYPE_OBJECT and not is_instance_valid(r):
			return null
		if r is Node3D:
			return (r as Node3D).global_position + Vector3(0, height, 0) if is_instance_valid(r) and (r as Node3D).is_inside_tree() else null
		return r
	if target is Node3D:
		if not is_instance_valid(target) or not (target as Node3D).is_inside_tree():
			return null
		return (target as Node3D).global_position + Vector3(0, height, 0)
	if target is Vector3:
		return target
	return null


func _process(_delta: float) -> void:
	var was := visible
	visible = _update()
	if visible or was:
		queue_redraw()


func _update() -> bool:
	_items.clear()
	if not GameState.settings.get("markers", true) or (target == null and choices.is_empty()):
		return false
	var hud := get_parent() as Hud
	# Konuşma sırasında da gizli: işaret konuşanın yüzüne binmesin. Ayak üstü sözlerde (bark) oyuncu yürürken görünür kalır:
	# görev sırasında sık sık söz söylenen yerlerde (34o kalabalığı) işaret durmadan kaybolup beliriyordu.
	if hud and (hud.cinematic or hud.is_faded() or (hud.is_talking() and _in_dialogue(hud))):
		return false
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return false
	var main := _item(cam, _world_pos(), GOLD, main_label if not choices.is_empty() else "")
	if main:
		_items.append(main)
		_screen = main["screen"]
		_arrow = main["arrow"]
		_angle = main["angle"]
		_dist = main["dist"]
	for c: Dictionary in choices:
		var it := _item(cam, _pos_of(c["target"], c["h"]), c["color"], c["label"])
		if it:
			_items.append(it)
	_spread()
	return not _items.is_empty()


func _in_dialogue(hud: Hud) -> bool:
	if hud.line_open:
		return true
	var p := get_tree().get_first_node_in_group("player") as Player
	return p == null or p.frozen


## Bir hedefin ekrandaki yeri; ekranın dışındaysa (ya da arkadaysa) kenardaki ok yeri
func _item(cam: Camera3D, p: Variant, col: Color, label: String) -> Dictionary:
	if p == null:
		return {}
	var pos: Vector3 = p
	var flat := Vector2(pos.x - cam.global_position.x, pos.z - cam.global_position.z).length()
	if flat < hide_near:
		return {}
	var size := get_viewport_rect().size
	var center := size / 2.0
	var behind := cam.is_position_behind(pos)
	var sp := cam.unproject_position(pos)
	if behind:
		sp = center - (sp - center) * 1000.0
	var inner := Rect2(Vector2(EDGE, EDGE), size - Vector2(EDGE, EDGE) * 2.0)
	var arrow := behind or not inner.has_point(sp)
	var ang := 0.0
	if arrow:
		var d := sp - center
		if d.length() < 1.0:
			d = Vector2(0, 1)
		# Kenardaki kesişim noktası
		var k := minf(absf((inner.size.x / 2.0) / d.x) if d.x != 0.0 else INF,
			absf((inner.size.y / 2.0) / d.y) if d.y != 0.0 else INF)
		sp = center + d * k
		ang = d.angle()
	return {"screen": sp, "arrow": arrow, "angle": ang, "dist": cam.global_position.distance_to(pos), "color": col, "label": label}


## Kenarda (ya da ekranda) üst üste binen işaretler (yazılarıyla birlikte) kayar: her renk ayrı okunsun. Ekranda ve
## yan kenarlarda alt alta, üst/alt kenarda yan yana.
func _spread() -> void:
	var size := get_viewport_rect().size
	for i in _items.size():
		for _pass in 8:
			var moved := false
			for j in i:
				var a: Vector2 = _items[i]["screen"]
				var b: Vector2 = _items[j]["screen"]
				if absf(a.x - b.x) < 150.0 and absf(a.y - b.y) < 48.0:
					var top_edge: bool = _items[i]["arrow"] and (a.y <= EDGE + 1.0 or a.y >= size.y - EDGE - 1.0)
					var step := Vector2(160, 0) if top_edge else Vector2(0, 52)
					if (a - b).dot(step) < 0.0:
						step = -step
					a = b + step
					a.x = clampf(a.x, EDGE, size.x - EDGE)
					a.y = clampf(a.y, EDGE, size.y - EDGE)
					_items[i]["screen"] = a
					moved = true
			if not moved:
				break


func _draw() -> void:
	if not visible:
		return
	for it: Dictionary in _items:
		_draw_item(it)


func _draw_item(it: Dictionary) -> void:
	var c: Color = it["color"]
	var sc: Vector2 = it["screen"]
	var ang: float = it["angle"]
	var shadow := Color(0, 0, 0, 0.55)
	if it["arrow"]:
		var pts := PackedVector2Array([Vector2(16, 0), Vector2(-9, -11), Vector2(-4, 0), Vector2(-9, 11)])
		var big := Transform2D(ang, Vector2(1.3, 1.3), 0.0, sc)
		draw_colored_polygon(big * pts, shadow)
		draw_colored_polygon(big * PackedVector2Array([Vector2(14, 0), Vector2(-8, -9), Vector2(-3, 0), Vector2(-8, 9)]), c)
	else:
		var r := 13.0
		var dia := PackedVector2Array([sc + Vector2(0, -r), sc + Vector2(r * 0.72, 0), sc + Vector2(0, r), sc + Vector2(-r * 0.72, 0)])
		var big := PackedVector2Array()
		for q in dia:
			big.append(sc + (q - sc) * 1.35)
		draw_colored_polygon(big, shadow)
		draw_colored_polygon(dia, c)
	var dist: float = it["dist"]
	var txt := "%d m" % int(round(dist))
	if it["label"] != "":
		txt = "%s · %s" % [it["label"], txt]
	# Her yer yürünür: görevden çok uzaklaşan oyuncuya yön hatırlatması (ceza yok)
	elif dist > FAR_HINT:
		txt += "  · " + tr("UI_MARKER_FAR")
	var fs := 18 if it["label"] == "" else 16
	var w := _font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var tp := sc + Vector2(-w / 2.0, 36.0)
	if it["arrow"]:
		tp = sc - Vector2.from_angle(ang) * 40.0 + Vector2(-w / 2.0, 6.0)
	# Yazı ekranın kenarında kesilmesin (kenara yapışan okta uzun "görev geride" ipucu)
	var vw := get_viewport_rect().size.x
	tp.x = clampf(tp.x, 12.0, vw - w - 12.0)
	draw_string_outline(_font, tp, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 5, Color(0, 0, 0, 0.75))
	draw_string(_font, tp, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, c)

