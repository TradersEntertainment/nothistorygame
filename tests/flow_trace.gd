class_name FlowTrace
extends Node
## --flowtrace (PACE ile, başsız): oyuncunun gözünden akış dökümü. Her değişiklik bir satır (FLOW t=oyun_sn ...):
##   SCENE ad                bölüm değişti
##   FREE / FROZEN           oyuncu hareket edebiliyor / edemiyor (player.frozen)
##   OBJ metin               hedef kutusu değişti (boş: hedef yok)
##   PROMPT metin            etkileşim istemi ("E: ...")
##   QTE metin, CONTROLS metin   ortadaki ipucu, kontrol satırı
##   LINE anahtar | metin    replik ya da ayak üstü söz gösterildi
##   CHOICE a / b / c        karar seçenekleri açıldı
##   BLACK on/off            ekran karardı / açıldı
## Sonunda FLOWSUM: sahne başına toplam süre, oyuncunun donuk kaldığı süre, en uzun kesintisiz donuk dilim, replik sayısı.
## Kimin için: "ilk 15 dakikada oyuncu ne kadar izliyor, ne kadar oynuyor, ne yapacağı söyleniyor mu" incelemesi.
## Test botu yürümez (ışınlanır): serbest dolaşma süreleri gerçek oyuncununkinden kısadır; donuk süreler gerçektir.

var _t := 0.0
var _scene := ""
var _hud: Node
var _last := {}
var _frozen_since := -1.0
var _sum := {}


func _init() -> void:
	name = "FlowTrace"
	process_mode = Node.PROCESS_MODE_ALWAYS


func _out(kind: String, text := "") -> void:
	print("FLOW t=%6.1f %s %s" % [_t, kind, text.replace("\n", " ⏎ ")])


func _s() -> Dictionary:
	if not _sum.has(_scene):
		_sum[_scene] = {"total": 0.0, "frozen": 0.0, "longest": 0.0, "lines": 0, "order": _sum.size()}
	return _sum[_scene]


func _process(delta: float) -> void:
	var tree := get_tree()
	var sc := tree.current_scene
	var sname := sc.scene_file_path.get_file().get_basename() if sc else ""
	if sname != _scene:
		_close_frozen()
		_scene = sname
		_t = 0.0
		_last.clear()
		_hud = null
		_out("SCENE", sname)
	if sc == null or tree.paused:
		return
	_t += delta
	_s()["total"] += delta
	var hud := tree.get_first_node_in_group("hud")
	if hud != _hud and hud != null:
		_hud = hud
		if hud.has_signal("line_shown") and not hud.is_connected("line_shown", _on_line):
			hud.connect("line_shown", _on_line)
	var pl := tree.get_first_node_in_group("player")
	if pl:
		var fr := bool(pl.get("frozen"))
		if _last.get("frozen") != fr:
			_last["frozen"] = fr
			_out("FROZEN" if fr else "FREE")
			if fr:
				_frozen_since = _t
			else:
				_close_frozen()
		if fr:
			_s()["frozen"] += delta
	if hud == null:
		return
	_label(hud, "_objective", "OBJ", "_objective_box")
	_label(hud, "_prompt", "PROMPT")
	_label(hud, "_qte", "QTE")
	_label(hud, "_controls", "CONTROLS")
	var cb = hud.get("_choice_box")
	var copen: bool = cb is Control and (cb as Control).visible and (cb as Control).get_child_count() > 0
	if _last.get("choice", false) != copen:
		_last["choice"] = copen
		if copen:
			var opts: Array = []
			for c in (cb as Control).get_children():
				var tx = c.get("text")
				if tx is String and tx != "":
					opts.append(tx)
			_out("CHOICE", " / ".join(opts))
	var fade = hud.get("_fade")
	var black: bool = fade is ColorRect and (fade as ColorRect).visible and (fade as ColorRect).color.a > 0.9
	if _last.get("black", false) != black:
		_last["black"] = black
		_out("BLACK", "on" if black else "off")


func _label(hud: Node, prop: String, kind: String, box_prop := "") -> void:
	var l = hud.get(prop)
	if not (l is Label):
		return
	var box = hud.get(box_prop) if box_prop != "" else l
	var vis: bool = (l as Label).is_visible_in_tree() and (not (box is CanvasItem) or (box as CanvasItem).is_visible_in_tree())
	var tx: String = (l as Label).text if vis else ""
	if str(_last.get(prop, "")) != tx:
		_last[prop] = tx
		_out(kind, tx if tx != "" else "(yok)")


func _on_line(key: String) -> void:
	_s()["lines"] += 1
	_out("LINE", "%s | %s" % [key, tr(key)])


func _close_frozen() -> void:
	if _frozen_since >= 0.0 and _scene != "":
		var d := _t - _frozen_since
		_s()["longest"] = maxf(float(_s()["longest"]), d)
	_frozen_since = -1.0


func _exit_tree() -> void:
	_close_frozen()
	var keys := _sum.keys()
	keys.sort_custom(func(a, b): return int(_sum[a]["order"]) < int(_sum[b]["order"]))
	for k in keys:
		var s: Dictionary = _sum[k]
		if float(s["total"]) < 1.0:
			continue
		print("FLOWSUM scene=%s total=%.0fs frozen=%.0fs (%.0f%%) longest_frozen=%.0fs lines=%d" % [k, s["total"], s["frozen"],
			100.0 * float(s["frozen"]) / maxf(1.0, float(s["total"])), s["longest"], s["lines"]])
