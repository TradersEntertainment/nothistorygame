class_name Rig
extends RefCounted
## Yordamsal karakter animasyonu (Person, Hikmet, Soldier ortak).
## Yürüme hızı konumun kareler arası değişiminden ölçülür: tween'le taşınan (uçan, yürütülen) karakterler
## de kendiliğinden yürür. Boşta nefes, bakınma, göz kırpma; konuşurken baş sallama ve kol jestleri.
## emote() tepki animasyonlarını oynatır; o sırada ve lock > 0 iken uzuvlara dokunulmaz.

var owner: Node3D
var body: Node3D
var head: Node3D
var arm_l: Node3D
var arm_r: Node3D
var leg_l: Node3D
var leg_r: Node3D
var knee_l: Node3D        # isteğe bağlı eklemler (CharKit): diz ve dirsek
var knee_r: Node3D
var elbow_l: Node3D
var elbow_r: Node3D
var eyes: Node3D          # isteğe bağlı: göz kırpma
var brows: Node3D         # isteğe bağlı: kaş
var arm_rest_z := 0.1     # kolların gövdeden açıklığı (dinlenme)
var lock := 0
var speed := 0.0
## Sürekli iş hareketi: "" (yok), "sit" (tabureye), "sit_ground" (yere bağdaş), "stir" (kazan karıştırır),
## "hammer" (çekiç), "chop" (doğrar), "write" (yere oturmuş yazar), "paint" (fırça), "carry" (önünde yük; yürürken de).
## Konuşurken el işleri durur (oturuşlar sürer), konuşma bitince devam eder.
var activity := ""

var _t := 0.0
var _last_pos := Vector3.INF
var _walk_phase := 0.0
var _blink_t := 2.0
var _look_t := 1.0
var _look_yaw := 0.0
var _look_pitch := 0.0
var _gesture_t := 0.0
var _gesture := Vector4.ZERO      # sağ kol x, sağ kol z, sol kol x, sol kol z
var _brow_y0 := 0.0
## Yüz ifadesi (konuşulan repliğe göre, bkz. mood_of): "", "happy", "angry", "surprised", "sad", "worried", "skeptic".
var mood := ""
var mouth_x := 1.0        # ağız genişliği çarpanı (gülümseme geniş, üzgün/şaşkın dar); Person/Hikmet/Soldier okur
var _m_brow := 0.0
var _m_roll := 0.0
var _m_eye := 1.0
const MOODS := {
	# [kaş yüksekliği, kaş eğimi (bir kaş kalkık), göz açıklığı, ağız genişliği]
	"": [0.0, 0.0, 1.0, 1.0],
	"happy": [0.012, 0.0, 0.72, 1.4],
	"angry": [-0.024, 0.0, 0.7, 1.1],
	"surprised": [0.038, 0.0, 1.3, 0.75],
	"sad": [0.018, 0.0, 0.8, 0.75],
	"worried": [0.026, 0.0, 1.12, 0.85],
	"skeptic": [0.008, 0.2, 0.85, 0.9],
}
const _STERN := ["SPK_FATIH", "SPK_URBAN", "SPK_KADRI", "SPK_AGA", "SPK_SOLDIER", "SPK_MUFIDE", "SPK_CANDARLI", "SPK_MANAGER"]


func _init(p_owner: Node3D, parts: Dictionary) -> void:
	owner = p_owner
	body = parts.get("body")
	head = parts.get("head")
	arm_l = parts.get("arm_l")
	arm_r = parts.get("arm_r")
	leg_l = parts.get("leg_l")
	leg_r = parts.get("leg_r")
	knee_l = parts.get("knee_l")
	knee_r = parts.get("knee_r")
	elbow_l = parts.get("elbow_l")
	elbow_r = parts.get("elbow_r")
	eyes = parts.get("eyes")
	brows = parts.get("brows")
	arm_rest_z = parts.get("arm_rest_z", 0.1)
	if brows:
		_brow_y0 = brows.position.y
	_t = randf() * 10.0
	_blink_t = randf_range(0.5, 4.0)


## Replikten yüz ifadesi: önce sahne notu ("(Gülerek)", "(Sinirle)"...), sonra noktalama ve kim konuştuğu.
## Tolga'nın varsayılanı gergin/endişeli (sesi öyle), sert karakterler ünlemde kızgın görünür.
static func mood_of(speaker_key: String, text: String) -> String:
	var notes := ""
	for m in RegEx.create_from_string("\\(([^)]*)\\)").search_all(text):
		notes += m.get_string(1).to_lower() + " "
	var body := RegEx.create_from_string("\\([^)]*\\)|\\[[^\\]]*\\]").sub(text, "", true).strip_edges()
	var low := body.to_lower()
	for pair in [["happy", ["gül", "sırıt", "keyif", "sevin", "neşe", "laugh", "grin", "smil", "chuckl"]],
			["angry", ["kız", "sinir", "öfke", "bağır", "hiddet", "haykır", "angr", "furious", "shout", "yell", "snap"]],
			["surprised", ["şaşır", "şaşkın", "irkil", "dehşet", "panik", "korku", "shock", "surpris", "panic", "startl", "horrif"]],
			["sad", ["üzgün", "iç çek", "gözleri dol", "hüzün", "boynu", "sad", "sigh", "tear", "gloom"]],
			["skeptic", ["şüphe", "kaşını", "süz", "suspic", "eyebrow", "doubt", "squint"]]]:
		for w in pair[1]:
			var at := notes.find(w)
			if at < 0:
				continue
			# Olumsuz fiil sayılmaz: "(gülümsemez)", "(kızmadan)"
			var end := notes.find(" ", at)
			var word := notes.substr(at, (end if end >= 0 else notes.length()) - at).rstrip(",.;")
			if word.ends_with("mez") or word.ends_with("maz") or word.ends_with("meden") or word.ends_with("madan") or " not " in notes:
				continue
			return pair[0]
	for w in ["harika", "mükemmel", "süper", "bravo", "haha", "ahaha", "yaşasın", "great", "wonderful", "perfect", "hooray"]:
		if w in low:
			return "happy"
	var stern := speaker_key in _STERN
	if "?!" in body or "!?" in body:
		return "angry" if stern else "surprised"
	if "!" in body:
		if stern:
			return "angry"
		return "surprised" if body.length() < 45 else "happy"
	if "…" in body or "..." in body:
		return "skeptic" if stern else "worried"
	if "?" in body:
		return "skeptic" if stern or speaker_key == "SPK_NIHAT" else "worried"
	if speaker_key == "SPK_TOLGA":
		return "worried"
	return ""


func update(delta: float, talking: bool, busy: bool) -> void:
	_t += delta
	var k := clampf(delta * 8.0, 0.0, 1.0)
	var gp := owner.global_position
	if _last_pos != Vector3.INF and delta > 0.0:
		var dist := Vector2(gp.x - _last_pos.x, gp.z - _last_pos.z).length()
		if dist < 2.0:   # daha büyük sıçrama ışınlanmadır, yürüme sayılmaz
			speed = lerpf(speed, minf(dist / delta, 8.0), clampf(delta * 6.0, 0.0, 1.0))
	_last_pos = gp
	# Göz kırpma
	if eyes:
		_blink_t -= delta
		if _blink_t <= 0.0:
			_blink_t = randf_range(2.2, 5.5)
			eyes.scale.y = 0.12
		elif eyes.scale.y < _m_eye:
			eyes.scale.y = minf(_m_eye, eyes.scale.y + delta * 9.0)
		else:
			eyes.scale.y = lerpf(eyes.scale.y, _m_eye, clampf(delta * 6.0, 0.0, 1.0))
	# İfade: hedefe yumuşakça geçer; replik bitince (mood "") nötre döner
	var mt: Array = MOODS.get(mood, MOODS[""])
	var km := clampf(delta * 5.0, 0.0, 1.0)
	_m_brow = lerpf(_m_brow, mt[0], km)
	_m_roll = lerpf(_m_roll, mt[1], km)
	_m_eye = lerpf(_m_eye, mt[2], km)
	mouth_x = lerpf(mouth_x, mt[3], km)
	if brows and lock == 0:
		var by := 0.012 * absf(sin(_t * 2.3)) if talking else 0.0
		brows.position.y = lerpf(brows.position.y, _brow_y0 + by + _m_brow, k)
		brows.rotation.z = _m_roll
	if lock > 0 or busy:
		return
	if speed > 0.35:
		_walk_phase += delta * (3.0 + speed * 1.6)
		var amp := clampf(speed / 3.0, 0.35, 1.0)
		var run := clampf((speed - 3.2) / 2.0, 0.0, 1.0)
		var sw := sin(_walk_phase)
		if leg_l:
			leg_l.rotation.x = sw * (0.55 + run * 0.2) * amp
			leg_l.rotation.z = lerpf(leg_l.rotation.z, 0.0, k)
		if leg_r:
			leg_r.rotation.x = -sw * (0.55 + run * 0.2) * amp
			leg_r.rotation.z = lerpf(leg_r.rotation.z, 0.0, k)
		# Diz: bacak öne salınırken bükülür, basarken düzleşir (koşuda daha çok)
		_knee(knee_l, (0.12 + maxf(0.0, sin(_walk_phase - 1.3)) * (0.75 + run * 0.7)) * amp)
		_knee(knee_r, (0.12 + maxf(0.0, sin(_walk_phase - 1.3 + PI)) * (0.75 + run * 0.7)) * amp)
		if arm_l:
			arm_l.rotation.x = -sw * (0.45 + run * 0.25) * amp
			arm_l.rotation.z = lerpf(arm_l.rotation.z, -arm_rest_z - 0.02, k)
		if arm_r:
			arm_r.rotation.x = sw * (0.45 + run * 0.25) * amp
			arm_r.rotation.z = lerpf(arm_r.rotation.z, arm_rest_z + 0.02, k)
		# Dirsek: yürürken hafif, koşarken belirgin bükük; öne salınan kol biraz daha bükülür
		_elbow(elbow_l, -(0.25 + run * 1.0 + maxf(0.0, -sw) * 0.25) * amp, k)
		_elbow(elbow_r, -(0.25 + run * 1.0 + maxf(0.0, sw) * 0.25) * amp, k)
		# Adımda iki kez inip kalkma, kalça yalpası, koşuda öne eğilme; baş sarsıntıyı dengeler
		body.position.y = (absf(sw) * 0.035 - 0.012 * run) * amp
		body.rotation.x = lerpf(body.rotation.x, (0.06 + run * 0.14) * amp, k)
		body.rotation.z = lerpf(body.rotation.z, sw * 0.035 * amp, k)
		if head:
			head.rotation = head.rotation.lerp(Vector3(-0.04 * run - absf(sw) * 0.03, 0, -sw * 0.03), k)
		if activity == "carry" and arm_l and arm_r:
			arm_r.rotation = arm_r.rotation.lerp(Vector3(-0.55, 0, 0.18), k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.55, 0, -0.18), k)
			_elbow(elbow_l, -1.1, k)
			_elbow(elbow_r, -1.1, k)
		return
	if activity != "" and _activity(delta, talking, k):
		return
	# Durunca bacaklar toplanır, beden dikleşir; nefes (oturanlarda oturuş korunur)
	if not activity in ["sit", "sit_ground", "write"]:
		# Ağırlık aktarma: yavaşça bir bacağa yüklenir, öbür diz hafif bükülür
		var shift := sin(_t * 0.45)
		if leg_l:
			leg_l.rotation.x = lerpf(leg_l.rotation.x, 0.0, k)
			leg_l.rotation.z = lerpf(leg_l.rotation.z, 0.0, k)
		if leg_r:
			leg_r.rotation.x = lerpf(leg_r.rotation.x, 0.0, k)
			leg_r.rotation.z = lerpf(leg_r.rotation.z, 0.0, k)
		_knee(knee_l, maxf(0.0, shift) * 0.12, k)
		_knee(knee_r, maxf(0.0, -shift) * 0.12, k)
		body.position.y = lerpf(body.position.y, sin(_t * 1.8) * 0.006 - absf(shift) * 0.004, k)
		body.rotation.x = lerpf(body.rotation.x, 0.0, k)
		body.rotation.z = lerpf(body.rotation.z, shift * 0.02, k)
	# Bakınma; konuşurken başını sallar
	if head:
		_look_t -= delta
		if _look_t <= 0.0:
			_look_t = randf_range(2.0, 5.0)
			_look_yaw = randf_range(-0.45, 0.45) if randf() < 0.6 else 0.0
			_look_pitch = randf_range(-0.12, 0.08)
		var ht := Vector3(_look_pitch, _look_yaw, 0.0)
		if talking:
			ht = Vector3(sin(_t * 5.2) * 0.07, sin(_t * 1.3) * 0.12, sin(_t * 2.1) * 0.04)
		head.rotation = head.rotation.lerp(ht, clampf(delta * 4.0, 0.0, 1.0))
	if arm_l == null or arm_r == null:
		return
	# Kollar: konuşurken jest (öne uzatma, açma, havaya kaldırma), boşta hafif salınım
	if talking:
		_gesture_t -= delta
		if _gesture_t <= 0.0:
			_gesture_t = randf_range(0.9, 2.0)
			match randi() % 5:
				0: _gesture = Vector4(-0.9, 0.25, 0.0, -0.1)
				1: _gesture = Vector4(-0.5, 0.6, -0.5, -0.6)
				2: _gesture = Vector4(0.0, 0.1, -0.8, -0.3)
				3: _gesture = Vector4(-1.3, 0.1, 0.0, -0.1)
				_: _gesture = Vector4(-0.2, 0.15, -0.2, -0.15)
		var bob := sin(_t * 6.0) * 0.08
		var g := clampf(delta * 5.0, 0.0, 1.0)
		arm_r.rotation.x = lerpf(arm_r.rotation.x, _gesture.x + bob, g)
		arm_r.rotation.z = lerpf(arm_r.rotation.z, _gesture.y, g)
		arm_l.rotation.x = lerpf(arm_l.rotation.x, _gesture.z - bob, g)
		arm_l.rotation.z = lerpf(arm_l.rotation.z, _gesture.w, g)
		# Jestte dirsek: kol öne gidince önkol kalkar (açıklayan bir el)
		_elbow(elbow_r, -0.35 + _gesture.x * 0.6 + bob, g)
		_elbow(elbow_l, -0.35 + _gesture.z * 0.6 - bob, g)
	else:
		var sway := sin(_t * 1.8) * 0.03
		arm_r.rotation.x = lerpf(arm_r.rotation.x, sway, k * 0.5)
		arm_r.rotation.z = lerpf(arm_r.rotation.z, arm_rest_z, k * 0.5)
		arm_l.rotation.x = lerpf(arm_l.rotation.x, -sway, k * 0.5)
		arm_l.rotation.z = lerpf(arm_l.rotation.z, -arm_rest_z, k * 0.5)
		_elbow(elbow_r, -0.14 - sway, k * 0.5)
		_elbow(elbow_l, -0.14 + sway, k * 0.5)


func _knee(n: Node3D, a: float, k := 1.0) -> void:
	if n:
		n.rotation.x = lerpf(n.rotation.x, a, k)


func _elbow(n: Node3D, a: float, k := 1.0) -> void:
	if n:
		n.rotation.x = lerpf(n.rotation.x, a, k)


## İş hareketi; true dönerse normal boşta/konuşma animasyonu atlanır.
func _activity(delta: float, talking: bool, k: float) -> bool:
	var sitting := activity in ["sit", "sit_ground", "write"]
	if sitting:
		var drop := -0.22 if activity == "sit" else -0.56
		body.position.y = lerpf(body.position.y, drop, k)
		body.rotation.x = lerpf(body.rotation.x, 0.08 if activity == "write" else 0.0, k)
		if leg_l:
			leg_l.rotation = leg_l.rotation.lerp(Vector3(-1.45, 0, -0.18 if activity != "sit" else 0.0), k)
		if leg_r:
			leg_r.rotation = leg_r.rotation.lerp(Vector3(-1.45, 0, 0.18 if activity != "sit" else 0.0), k)
		# Taburede baldırlar aşağı sarkar; yerde bağdaş: dizler katlanır
		var kb := 1.45 if activity == "sit" else 2.3
		_knee(knee_l, kb, k)
		_knee(knee_r, kb, k)
	if talking or arm_l == null or arm_r == null:
		# Konuşurken oturuş sürer, kollar ve baş normal konuşma jestine döner
		return false
	var t := _t
	match activity:
		"sit", "sit_ground":
			# Eller dizlerde
			arm_r.rotation = arm_r.rotation.lerp(Vector3(-0.35, 0, 0.15), k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.35, 0, -0.15), k)
			_elbow(elbow_r, -0.9, k)
			_elbow(elbow_l, -0.9, k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(sin(t * 0.5) * 0.05, sin(t * 0.37) * 0.3, 0), clampf(delta * 2.0, 0.0, 1.0))
		"write":
			arm_r.rotation = arm_r.rotation.lerp(Vector3(-1.05 + sin(t * 11.0) * 0.04, 0, 0.12 + sin(t * 2.3) * 0.08), k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.9, 0, -0.1), k)
			_elbow(elbow_r, -0.5 + sin(t * 11.0) * 0.08, k)
			_elbow(elbow_l, -0.6, k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(0.38, sin(t * 0.4) * 0.08, 0), k)
		"stir":
			arm_r.rotation = Vector3(-0.8 + sin(t * 3.0) * 0.22, 0, 0.3 + cos(t * 3.0) * 0.22)
			_elbow(elbow_r, -0.7 + cos(t * 3.0) * 0.2, k)
			_elbow(elbow_l, -0.8, k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.75, 0, -0.2), k)
			body.rotation.x = lerpf(body.rotation.x, 0.14, k)
			body.position.y = lerpf(body.position.y, sin(t * 3.0) * 0.01, k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(0.3, sin(t * 0.6) * 0.15, 0), k)
		"chop":
			arm_r.rotation = Vector3(-0.7 - absf(sin(t * 8.0)) * 0.25, 0, 0.2)
			_elbow(elbow_r, -0.6 - absf(sin(t * 8.0)) * 0.5)
			_elbow(elbow_l, -0.9, k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.85, 0, -0.1), k)
			body.rotation.x = lerpf(body.rotation.x, 0.1, k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(0.35, sin(t * 0.5) * 0.1, 0), k)
		"hammer":
			var ph := fmod(t * 1.4, 1.0)
			var swing := -2.5 + pow(ph, 3.0) * 1.9 if ph < 0.85 else -0.6 - (ph - 0.85) / 0.15 * 1.9
			arm_r.rotation = Vector3(swing, 0, 0.15)
			# Çekiç kalkarken dirsek bükülür, inerken kol açılır
			_elbow(elbow_r, -1.3 * (1.0 - clampf((swing + 2.5) / 1.9, 0.0, 1.0)) - 0.2)
			_elbow(elbow_l, -0.7, k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.8, 0, -0.25), k)
			body.rotation.x = lerpf(body.rotation.x, 0.18, k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(0.35, 0, 0), k)
		"paint":
			arm_r.rotation = Vector3(-1.2 + sin(t * 2.2) * 0.2, 0, 0.3 + sin(t * 1.3) * 0.15)
			_elbow(elbow_r, -0.5 + sin(t * 2.2) * 0.3, k)
			_elbow(elbow_l, -1.2, k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.5, 0, -0.35), k)
			if head:
				head.rotation = head.rotation.lerp(Vector3(-0.05, sin(t * 0.5) * 0.1, sin(t * 0.8) * 0.1), k)
		"carry":
			arm_r.rotation = arm_r.rotation.lerp(Vector3(-0.55, 0, 0.18), k)
			arm_l.rotation = arm_l.rotation.lerp(Vector3(-0.55, 0, -0.18), k)
			_elbow(elbow_l, -1.1, k)
			_elbow(elbow_r, -1.1, k)
			return false if head == null else _idle_head(delta)
		_:
			return false
	return true


func _idle_head(delta: float) -> bool:
	_look_t -= delta
	if _look_t <= 0.0:
		_look_t = randf_range(2.0, 5.0)
		_look_yaw = randf_range(-0.45, 0.45) if randf() < 0.6 else 0.0
	head.rotation = head.rotation.lerp(Vector3(0, _look_yaw, 0), clampf(delta * 4.0, 0.0, 1.0))
	return true


## Tepki animasyonları: "surprise", "laugh", "shrug", "wave", "nod", "facepalm", "cheer".
func emote(kind: String) -> void:
	if not owner.is_inside_tree() or arm_l == null or arm_r == null:
		return
	lock += 1
	var tw := owner.create_tween()
	match kind:
		"surprise":
			tw.set_parallel(true)
			tw.tween_property(arm_r, "rotation", Vector3(-2.6, 0, 0.5), 0.15)
			tw.tween_property(arm_l, "rotation", Vector3(-2.6, 0, -0.5), 0.15)
			_tw_elbows(tw, -0.45, 0.15)
			tw.tween_property(body, "rotation:x", -0.12, 0.15)
			if head:
				tw.tween_property(head, "rotation:x", -0.2, 0.15)
			if brows:
				tw.tween_property(brows, "position:y", _brow_y0 + 0.03, 0.15)
			tw.set_parallel(false)
			tw.tween_interval(0.7)
		"laugh":
			# Göbeğini tutarak güler
			tw.set_parallel(true)
			tw.tween_property(arm_r, "rotation", Vector3(-0.35, 0, 0.3), 0.15)
			tw.tween_property(arm_l, "rotation", Vector3(-0.35, 0, -0.3), 0.15)
			_tw_elbows(tw, -1.35, 0.15)
			tw.set_parallel(false)
			for i in 6:
				tw.tween_property(body, "rotation:x", 0.12, 0.09)
				tw.tween_property(body, "rotation:x", -0.04, 0.09)
			if head:
				tw.parallel().tween_property(head, "rotation:x", -0.25, 0.3)
		"shrug":
			tw.set_parallel(true)
			# Klasik omuz silkme: kollar yanda, önkollar yukarı, avuçlar açık
			tw.tween_property(arm_r, "rotation", Vector3(-0.15, 0, 0.45), 0.2)
			tw.tween_property(arm_l, "rotation", Vector3(-0.15, 0, -0.45), 0.2)
			_tw_elbows(tw, -1.55, 0.2)
			tw.tween_property(body, "position:y", body.position.y + 0.03, 0.2)
			if head:
				tw.tween_property(head, "rotation:z", 0.2, 0.2)
			if brows:
				tw.tween_property(brows, "position:y", _brow_y0 + 0.02, 0.2)
			tw.set_parallel(false)
			tw.tween_interval(0.6)
		"wave":
			# Kol kalkar, el dirsekten sallanır
			tw.tween_property(arm_r, "rotation", Vector3(-2.5, 0, 0.45), 0.2)
			if elbow_r:
				tw.parallel().tween_property(elbow_r, "rotation", Vector3(-0.35, 0, 0), 0.2)
				for i in 3:
					tw.tween_property(elbow_r, "rotation:z", 0.55, 0.14)
					tw.tween_property(elbow_r, "rotation:z", -0.45, 0.14)
				tw.tween_property(elbow_r, "rotation:z", 0.0, 0.1)
			else:
				for i in 3:
					tw.tween_property(arm_r, "rotation:z", 0.7, 0.14)
					tw.tween_property(arm_r, "rotation:z", 0.1, 0.14)
		"nod":
			if head:
				for i in 2:
					tw.tween_property(head, "rotation:x", 0.3, 0.14)
					tw.tween_property(head, "rotation:x", -0.05, 0.14)
			else:
				tw.tween_interval(0.5)
		"facepalm":
			# El gerçekten yüze gider: kol öne, dirsek tam bükük
			tw.tween_property(arm_r, "rotation", Vector3(-1.25, 0, -0.35) if elbow_r else Vector3(-2.2, 0, -0.6), 0.25)
			if elbow_r:
				tw.parallel().tween_property(elbow_r, "rotation:x", -2.1, 0.25)
			if head:
				tw.parallel().tween_property(head, "rotation:x", 0.3, 0.25)
			tw.tween_interval(0.8)
		"cheer":
			var y0 := owner.position.y
			tw.set_parallel(true)
			tw.tween_property(arm_r, "rotation", Vector3(-2.9, 0, 0.2), 0.15)
			tw.tween_property(arm_l, "rotation", Vector3(-2.9, 0, -0.2), 0.15)
			_tw_elbows(tw, -0.3, 0.15)
			if knee_l and knee_r:
				tw.tween_property(knee_l, "rotation:x", 0.6, 0.15)
				tw.tween_property(knee_r, "rotation:x", 0.6, 0.15)
			tw.tween_property(owner, "position:y", y0 + 0.25, 0.15)
			tw.set_parallel(false)
			tw.tween_property(owner, "position:y", y0, 0.2)
			tw.tween_interval(0.3)
		"bow", "lean":
			# Saygıyla eğilme / öne eğilme (bir şeye bakmak için)
			var deep := 0.38 if kind == "bow" else 0.26
			tw.tween_property(body, "rotation:x", deep, 0.3).set_trans(Tween.TRANS_SINE)
			if head:
				tw.parallel().tween_property(head, "rotation:x", 0.2, 0.3)
			tw.tween_interval(0.7 if kind == "bow" else 1.2)
			tw.tween_property(body, "rotation:x", 0.0, 0.35).set_trans(Tween.TRANS_SINE)
		"sip", "eat", "sniff":
			# El ağza/buruna gider: yudum (bardak), yeme (bir tane), koklama (boş el)
			var prop := _hand_prop("cup" if kind == "sip" else ("bite" if kind == "eat" else ""))
			tw.tween_property(arm_r, "rotation", Vector3(-1.15, 0, -0.3), 0.25)
			if elbow_r:
				tw.parallel().tween_property(elbow_r, "rotation:x", -2.0, 0.25)
			if head:
				tw.parallel().tween_property(head, "rotation:x", -0.12 if kind == "sip" else 0.05, 0.25)
			if kind == "sip":
				tw.tween_callback(Audio.sfx_at.bind("tea_sip", body, -10.0))
			var reps := 2 if kind == "eat" else 1
			for i in reps:
				tw.tween_interval(0.35)
				if kind == "eat" and elbow_r:
					tw.tween_property(elbow_r, "rotation:x", -1.4, 0.15)
					tw.tween_property(elbow_r, "rotation:x", -2.0, 0.15)
			tw.tween_interval(0.5 if kind != "eat" else 0.2)
			if prop:
				tw.tween_callback(prop.queue_free)
		"stir_cup":
			# Bardaktaki çayı kaşıkla karıştırır, sonra bir yudum
			var cup := _hand_prop("cup")
			Audio.sfx_at("tea_stir", body, -8.0)   # kaşık bardakta döner, sonunda kenara iki kez vurur
			tw.tween_property(arm_r, "rotation", Vector3(-0.95, 0, -0.25), 0.25)
			if elbow_r:
				tw.parallel().tween_property(elbow_r, "rotation:x", -1.35, 0.25)
			if head:
				tw.parallel().tween_property(head, "rotation:x", 0.25, 0.25)
			for i in 4:
				tw.tween_property(arm_l, "rotation", Vector3(-0.9, 0, 0.2), 0.12)
				tw.tween_property(arm_l, "rotation", Vector3(-0.8, 0, 0.35), 0.12)
			tw.tween_property(arm_r, "rotation", Vector3(-1.15, 0, -0.3), 0.25)
			if elbow_r:
				tw.parallel().tween_property(elbow_r, "rotation:x", -2.0, 0.25)
			if head:
				tw.parallel().tween_property(head, "rotation:x", -0.12, 0.25)
			tw.tween_callback(Audio.sfx_at.bind("tea_sip", body, -10.0))
			tw.tween_interval(0.6)
			tw.tween_callback(cup.queue_free)
		"offer", "offer2", "offer_cup":
			# Bir şey uzatır (kalem, form, mektup, çay bardağı) ya da iki eliyle tartar
			var prop2 := _hand_prop("paper" if kind == "offer" else "cup") if kind != "offer2" else null
			tw.set_parallel(true)
			tw.tween_property(arm_r, "rotation", Vector3(-1.35, 0, 0.05), 0.3)
			if elbow_r:
				tw.tween_property(elbow_r, "rotation:x", -0.25, 0.3)
			if kind == "offer2":
				tw.tween_property(arm_l, "rotation", Vector3(-1.35, 0, -0.05), 0.3)
				if elbow_l:
					tw.tween_property(elbow_l, "rotation:x", -0.25, 0.3)
			tw.tween_property(body, "rotation:x", 0.08, 0.3)
			tw.set_parallel(false)
			tw.tween_interval(1.1)
			if prop2:
				tw.tween_callback(prop2.queue_free)
		"read":
			# Kâğıdı iki eliyle tutar, başını eğip okur
			var paper := _hand_prop("paper")
			tw.set_parallel(true)
			tw.tween_property(arm_r, "rotation", Vector3(-0.95, 0, -0.3), 0.3)
			tw.tween_property(arm_l, "rotation", Vector3(-0.95, 0, 0.3), 0.3)
			_tw_elbows(tw, -1.2, 0.3)
			if head:
				tw.tween_property(head, "rotation:x", 0.32, 0.3)
			tw.set_parallel(false)
			if head:
				for i in 2:
					tw.tween_property(head, "rotation:y", 0.12, 0.45)
					tw.tween_property(head, "rotation:y", -0.12, 0.45)
				tw.tween_property(head, "rotation:y", 0.0, 0.2)
			tw.tween_callback(paper.queue_free)
		"phone":
			# Telefonu eline alıp ekrana bakar (ekran yüzünü aydınlatır)
			var ph := _hand_prop("phone")
			tw.set_parallel(true)
			tw.tween_property(arm_r, "rotation", Vector3(-1.2, 0, -0.3), 0.3)
			if elbow_r:
				tw.tween_property(elbow_r, "rotation:x", -0.95, 0.3)
			if head:
				tw.tween_property(head, "rotation:x", 0.3, 0.3)
			tw.set_parallel(false)
			tw.tween_interval(3.4)
			tw.tween_callback(ph.queue_free)
		"write":
			# Önünde yazar/imzalar: el küçük daireler çizer
			var pen := _hand_prop("pen")
			tw.tween_property(arm_r, "rotation", Vector3(-0.85, 0, -0.25), 0.25)
			if elbow_r:
				tw.parallel().tween_property(elbow_r, "rotation:x", -1.05, 0.25)
			if head:
				tw.parallel().tween_property(head, "rotation:x", 0.35, 0.25)
			for i in 5:
				tw.tween_property(arm_r, "rotation:z", -0.12, 0.1)
				tw.tween_property(arm_r, "rotation:z", -0.32, 0.1)
			tw.tween_callback(pen.queue_free)
		"stamp":
			tw.tween_property(arm_r, "rotation", Vector3(-2.2, 0, -0.1), 0.2).set_ease(Tween.EASE_OUT)
			tw.tween_property(arm_r, "rotation:x", -0.8, 0.08)
			tw.tween_interval(0.25)
		"sigh":
			var y1 := body.position.y
			tw.tween_property(body, "position:y", y1 + 0.025, 0.4).set_trans(Tween.TRANS_SINE)
			if head:
				tw.parallel().tween_property(head, "rotation:x", -0.15, 0.4)
			tw.tween_property(body, "position:y", y1 - 0.015, 0.6).set_trans(Tween.TRANS_SINE)
			if head:
				tw.parallel().tween_property(head, "rotation:x", 0.3, 0.6)
			tw.tween_interval(0.4)
			tw.tween_property(body, "position:y", y1, 0.3)
		"tearful":
			# Başı düşer, eliyle gözünü siler
			if head:
				tw.tween_property(head, "rotation:x", 0.28, 0.3)
			tw.parallel().tween_property(arm_r, "rotation", Vector3(-1.3, 0, -0.4), 0.3)
			if elbow_r:
				tw.parallel().tween_property(elbow_r, "rotation:x", -2.15, 0.3)
			for i in 2:
				tw.tween_property(arm_r, "rotation:z", -0.25, 0.18)
				tw.tween_property(arm_r, "rotation:z", -0.45, 0.18)
			tw.tween_interval(0.6)
		"hat":
			# Şapkasını çıkarıp göğsüne bastırır
			tw.tween_property(arm_r, "rotation", Vector3(-2.75, 0, 0.1), 0.3)
			if elbow_r:
				tw.parallel().tween_property(elbow_r, "rotation:x", -0.7, 0.3)
			tw.tween_interval(0.25)
			tw.tween_property(arm_r, "rotation", Vector3(-0.9, 0, -0.35), 0.35)
			if elbow_r:
				tw.parallel().tween_property(elbow_r, "rotation:x", -1.6, 0.35)
			if head:
				tw.parallel().tween_property(head, "rotation:x", 0.2, 0.35)
			tw.tween_interval(1.0)
		"whisper", "think":
			# Fısıltı: öne eğilip elini ağzına siper eder. Düşünme: eli çenede, baş yana
			var hand_z := 0.35 if kind == "whisper" else -0.3
			tw.set_parallel(true)
			if kind == "whisper":
				tw.tween_property(body, "rotation:x", 0.14, 0.3)
				tw.tween_property(arm_l, "rotation", Vector3(-1.25, 0, hand_z), 0.3)
				if elbow_l:
					tw.tween_property(elbow_l, "rotation:x", -2.0, 0.3)
			else:
				tw.tween_property(arm_r, "rotation", Vector3(-1.05, 0, hand_z), 0.3)
				if elbow_r:
					tw.tween_property(elbow_r, "rotation:x", -2.05, 0.3)
			if head:
				tw.tween_property(head, "rotation:z", 0.15, 0.3)
			tw.set_parallel(false)
			tw.tween_interval(1.2)
		_:
			tw.tween_interval(0.1)
	await tw.finished
	lock -= 1


## Hareket sırasında elde küçük bir eşya: "cup" (bardak), "bite" (lokma), "paper" (kâğıt), "pen" (kalem).
## Eline bir eşya alır ve inceler (Fatih'e gösterilen eşyalar, okunan mektup): kol kalkar, baş eşyaya eğilir,
## eşya elde yavaşça döner; read: mektup gibi yüzünün önünde düz tutulur. release_item() bırakır.
var _held: Node3D
var _held_tw: Tween


func hold_item(model: Node3D, read := false) -> void:
	release_item()
	if elbow_r == null or arm_r == null or not owner.is_inside_tree():
		return
	lock += 1
	var n := Node3D.new()
	elbow_r.add_child(n)
	n.position = Vector3(0, -0.3, 0.1)
	if model.get_parent():
		model.get_parent().remove_child(model)
	n.add_child(model)
	model.position = Vector3.ZERO
	model.rotation = Vector3(deg_to_rad(-70), 0, 0) if read else Vector3.ZERO
	_held = n
	var tw := owner.create_tween().set_parallel(true)
	tw.tween_property(arm_r, "rotation", Vector3(-1.45 if read else -1.15, 0, -0.35), 0.35)
	tw.tween_property(elbow_r, "rotation:x", -1.3 if read else -0.95, 0.35)
	if head:
		tw.tween_property(head, "rotation:x", 0.18 if read else 0.28, 0.35)
	if not read:
		_held_tw = owner.create_tween().set_loops()
		_held_tw.tween_property(model, "rotation:y", TAU, 4.5).from(0.0)


func release_item() -> void:
	if _held == null:
		return
	if _held_tw and _held_tw.is_valid():
		_held_tw.kill()
	_held_tw = null
	if is_instance_valid(_held):
		_held.queue_free()
	_held = null
	lock = maxi(0, lock - 1)


func _hand_prop(kind: String) -> Node3D:
	if kind == "" or elbow_r == null:
		return null
	var n := Node3D.new()
	elbow_r.add_child(n)
	n.position = Vector3(0, -0.29, 0.04)
	match kind:
		"cup":
			# İnce belli çay bardağı: tabak, tavşan kanı çay, cam
			Props.cyl(n, 0.05, 0.008, Vector3(0, -0.05, 0), Color("f0ece4"), Vector3.ZERO, 12)
			Props.cyl(n, 0.024, 0.075, Vector3(0, -0.01, 0), Color("a0301a"), Vector3.ZERO, 10, 0.02)
			var glass := Props.cyl(n, 0.028, 0.09, Vector3(0, -0.005, 0), Color(1, 1, 1, 0.3), Vector3.ZERO, 12, 0.022)
			glass.material_override = Props.mat(Color(0.92, 0.96, 1.0, 0.3), 0.0, true, "", false)
		"bite":
			Props.ball(n, 0.025, Vector3.ZERO, Color("d9b98a"), Vector3.ONE, 6)
		"phone":
			Props.box(n, Vector3(0.075, 0.012, 0.15), Vector3(0, -0.02, 0.05), Color("1d1f24"), Vector3(-25, 0, 0))
			var scr := Props.box(n, Vector3(0.065, 0.004, 0.13), Vector3(0, -0.012, 0.05), Color("dff4ff"), Vector3(-25, 0, 0), 2.5)
			scr.material_override = Props.mat(Color("dff4ff"), 2.5, false, "", false)
			var gl := OmniLight3D.new()
			gl.position = Vector3(0, 0.08, 0.1)
			gl.light_color = Color("cfe8ff")
			gl.light_energy = 1.8
			gl.omni_range = 1.4
			n.add_child(gl)
		"paper":
			Props.box(n, Vector3(0.2, 0.004, 0.26), Vector3(0, -0.02, 0.1), Color("efe6cf"))
		"pen":
			Props.cyl(n, 0.006, 0.14, Vector3(0, -0.02, 0.03), Color("2a2a30"), Vector3(70, 0, 0), 5)
	return n


func _tw_elbows(tw: Tween, a: float, t: float) -> void:
	for e in [elbow_l, elbow_r]:
		if e:
			tw.tween_property(e, "rotation:x", a, t)
