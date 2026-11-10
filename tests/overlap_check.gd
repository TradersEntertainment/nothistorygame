extends Node3D
## Karakter üst üste binme denetimi (OVERLAPCHECK): bütün insan karakterleri (Person kılıkları, Soldier, Hikmet, şehir halkı
## rolleri, adlı karakterlerin görünüşleri) × poz/etkinlik × elde tutulan eşya birleşimleri kurulur; pozun hareketi 2 sn'de
## 11 adımda örneklenir; her adımda beden parçaları (kol, önkol, el, bacak, gövde, baş, başlık, sakal, etek/kaftan, eşya)
## birbirine karşı sınanır. Düzeltme yapmaz, ölçer ve raporlar (PASS/FAIL eşiği yok: rapor aracı).
##
## Yöntem
##  · Pişirilmiş (CharKit.bake) parça ağları köşe birleştirmesiyle ilkel parçalara (küre, silindir, kutu, kapsül) ayrılır;
##    her ilkel, kendi eksenlerinde en uygun analitik gövdeye (elipsoid, kapsül, kesik koni/silindir, kutu) oturtulur
##    (yönlü kutu AABB'si kaba kalırdı: kaftan etek geniş kutu olurdu).
##  · İki parça arası derinlik: bir parçanın yüzey örnekleri (uzun parçalarda eksen boyunca sıklaştırılmış) ötekinin içine
##    ne kadar girdi (iki yönlü, en büyüğü); ince levhalarda (pelerin, duvak, kalkan) levha normalinde itme mesafesi.
##  · Etek/kaftan/zırh eteği "kuşatan kumaş"tır: içindeki bacak/gövde sorun değildir. Bu parçayla ölçü, öteki parçanın
##    kumaşı KESİP geçtiği derinliktir: min(içine giren, dışarıda kalan); alt kenar açıktır (bacak etekten aşağı çıkar).
##  · Komşu eklemler (omuz-gövde, dirsek, bilek, kalça, diz, boyun) ve aynı sert gövdedeki parçalar (kafa-başlık) atlanır.
##  · Bilerek temas eden çiftler (elde tutulan eşya, el-yüz/gövde/diz/el pozları) "TEMAS" etiketiyle ayrı listelenir.
##
## Katmanlar: A = bütün türler × bütün pozlar (türün yerleşik eşyasıyla: şehir halkı yükü, devriye mızrağı...);
## B = 7 gövde türü + 3 asker türü × elde tutulan eşyalar × eşyayla anlamlı pozlar; L = LimbAnim klipleri (düello) × kılıç/kalkan.
## Çıktı satırı: OVERLAP|TEMAS tür=... poz=... eşya=... a=... b=... derinlik=...cm oran=...% (adımların yüzde kaçında).
## Sonda: özet, en kötü 40 (derinlik × oran), kök neden çeşitli en kötü 40, "OVERLAPCHECK DONE combos=N bad=M touch_combos=K".
## Hata ayıklama: --dump (parça dökümü), --pd / --pdc (çift ayrıntısı), --list (tür listesi), --dbg.
##
## Çalıştırma (başsız):
##   godot --headless --path . res://tests/overlap_check.tscn -- [--layer=A|B|L|ALL] [--types=ad,ad] [--poses=ad,ad]
##       [--items=ad,ad] [--limit=N] [--shard=i/n] [--out=TSV] [--quiet]
## Kare modu (ekranlı): -- --shots=DOSYA  (satır: no|tür|poz|eşya|adım|çıkış.png)
##   xvfb-run -a -s "-screen 0 1280x720x24" godot --path . --resolution 1500x500 res://tests/overlap_check.tscn -- --shots=DOSYA

const DEPTH_MIN := 0.03
const STEPS := 11
const SPAN := 2.0
const DT := 1.0 / 30.0
const SETTLE := 45
const MAX_SAMPLES := 28

# Parça rolleri
const R_CORE := 0
const R_CLOTH := 1
const R_OUTER := 2
const R_UPPER := 3
const R_FORE := 4
const R_HAND := 5
const R_THIGH := 6
const R_SHIN := 7
const R_FOOT := 8
const R_SKULL := 9
const R_HAT := 10
const R_BEARD := 11
const R_EYES := 12
const R_BROWS := 13
const R_ITEM := 14
const R_NECK := 15
const NR := 16
const ROLE_TR := ["gövde", "etek/kaftan", "giysi/zırh", "üstkol", "önkol", "el", "uyluk", "baldır", "ayak", "yüz", "başlık/saç",
	"sakal/bıyık", "göz", "kaş", "eşya", "boyun"]

# Şekiller
const S_BOX := 0
const S_ELL := 1
const S_CYL := 2
const S_CAP := 3
const S_RING := 4

const ACT_POSES := ["run_a", "run_b", "run_m", "run_ta", "run_tb", "run_tm", "leap", "climb_a", "climb_b", "aim", "fall", "lean_down",
	"thrust_a", "thrust_b", "throw_up", "throw_down", "dead", "crouch", "stretch_up", "stretch_pull", "stretch_low", "halay",
	"halay_lead", "clap", "row", "fly", "hover", "swim", "ride", "sit", "sit_ground", "doze", "hold_paper", "sit_astride",
	"hands_behind", "arms_folded", "hand_in_coat", "push", "write", "write_desk", "stir", "read_ground", "whittle", "chop",
	"hammer", "paint", "carry"]
const EMOTES := ["surprise", "laugh", "shrug", "wave", "cross_self", "wink", "nod", "facepalm", "cheer", "bow", "lean", "sip", "eat",
	"sniff", "stir_cup", "offer", "offer2", "offer_cup", "read", "phone", "write", "stamp", "sigh", "tearful", "hat", "point",
	"arms_cross", "swing", "whisper", "think"]
const SOLDIER_POSES := ["pull", "point", "soldier_aim", "soldier_push", "grease", "haul"]
const CLIPS := ["A_TPose", "Crouch_Idle_Loop", "Death01", "Hit_Chest", "Hit_Head", "Idle_Loop", "Idle_Talking_Loop", "Interact",
	"Jog_Fwd_Loop", "PickUp_Table", "Roll", "Sitting_Idle_Loop", "Sprint_Loop", "Sword_Attack", "Sword_Idle", "Walk_Loop",
	"ClimbUp_1m", "Hit_Knockback", "Idle_FoldArms_Loop", "Idle_No_Loop", "Idle_Shield_Break", "Idle_Shield_Loop", "Melee_Hook",
	"Shield_OneShot", "Sword_Block", "Sword_Heavy_Combo", "Sword_Regular_A", "Sword_Regular_B", "Sword_Regular_C", "Yes",
	"Kick_Front"]

# Bilerek temas eden çift sınıfları (poz → sınıflar): face = el/önkol ↔ yüz/başlık/sakal/göz; body = el/önkol ↔ gövde/giysi;
# hands = el/önkol ↔ öbür el/önkol; legs = el/önkol ↔ uyluk/baldır/etek
const POSE_TOUCH := {
	"emote:facepalm": ["face"], "emote:think": ["face"], "emote:whisper": ["face"], "emote:tearful": ["face"],
	"emote:sip": ["face"], "emote:eat": ["face"], "emote:sniff": ["face"], "emote:stir_cup": ["face", "hands"],
	"emote:phone": ["face"], "emote:hat": ["face", "body"], "emote:cross_self": ["face", "body"], "emote:laugh": ["body"],
	"emote:arms_cross": ["body", "hands"], "emote:read": ["hands", "body"], "emote:offer2": ["hands"], "emote:write": ["body"],
	"emote:stamp": ["body"], "emote:shrug": ["body"],
	"arms_folded": ["body", "hands"], "hand_in_coat": ["body", "hands"], "hands_behind": ["body", "hands"], "clap": ["hands"],
	"hold_paper": ["hands", "body"], "sit": ["legs"], "sit_ground": ["legs"], "row_rest": ["legs"], "row": ["legs"],
	"read_ground": ["legs", "hands"], "write": ["legs", "body"], "write_desk": ["legs", "body"], "whittle": ["legs", "hands"],
	"doze": ["face", "hands", "legs"], "sit_astride": ["hands", "legs"], "crouch": ["legs", "hands"], "stir": ["body"],
	"halay": ["hands"], "halay_lead": ["hands"],
	"fidget:0": ["face"], "fidget:1": ["hands", "body"], "fidget:2": ["body"], "fidget:3": ["body"], "fidget:4": ["body"],
}

# ---------------------------------------------------------------- iç sınıflar

class Comp:
	var piv := 0              # kıpırdayan düğüm dizini (Act.pn)
	var role := 0
	var side := 0             # -1 sol, +1 sağ, 0 yok
	var grp := 0              # eşya grubu (aynı eşyanın parçaları birbirine karşı sınanmaz)
	var shape := 0
	var c := Vector3.ZERO     # şekil merkezi (düğüm yerelinde)
	var bi := Basis.IDENTITY  # düğüm yereli → şekil çerçevesi
	var h := Vector3.ONE      # şekil çerçevesinde yarı ölçüler
	var k := 0                # silindir/kapsül ekseni
	var s0 := 1.0             # koni: yarıçap çarpanı (zn = 0'da) ve eğimi
	var s1 := 0.0
	var hr := 0.05            # enine yarıçap
	var ll := 0.0             # kapsül yarı uzunluğu (uçlar hariç)
	var thin := -1            # ince levha ekseni (-1: değil)
	var hmin := 0.05
	var ih := Vector3.ONE
	var ihz := 1.0
	var pts := PackedVector3Array()
	var bc := Vector3.ZERO
	var br := 0.0
	var res := 0.0            # oturtma hatası (tanı)
	var dims := ""
	var col := Color.WHITE
	var axis := Vector3.UP
	var label := ""


class Act:
	var node: Node3D
	var kind := "person"      # person | soldier | hikmet
	var rig: Rig
	var tname := ""
	var item := ""
	var pn: Array[Node3D] = []
	var pside: Array[int] = []
	var rest: Array[Transform3D] = []
	var n_base := 0           # kalıcı düğüm sayısı (sonrası eşya)
	var comps: Array = []     # Comp
	var n_base_comps := 0
	var base_ids := {}
	var base_pairs: Array = []
	var head_idx := -1
	var skin := Color.WHITE
	var hair := Color(0.2, 0.15, 0.1)
	var base_act := ""
	var item_ids := {}
	var keep_beam := false
	var keep_shield: Node3D = null
	var keep_shield_out := 0.35
	var spec: Dictionary = {}


var _types: Array = []        # tür tanımları
var _rng_seed := 12345
var _recs: Array = []         # sorun kayıtları
var _n_combo := 0
var _n_bad := 0
var _n_touch_combo := 0
var _fit_ms := 0
var _eval_ms := 0
var _opt := {}
var _quiet := false
var _tsv: FileAccess
var _mode := PackedByteArray()
var _pose_defs := {}
var _skip_static := 0


func _ready() -> void:
	GameState.autotest = true
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--") and a.contains("="):
			var kv := a.substr(2).split("=", true, 1)
			_opt[kv[0]] = kv[1]
		elif a.begins_with("--"):
			_opt[a.substr(2)] = "1"
	_quiet = _opt.has("quiet")
	_build_mode()
	_build_poses()
	_run.call_deferred()


# ---------------------------------------------------------------- tablolar

func _build_mode() -> void:
	_mode.resize(NR * NR)
	_mode.fill(0)
	var allow := {
		R_CORE: [R_FORE, R_HAND, R_ITEM, R_HAT, R_BEARD],
		R_CLOTH: [R_UPPER, R_FORE, R_HAND, R_THIGH, R_SHIN, R_FOOT, R_ITEM],
		R_OUTER: [R_FORE, R_HAND, R_THIGH, R_SHIN, R_ITEM, R_HAT, R_BEARD],
		R_UPPER: [R_SKULL, R_HAT, R_BEARD, R_FORE, R_HAND, R_UPPER, R_THIGH, R_SHIN, R_ITEM],
		R_FORE: [R_SKULL, R_HAT, R_BEARD, R_EYES, R_BROWS, R_FORE, R_HAND, R_THIGH, R_SHIN, R_ITEM],
		R_HAND: [R_SKULL, R_HAT, R_BEARD, R_EYES, R_BROWS, R_HAND, R_THIGH, R_SHIN, R_FOOT, R_ITEM],
		R_THIGH: [R_THIGH, R_SHIN, R_FOOT, R_ITEM],
		R_SHIN: [R_SHIN, R_FOOT, R_ITEM],
		R_FOOT: [R_FOOT, R_ITEM],
		R_SKULL: [R_ITEM, R_HAT],
		R_HAT: [R_EYES, R_BROWS, R_ITEM],
		R_BEARD: [R_ITEM],
		R_EYES: [R_ITEM],
		R_BROWS: [R_ITEM],
		R_ITEM: [R_ITEM],
		R_NECK: [R_FORE, R_HAND, R_ITEM],
	}
	for a: int in allow:
		for b: int in allow[a]:
			var m := 1
			if a == R_CLOTH or b == R_CLOTH:
				m = 2
			_mode[a * NR + b] = m
			_mode[b * NR + a] = m


func _build_poses() -> void:
	_pose_defs["idle"] = {"t": "idle"}
	_pose_defs["talk"] = {"t": "talk"}
	_pose_defs["walk"] = {"t": "walk", "v": 1.4}
	_pose_defs["run"] = {"t": "walk", "v": 5.6}
	for a: String in ACT_POSES:
		_pose_defs[a] = {"t": "act", "a": a}
	_pose_defs["row_rest"] = {"t": "act", "a": "row", "rest": true}
	for e: String in EMOTES:
		_pose_defs["emote:" + e] = {"t": "emote", "k": e}
	for i in 5:
		_pose_defs["fidget:%d" % i] = {"t": "fidget", "k": i}
	_pose_defs["reach:ön-alçak"] = {"t": "reach", "p": Vector3(0.25, 0.85, 0.7)}
	_pose_defs["reach:ön-yüksek"] = {"t": "reach", "p": Vector3(0.2, 1.85, 0.45)}
	for s: String in SOLDIER_POSES:
		_pose_defs[s] = {"t": "sold", "a": s}
	for c: String in CLIPS:
		_pose_defs["klip:" + c] = {"t": "clip", "c": c}


# ---------------------------------------------------------------- tür listesi

static func _sig(p: Dictionary) -> String:
	var robe: Color = p.get("robe", Color(0, 0, 0, 0))
	var apr: Color = p.get("apron", Color(0, 0, 0, 0))
	var fc = p.get("face", null)
	return "%s|%s%s%s%s%s%s%s|%s%s" % [p.get("hat", "none"), "R" if robe.a > 0.0 else "-", "S" if p.get("skirt", false) else "-",
		"B" if p.get("beard", false) else "-", "M" if p.get("mustache", false) else "-", "A" if apr.a > 0.0 else "-",
		"G" if p.get("glasses", false) else "-", "C" if p.get("child", false) else "-", p.get("armor", ""),
		"|tolga" if str(fc) == "tolga" else ""]


func _collect_types() -> void:
	var sigs := {}
	var add_person := func(nm: String, p: Dictionary) -> void:
		var sg := _sig(p)
		if sigs.has(sg):
			var ex: Dictionary = _types[sigs[sg]]
			if nm in ITEM_TYPES and not ex.get("item_type", false):
				(ex["alias"] as Array).append(str(ex["name"]))
				ex["name"] = nm
				ex["p"] = p
				ex["item_type"] = true
			else:
				(ex["alias"] as Array).append(nm)
			return
		sigs[sg] = _types.size()
		_types.append({"name": nm, "key": sg, "cls": "person", "p": p, "alias": [], "item_type": nm in ITEM_TYPES})
	# Elle seçilen gövde türleri (eşya katmanı bunları kullanır)
	var base_coat := Color("6a5040")
	var plain := {"coat": base_coat, "pants": Color("3a3028"), "hair": Color("3a2a1e"), "mustache": true, "skin": Color("d9a07a")}
	for k: String in PortraitLooks.LOOKS:
		var p: Dictionary = (PortraitLooks.LOOKS[k] as Dictionary).duplicate()
		if k == "SPK_HUSEYIN":
			p["hat"] = "bork"
		add_person.call(k, p)
	for k: String in PortraitLooks.SIDED:
		var arr: Array = PortraitLooks.SIDED[k]
		add_person.call(k + "_B", (arr[0] as Dictionary).duplicate())
		add_person.call(k + "_O", (arr[1] as Dictionary).duplicate())
	for fez: bool in [true, false]:
		for kaf: bool in [false, true]:
			var p := {"face": "tolga", "coat": Color("7a3a2a") if kaf else Color("23262d"), "pants": Color("23262d"), "skin": Color("e6ad88"),
				"hat": "fez" if fez else "none", "hair": Color("2a1e14")}
			if kaf:
				p["robe"] = Color("8a3a2a")
			add_person.call("SPK_TOLGA_%s%s" % ["fes" if fez else "başsız", "_kaftan" if kaf else ""], p)
	add_person.call("düz_erkek", plain)
	add_person.call("çocuk", {"coat": Color("c8603a"), "pants": Color("3a3a5a"), "hair": Color("5a3a1e"), "child": true})
	# Şehir halkı rolleri (CityLife): kurulum betiğin kendi koduyla
	var cl := CityLife.new()
	for role: String in ["vendor", "fisher", "porter", "priest", "monk", "woman", "child", "man", "lantern"]:
		for era: String in ["siege", "conquest"]:
			if era == "conquest" and not role in ["vendor", "man"]:
				continue
			_types.append({"name": "şehir_%s_%s" % [role, era], "key": "city|%s|%s" % [role, era], "cls": "city", "role": role, "era": era,
				"idx": 3 + _types.size(), "alias": []})
	for sq: int in [0, 3]:
		for slot: int in [0, 1]:
			_types.append({"name": "devriye_bizans_%d_%s" % [sq, "lider" if slot == 0 else "nöbetçi"], "key": "patrol|%d|%d" % [sq, slot],
				"cls": "patrol", "squad": sq, "slot": slot, "era": "siege", "night": false, "alias": [], "idx": 4000 + sq * 2 + slot})
	_types.append({"name": "devriye_bizans_fenerli", "key": "patrol|lantern", "cls": "patrol", "squad": 0, "slot": 0, "era": "siege",
		"night": true, "alias": [], "idx": 4100})
	_types.append({"name": "devriye_yeniçeri_mızraklı", "key": "patrol|jan", "cls": "patrol", "squad": 1, "slot": 1, "era": "conquest",
		"night": false, "alias": [], "idx": 4200})
	_types.append({"name": "devriye_yeniçeri_fenerli", "key": "patrol|janlan", "cls": "patrol", "squad": 1, "slot": 0, "era": "conquest",
		"night": true, "alias": [], "idx": 4201})
	cl.free()
	for hat: String in ["bork", "turban", "azap", "helmet", "helm", "fez"]:
		_types.append({"name": "asker_" + hat, "key": "soldier|" + hat, "cls": "soldier", "hat": hat, "coat": Color("b3262d"), "alias": []})
	_types.append({"name": "Hikmet", "key": "hikmet", "cls": "hikmet", "alias": []})


## Eşya katmanı için gövde türleri (ad)
const ITEM_TYPES := ["düz_erkek", "SPK_SINAN", "SPK_WOMAN", "çocuk", "SPK_NIKO", "SPK_FATIH", "SPK_GIUST"]
const PERSON_ITEMS := ["mızrak", "yay", "kalkan", "mızrak+kalkan", "kandil", "el_feneri", "haç", "buhurdan", "fener_sırığı", "kazma", "değnek",
	"olta", "kilij", "spathion", "kilij+kalkan", "spathion+kalkan", "yük:sepet", "yük:çuval", "yük:sini", "yük:toprak", "yük:fıçı",
	"yük:kalas", "yük:sandık"]
const SOLDIER_ITEMS := ["mızrak", "kılıç", "kalkan", "kılıç+kalkan", "yay", "tüfek", "meşale", "balta", "fener"]
const ITEM_POSES := ["idle", "talk", "walk", "run", "run_a", "run_b", "run_m", "leap", "climb_a", "climb_b", "aim", "fall", "lean_down",
	"thrust_a", "thrust_b", "throw_up", "crouch", "sit", "sit_ground", "arms_folded", "push", "hammer", "chop", "stir", "halay",
	"hover", "reach:ön-alçak", "reach:ön-yüksek", "emote:point", "emote:bow", "emote:swing", "emote:wave", "emote:cheer",
	"emote:surprise", "emote:facepalm", "emote:laugh", "emote:arms_cross", "emote:lean", "emote:shrug", "emote:think", "fidget:0",
	"fidget:1", "fidget:3"]
const CLIP_ITEMS := ["", "kilij", "spathion", "kilij+kalkan", "spathion+kalkan"]
const SOLDIER_ITEM_POSES := ["idle", "talk", "walk", "run", "soldier_aim", "soldier_push", "pull", "point", "run_a", "run_b", "thrust_a",
	"thrust_b", "lean_down", "crouch", "sit_ground", "climb_a", "aim", "throw_up", "hammer", "chop", "emote:point", "emote:bow",
	"emote:swing", "emote:wave", "emote:cheer", "emote:arms_cross", "emote:facepalm", "reach:ön-yüksek", "fidget:1", "fidget:3"]


# ---------------------------------------------------------------- kuruluş

func _make_node(t: Dictionary) -> Node3D:
	match str(t["cls"]):
		"person":
			var p := Person.new(t["p"])
			p.set_meta("no_chat", true)
			p.set_meta("no_talk", true)
			return p
		"city":
			var cl := CityLife.new()
			cl.era = str(t["era"])
			var ag := CityLife.Agent.new()
			ag.role = str(t["role"])
			ag.kind = "vendor" if ag.role == "vendor" else ("fisher" if ag.role == "fisher" else "civ")
			ag.idx = int(t["idx"])
			var body := cl._civ_body(ag, ag.idx)
			ag.body = body
			body.set_meta("no_talk", true)
			t["_ag"] = ag
			t["_cl"] = cl
			return body
		"patrol":
			var cl := CityLife.new()
			cl.era = str(t["era"])
			cl.night = bool(t["night"])
			var ag := CityLife.Agent.new()
			ag.kind = "patrol"
			ag.slot = int(t["slot"])
			ag.role = "leader" if ag.slot == 0 else "guard"
			ag.squad = [int(t["squad"])]
			ag.idx = int(t["idx"])
			var body := cl._patrol_body(ag, ag.idx)
			ag.body = body
			body.set_meta("no_talk", true)
			t["_ag"] = ag
			t["_cl"] = cl
			return body
		"soldier":
			var s := Soldier.new(t["coat"], "stand", str(t["hat"]))
			s.set_meta("no_talk", true)
			return s
		"hikmet":
			return Hikmet.new()
	return null


func _build_act(t: Dictionary) -> Act:
	var node := _make_node(t)
	if node == null:
		return null
	add_child(node)
	await get_tree().process_frame
	await get_tree().process_frame
	node.set_process(false)
	var a := Act.new()
	a.node = node
	a.tname = str(t["name"])
	a.spec = t
	a.kind = "soldier" if node is Soldier else ("hikmet" if node is Hikmet else "person")
	a.rig = node.get("rig")
	if a.rig == null:
		push_error("rig yok: " + a.tname)
		return null
	a.skin = node.get("skin") if node.get("skin") is Color else Color("d9a07a")
	if a.kind == "hikmet":
		a.skin = Color("e0a57e")
		a.hair = Color("e8e8e4")
	elif a.kind == "soldier":
		a.hair = Color("2b1d14")
	else:
		a.hair = node.get("hair") if node.get("hair") is Color else a.hair
	# Şehir halkı: rolün eşyası (taşıma, kandil, olta, fener) kurulu tür sayılır; temel gövdeden önce eklenmez
	_pivots(a)
	var t0 := Time.get_ticks_msec()
	_scan_base(a)
	if t.has("_ag"):
		_dress_city(a, t)
	else:
		_mark_items(a)
		_scan_items(a, "yerleşik")
		a.item = "yerleşik" if a.comps.size() > a.n_base_comps else ""
	_fit_ms += Time.get_ticks_msec() - t0
	return a


func _dress_city(a: Act, t: Dictionary) -> void:
	# Tür tanımındaki yerleşik eşya (porter yükü, kandil, olta, devriye mızrağı/feneri)
	var cl: CityLife = t["_cl"]
	var ag: CityLife.Agent = t["_ag"]
	if str(t["cls"]) == "city":
		cl._dress(ag)
	_mark_items(a)
	_scan_items(a, "yerleşik")
	a.item = "yerleşik" if a.comps.size() > a.n_base_comps else ""


func _pivots(a: Act) -> void:
	var r := a.rig
	var seen := {}
	var add := func(n: Node3D, side: int) -> void:
		if n == null or seen.has(n):
			return
		seen[n] = true
		a.pn.append(n)
		a.pside.append(side)
	add.call(a.node, 0)
	add.call(r.body, 0)
	add.call(r.head, 0)
	a.head_idx = a.pn.find(r.head)
	add.call(r.eyes, 0)
	add.call(r.brows, 0)
	for n in r.head.find_children("FaceDetail", "Node3D", true, false):
		add.call(n, 0)
	add.call(r.arm_l, -1)
	add.call(r.arm_r, 1)
	add.call(r.elbow_l, -1)
	add.call(r.elbow_r, 1)
	add.call(r.leg_l, -1)
	add.call(r.leg_r, 1)
	add.call(r.knee_l, -1)
	add.call(r.knee_r, 1)
	for pr: Array in [[r.elbow_l, -1], [r.elbow_r, 1]]:
		add.call((pr[0] as Node3D).get_node_or_null("Wrist"), pr[1])
	for pr: Array in [[r.knee_l, -1], [r.knee_r, 1]]:
		add.call((pr[0] as Node3D).get_node_or_null("Ankle"), pr[1])
	# Başka pişirilmiş düğümler (Hikmet'in bıyığı vb.)
	for n in a.node.find_children("*", "MeshInstance3D", true, false):
		if n.name == "Baked":
			var par := n.get_parent() as Node3D
			if par != null and not seen.has(par):
				var side := 0
				add.call(par, side)
	for n: Node3D in a.pn:
		a.rest.append(n.transform)
	a.n_base = a.pn.size()


## Düğümün hangi bilinen kıpırdayan düğümün altında olduğu (kendisi dahil)
func _owner_piv(a: Act, n: Node) -> int:
	var cur: Node = n
	while cur != null:
		var i := a.pn.find(cur)
		if i >= 0 and i < a.n_base:
			return i
		cur = cur.get_parent()
	return 0


func _pivot_role(a: Act, pi: int) -> int:
	var n := a.pn[pi]
	var r := a.rig
	if n == r.body:
		return R_CORE
	if n == r.head:
		return R_SKULL
	if n == r.eyes:
		return R_EYES
	if n == r.brows:
		return R_BROWS
	if n == r.arm_l or n == r.arm_r:
		return R_UPPER
	if n == r.elbow_l or n == r.elbow_r:
		return R_FORE
	if n == r.leg_l or n == r.leg_r:
		return R_THIGH
	if n == r.knee_l or n == r.knee_r:
		return R_SHIN
	if n.name == "Wrist":
		return R_HAND
	if n.name == "Ankle":
		return R_FOOT
	if n.name == "FaceDetail":
		return R_SKULL
	return R_CORE


func _is_descendant(n: Node, anc: Node) -> bool:
	var cur: Node = n
	while cur != null:
		if cur == anc:
			return true
		cur = cur.get_parent()
	return false


## Pişirilmiş ağları ilkellere ayırır, oturtur.
func _scan_base(a: Act) -> void:
	var mouth = a.node.get("_mouth")
	for pi in a.n_base:
		var piv := a.pn[pi]
		for ch in piv.get_children():
			if ch is MeshInstance3D and ch.name == "Baked":
				_split_baked(a, pi, ch as MeshInstance3D)
		a.base_ids[piv.get_instance_id()] = true
	# Pişirilmeyen kalıcı parçalar (Soldier'ın fesi vb.): başa bağlı olanlar sert gövdeye eklenir; ötekiler eşyadır
	for n in a.node.find_children("*", "MeshInstance3D", true, false):
		if n.name == "Baked" or n == mouth:
			continue
		var mi := n as MeshInstance3D
		if mi.mesh == null or not mi.is_visible_in_tree():
			continue
		var pi := _owner_piv(a, mi)
		if not _pivot_role(a, pi) in [R_SKULL, R_EYES, R_BROWS, R_THIGH, R_SHIN, R_FOOT]:
			continue
		var c := _comp_from_mesh(a, pi, mi, pi)
		if c != null:
			c.role = R_HAT if _is_descendant(mi, a.rig.head) else _pivot_role(a, pi)
			c.side = a.pside[pi]
			c.label = "base-extra"
			a.comps.append(c)
		a.base_ids[mi.get_instance_id()] = true
	for pi in a.n_base:
		for ch in a.pn[pi].get_children():
			a.base_ids[ch.get_instance_id()] = true
	for n in a.node.find_children("*", "Node", true, false):
		a.base_ids[n.get_instance_id()] = true
	# Önceden kuşanılmış eşyalar (devriye mızrağı, kova, fener...): kalıcı sayılmaz, eşya olarak taranır
	for n in a.node.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.name == "Baked" or mi == mouth or mi.mesh == null:
			continue
		if _pivot_role(a, _owner_piv(a, mi)) in [R_SKULL, R_EYES, R_BROWS, R_THIGH, R_SHIN, R_FOOT]:
			continue
		var root: Node = mi
		
		while root.get_parent() != null and not a.pn.has(root.get_parent()):
			root = root.get_parent()
		if root.get_parent() == null:
			continue
		for d in root.find_children("*", "Node", true, false):
			a.base_ids.erase(d.get_instance_id())
		a.base_ids.erase(root.get_instance_id())
	# Roller ve taraflar
	_classify(a)
	a.n_base_comps = a.comps.size()
	# Taban çiftleri
	a.base_pairs = _pairs(a, 0, a.n_base_comps, 0, a.n_base_comps)


func _split_baked(a: Act, pi: int, mi: MeshInstance3D) -> void:
	var m := mi.mesh
	if _opt.has("dbg"):
		print("  baked piv=%s mesh=%s surf=%d" % [a.pn[pi].name, m, m.get_surface_count() if m else -1])
	if m == null or m.get_surface_count() == 0:
		return
	var arr := m.surface_get_arrays(0)
	var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var ix: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
	var cols: PackedColorArray = arr[Mesh.ARRAY_COLOR]
	if _opt.has("dbg"):
		print("   v=%d ix=%d cols=%d" % [v.size(), ix.size(), cols.size()])
	if ix.is_empty():
		return
	# Köşe birleştirme: aynı yerdeki köşeler tek düğüm
	var wid := {}
	var vw := PackedInt32Array()
	vw.resize(v.size())
	var uniq := PackedVector3Array()
	var ucol := PackedColorArray()
	for i in v.size():
		var q := v[i]
		var key := Vector3i(roundi(q.x * 4000.0), roundi(q.y * 4000.0), roundi(q.z * 4000.0))
		var id: int = wid.get(key, -1)
		if id < 0:
			id = uniq.size()
			wid[key] = id
			uniq.append(q)
			ucol.append(cols[i] if i < cols.size() else Color.WHITE)
		vw[i] = id
	var par := PackedInt32Array()
	par.resize(uniq.size())
	for i in par.size():
		par[i] = i
	for t in range(0, ix.size(), 3):
		var a0 := _find(par, vw[ix[t]])
		var a1 := _find(par, vw[ix[t + 1]])
		var a2 := _find(par, vw[ix[t + 2]])
		if a1 != a0:
			par[a1] = a0
		var r2 := _find(par, a2)
		var r0 := _find(par, a0)
		if r2 != r0:
			par[r2] = r0
	var groups := {}
	for i in uniq.size():
		var rt := _find(par, i)
		if not groups.has(rt):
			groups[rt] = []
		(groups[rt] as Array).append(i)
	if _opt.has("dbg"):
		print("   uniq=%d groups=%d" % [uniq.size(), groups.size()])
	for rt in groups:
		var ids: Array = groups[rt]
		if ids.size() < 6:
			continue
		var pts := PackedVector3Array()
		for i in ids:
			pts.append(uniq[i])
		var c := _make_comp(pts, pi)
		if c == null:
			continue
		var col := ucol[ids[0]]
		c.dims = "%s#%s" % [c.dims, col.to_html(false)]
		c.col = col
		a.comps.append(c)


static func _find(par: PackedInt32Array, x: int) -> int:
	while par[x] != x:
		par[x] = par[par[x]]
		x = par[x]
	return x


func _comp_from_mesh(a: Act, pi: int, mi: MeshInstance3D, frame_piv: int) -> Comp:
	var m := mi.mesh
	var pts := PackedVector3Array()
	var seen := {}
	for si in m.get_surface_count():
		var arr := m.surface_get_arrays(si)
		var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		for q in v:
			var key := Vector3i(roundi(q.x * 4000.0), roundi(q.y * 4000.0), roundi(q.z * 4000.0))
			if not seen.has(key):
				seen[key] = true
				pts.append(q)
	if pts.size() < 4:
		return null
	var xf := a.pn[frame_piv].global_transform.affine_inverse() * mi.global_transform
	var out := PackedVector3Array()
	for q in pts:
		out.append(xf * q)
	return _make_comp(out, pi)


# ---------------------------------------------------------------- şekil oturtma

static func _jacobi(a: Array) -> Array:
	var v := [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]
	for sweep in 14:
		var off := absf(a[0][1]) + absf(a[0][2]) + absf(a[1][2])
		if off < 1e-14:
			break
		for pq: Array in [[0, 1], [0, 2], [1, 2]]:
			var p: int = pq[0]
			var q: int = pq[1]
			if absf(a[p][q]) < 1e-16:
				continue
			var theta: float = (a[q][q] - a[p][p]) / (2.0 * a[p][q])
			var t: float = (1.0 if theta >= 0.0 else -1.0) / (absf(theta) + sqrt(theta * theta + 1.0))
			var c: float = 1.0 / sqrt(t * t + 1.0)
			var s: float = t * c
			for k in 3:
				var akp: float = a[k][p]
				var akq: float = a[k][q]
				a[k][p] = c * akp - s * akq
				a[k][q] = s * akp + c * akq
			for k in 3:
				var apk: float = a[p][k]
				var aqk: float = a[q][k]
				a[p][k] = c * apk - s * aqk
				a[q][k] = s * apk + c * aqk
			for k in 3:
				var vkp: float = v[k][p]
				var vkq: float = v[k][q]
				v[k][p] = c * vkp - s * vkq
				v[k][q] = s * vkp + c * vkq
	return [Vector3(v[0][0], v[1][0], v[2][0]), Vector3(v[0][1], v[1][1], v[2][1]), Vector3(v[0][2], v[1][2], v[2][2])]


## Nokta bulutunu (düğüm yerelinde) en iyi oturan ilkele çevirir.
func _make_comp(pts: PackedVector3Array, pi: int) -> Comp:
	var n := pts.size()
	if n < 4:
		return null
	var mean := Vector3.ZERO
	for q in pts:
		mean += q
	mean /= float(n)
	var cov := [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]]
	for q in pts:
		var d := q - mean
		cov[0][0] += d.x * d.x
		cov[0][1] += d.x * d.y
		cov[0][2] += d.x * d.z
		cov[1][1] += d.y * d.y
		cov[1][2] += d.y * d.z
		cov[2][2] += d.z * d.z
	cov[1][0] = cov[0][1]
	cov[2][0] = cov[0][2]
	cov[2][1] = cov[1][2]
	var ev := _jacobi(cov)
	var frames: Array = [Basis(ev[0], ev[1], ev[2]), Basis.IDENTITY]
	var best: Comp = null
	var best_res := 1e9
	for fb: Basis in frames:
		var bi := fb.transposed()
		# Çerçevedeki sınırlar
		var lo := Vector3(1e9, 1e9, 1e9)
		var hi := Vector3(-1e9, -1e9, -1e9)
		var qs := PackedVector3Array()
		qs.resize(n)
		for i in n:
			var qq := bi * (pts[i] - mean)
			qs[i] = qq
			lo = lo.min(qq)
			hi = hi.max(qq)
		var mid := (lo + hi) * 0.5
		var h := ((hi - lo) * 0.5).max(Vector3(1e-4, 1e-4, 1e-4))
		var c0 := mean + fb * mid
		for i in n:
			qs[i] = qs[i] - mid
		# Kutu
		var rb := 0.0
		var re := 0.0
		for i in n:
			var qq := qs[i]
			rb += absf(maxf(maxf(absf(qq.x) / h.x, absf(qq.y) / h.y), absf(qq.z) / h.z) - 1.0)
			re += absf(Vector3(qq.x / h.x, qq.y / h.y, qq.z / h.z).length() - 1.0)
		rb /= n
		re /= n
		var cand: Array = [[S_BOX, rb + 0.02, -1], [S_ELL, re, -1]]
		for k in 3:
			var ia := (k + 1) % 3
			var ib := (k + 2) % 3
			var hk: float = h[k]
			var ha: float = h[ia]
			var hb: float = h[ib]
			# Kapsül
			var rr := minf(ha, hb)
			var ll := maxf(hk - rr, 0.0)
			var rc := 0.0
			for i in n:
				var qq := qs[i]
				var rho := sqrt(qq[ia] * qq[ia] + qq[ib] * qq[ib])
				var ex := maxf(absf(qq[k]) - ll, 0.0)
				rc += absf(sqrt(rho * rho + ex * ex) / rr - 1.0)
			rc /= n
			if absf(ha - hb) > 0.25 * maxf(ha, hb):
				rc += 0.3
			cand.append([S_CAP, rc + 0.004, k])
			# Kesik koni / silindir (eliptik kesit normalize)
			var sxx := 0.0
			var sx := 0.0
			var sy := 0.0
			var sxy := 0.0
			var cnt := 0
			var rmax := 0.0
			for i in n:
				var qq := qs[i]
				rmax = maxf(rmax, sqrt(pow(qq[ia] / ha, 2.0) + pow(qq[ib] / hb, 2.0)))
			for i in n:
				var qq := qs[i]
				var rn := sqrt(pow(qq[ia] / ha, 2.0) + pow(qq[ib] / hb, 2.0))
				if rn > 0.6 * rmax:
					var zn: float = qq[k] / hk
					sx += zn
					sy += rn
					sxx += zn * zn
					sxy += zn * rn
					cnt += 1
			var s0 := 1.0
			var s1 := 0.0
			if cnt >= 3:
				var den := float(cnt) * sxx - sx * sx
				if absf(den) > 1e-9:
					s1 = (float(cnt) * sxy - sx * sy) / den
					s0 = (sy - s1 * sx) / float(cnt)
				else:
					s0 = sy / float(cnt)
			var rcy := 0.0
			for i in n:
				var qq := qs[i]
				var zn: float = qq[k] / hk
				var rn := sqrt(pow(qq[ia] / ha, 2.0) + pow(qq[ib] / hb, 2.0))
				var sr := maxf(s0 + s1 * zn, 0.02)
				rcy += absf(maxf(rn / sr, absf(zn)) - 1.0)
			rcy /= n
			cand.append([S_CYL, rcy + 0.012, k, s0, s1])
			# Halka (torus): eksene yakın nokta yok
			var rmin := 1e9
			var rmaxx := 0.0
			for i in n:
				var qq := qs[i]
				var rho := sqrt(qq[ia] * qq[ia] + qq[ib] * qq[ib])
				rmin = minf(rmin, rho)
				rmaxx = maxf(rmaxx, rho)
			if rmin > 0.35 * rmaxx and hk < 0.5 * rmaxx and absf(ha - hb) < 0.2 * maxf(ha, hb):
				var rmaj := 0.5 * (rmin + rmaxx)
				var rtub := 0.5 * (rmaxx - rmin)
				if rtub > 1e-3:
					var rrg := 0.0
					for i in n:
						var qq := qs[i]
						var rho := sqrt(qq[ia] * qq[ia] + qq[ib] * qq[ib])
						rrg += absf(sqrt((rho - rmaj) * (rho - rmaj) + qq[k] * qq[k]) / rtub - 1.0)
					rrg /= n
					cand.append([S_RING, rrg - 0.002, k, rmaj, rtub])
		for cd: Array in cand:
			var rs: float = cd[1]
			if rs < best_res:
				best_res = rs
				var c := Comp.new()
				c.piv = pi
				c.shape = cd[0]
				c.c = c0
				c.bi = bi
				c.h = h
				c.k = maxi(int(cd[2]), 0)
				c.res = rs
				if c.shape == S_CYL:
					c.s0 = cd[3]
					c.s1 = cd[4]
				elif c.shape == S_RING:
					c.ll = cd[3]
					c.hr = cd[4]
				var ka: int = c.k
				if c.shape != S_RING:
					c.hr = minf(h[(ka + 1) % 3], h[(ka + 2) % 3])
				if c.shape == S_CAP:
					c.ll = maxf(h[ka] - c.hr, 0.0)
				# Eksen yönü (düğüm yerelinde yukarı mı)
				c.axis = fb[ka]
				c.hmin = minf(h.x, minf(h.y, h.z))
				best = c
	if best == null:
		return null
	if best.shape >= S_CYL:
		var kk: int = best.k
		var fb0 := best.bi.transposed()
		var ia0 := (kk + 1) % 3
		var ib0 := (kk + 2) % 3
		best.bi = Basis(fb0[ia0], fb0[ib0], fb0[kk]).transposed()
		best.h = Vector3(best.h[ia0], best.h[ib0], best.h[kk])
		best.k = 2
	best.dims = "%s h=(%.3f,%.3f,%.3f)%s" % [["kutu", "elips", "silindir", "kapsül", "halka"][best.shape], best.h.x, best.h.y, best.h.z,
		(" r=%.3f" % best.hr) if best.shape >= S_CYL else ""]
	best.ih = Vector3(1.0 / best.h.x, 1.0 / best.h.y, 1.0 / best.h.z)
	best.ihz = best.ih.z
	# İnce levha
	var hs: Vector3 = best.h
	if best.shape == S_BOX:
		var ia := 0
		for i in 3:
			if hs[i] < hs[ia]:
				ia = i
		if hs[ia] < 0.025:
			best.thin = ia
	elif best.shape == S_CYL and best.h.z < 0.025:
		best.thin = 2
	# Örnekler (yüzey): küçük parçada köşe noktaları, uzunda eksen boyunca sıklaştırılmış
	best.pts = _samples(best, pts)
	var bcen := Vector3.ZERO
	for q in best.pts:
		bcen += q
	bcen /= float(best.pts.size())
	var rad := 0.0
	for q in pts:
		rad = maxf(rad, q.distance_to(bcen))
	best.bc = bcen
	best.br = rad
	return best


func _samples(c: Comp, pts: PackedVector3Array) -> PackedVector3Array:
	var ext := maxf(c.h.x, maxf(c.h.y, c.h.z)) * 2.0
	var out := PackedVector3Array()
	if ext < 0.14 or c.shape == S_ELL or c.shape == S_RING:
		var stride := maxi(1, int(ceil(float(pts.size()) / float(MAX_SAMPLES))))
		var i := 0
		while i < pts.size():
			out.append(pts[i])
			i += stride
		return out
	# Uzun parça: en uzun eksen boyunca kesitler
	var la := 0
	for i in 3:
		if c.h[i] > c.h[la]:
			la = i
	var ia := (la + 1) % 3
	var ib := (la + 2) % 3
	var hl: float = c.h[la]
	var n := clampi(int(ceil(2.0 * hl / maxf(0.05, 2.0 * hl / 22.0))), 2, 24)
	var fb := c.bi.transposed()
	for j in n + 1:
		var z := -hl + 2.0 * hl * float(j) / float(n)
		var zn := z / hl
		var sc := 1.0
		if c.shape == S_CYL and c.k == la:
			sc = clampf(c.s0 + c.s1 * zn, 0.0, 1.5)
		var ha: float = c.h[ia] * sc
		var hb: float = c.h[ib] * sc
		var corners: Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
		if c.shape == S_BOX:
			corners = [Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]
		for cr: Vector2 in corners:
			var q := Vector3.ZERO
			q[la] = z
			q[ia] = cr.x * ha
			q[ib] = cr.y * hb
			out.append(c.c + fb * q)
	return out


# ---------------------------------------------------------------- derinlik

## Şeklin içinde (pozitif) ya da dışında (negatif) yaklaşık işaretli derinlik; p düğüm yerelinde.
## Silindir ve kapsülde eksen çerçevenin z'sidir (oturtma sırasında yeniden sıralanır).
static func _depth(cm: Comp, p: Vector3) -> float:
	var q := cm.bi * (p - cm.c)
	match cm.shape:
		S_BOX:
			return minf(minf(cm.h.x - absf(q.x), cm.h.y - absf(q.y)), cm.h.z - absf(q.z))
		S_ELL:
			var ux := q.x * cm.ih.x
			var uy := q.y * cm.ih.y
			var uz := q.z * cm.ih.z
			var g := sqrt(ux * ux + uy * uy + uz * uz)
			if g < 1e-4:
				return cm.hmin
			var gx := ux * cm.ih.x
			var gy := uy * cm.ih.y
			var gz := uz * cm.ih.z
			return (1.0 - g) * g / maxf(sqrt(gx * gx + gy * gy + gz * gz), 1e-6)
		S_CYL:
			var zn := q.z * cm.ihz
			var rx := q.x * cm.ih.x
			var ry := q.y * cm.ih.y
			var d_r := (maxf(cm.s0 + cm.s1 * zn, 0.02) - sqrt(rx * rx + ry * ry)) * cm.hr
			return minf(d_r, (1.0 - absf(zn)) * cm.h.z)
		S_CAP:
			var ex := maxf(absf(q.z) - cm.ll, 0.0)
			return cm.hr - sqrt(q.x * q.x + q.y * q.y + ex * ex)
		_:
			var rho := sqrt(q.x * q.x + q.y * q.y) - cm.ll
			return cm.hr - sqrt(rho * rho + q.z * q.z)


## Kumaş (kuşatan silindir) ile kesişme: kumaşın eksen aralığındaki noktalardan içeride kalanın derinliği ile dışarıda
## kalanın uzaklığının küçüğü. Alt kenarın altı ve üst kenarın üstü sayılmaz (bacak etekten aşağı çıkar).
static func _cloth_cross(pa: PackedVector3Array, xf: Transform3D, cb: Comp) -> Array:
	var din := 0.0
	var dout := 0.0
	var at := Vector3.ZERO
	for p in pa:
		var q := cb.bi * (xf * p - cb.c)
		var zn := q.z * cb.ihz
		if absf(zn) > 1.0:
			continue
		var rx := q.x * cb.ih.x
		var ry := q.y * cb.ih.y
		var d := (maxf(cb.s0 + cb.s1 * zn, 0.02) - sqrt(rx * rx + ry * ry)) * cb.hr
		if d > 0.0:
			if d > din:
				din = d
				at = p
		elif -d > dout:
			dout = -d
	var cr := minf(din, dout)
	return [cr, cr, at]


## A noktalarının B'ye göre derinliği. Döner: [en derin içeri, en uzak dışarı, en derin noktanın A yerelindeki yeri]
static func _pts_in(pa: PackedVector3Array, xf: Transform3D, cb: Comp) -> Array:
	var din := -1e9
	var dout := -1e9
	var at := Vector3.ZERO
	for p in pa:
		var d := _depth(cb, xf * p)
		if d > din:
			din = d
			at = p
		if -d > dout:
			dout = -d
	return [din, dout, at]


## İnce levhaya (B) karşı A'nın örnekleri: levha normalinde itme mesafesi
static func _thin_push(pa: PackedVector3Array, xf: Transform3D, cb: Comp, ca_hmin: float) -> float:
	var ax := cb.thin
	var ia := (ax + 1) % 3
	var ib := (ax + 2) % 3
	var amin := 1e9
	var amax := -1e9
	var any := false
	for p in pa:
		var q := cb.bi * (xf * p - cb.c)
		var lat_ok: bool
		if cb.shape == S_BOX:
			lat_ok = absf(q[ia]) < cb.h[ia] and absf(q[ib]) < cb.h[ib]
		else:
			lat_ok = sqrt(pow(q[ia] / cb.h[ia], 2.0) + pow(q[ib] / cb.h[ib], 2.0)) < 1.0
		if lat_ok:
			any = true
			amin = minf(amin, q[ax])
			amax = maxf(amax, q[ax])
	if not any:
		return 0.0
	var hh: float = cb.h[ax]
	if amax < -hh or amin > hh:
		return 0.0
	# Uzun ince parça levhayı deliyorsa itme mesafesi metrelerce olur: görünen kesişim parçanın kendi kalınlığı kadardır
	return minf(minf(amax + hh, hh - amin), 2.0 * ca_hmin + 2.0 * hh)


# ---------------------------------------------------------------- roller

func _skin_like(a: Act, c: Color) -> bool:
	var d := Vector3(c.r - a.skin.r, c.g - a.skin.g, c.b - a.skin.b).length()
	return d < 0.2


func _classify(a: Act) -> void:
	var keep: Array = []
	for c: Comp in a.comps:
		if c.label == "base-extra":
			keep.append(c)
			continue
		var pr := _pivot_role(a, c.piv)
		var n := a.pn[c.piv]
		c.side = a.pside[c.piv]
		if maxf(c.h.x, maxf(c.h.y, c.h.z)) < 0.011:
			continue
		var role := pr
		if n == a.rig.body or n == a.node:
			var axis_v := c.axis.abs().y > 0.9
			if c.shape == S_CYL and axis_v and c.hr >= 0.19 and c.c.y < 0.95:
				role = R_CLOTH
			elif absf(c.c.x) < 0.1 and absf(c.c.z) < 0.14 and c.c.y > 1.25 and c.hr < 0.1:
				role = R_NECK
			elif absf(c.c.x) < 0.1 and absf(c.c.z) < 0.14 and (c.hr >= 0.12 or c.c.y > 1.25):
				role = R_CORE
			else:
				role = R_OUTER
		elif n == a.rig.head:
			if _skin_like(a, c.col):
				role = R_SKULL
			elif c.c.y < -0.06 and c.c.z > -0.01 and Vector3(c.col.r - a.hair.r, c.col.g - a.hair.g, c.col.b - a.hair.b).length() < 0.2:
				role = R_BEARD          # sakal önde ve çenenin altındadır; arkada sarkan uzun saç "başlık/saç" kalır
			else:
				role = R_HAT
		elif n.name == "FaceDetail":
			role = R_SKULL if _skin_like(a, c.col) else (R_BEARD if Vector3(c.col.r - a.hair.r, c.col.g - a.hair.g, c.col.b - a.hair.b).length() < 0.25 else R_HAT)
		elif pr == R_CORE and n != a.rig.body:
			role = R_BEARD          # Hikmet'in bıyığı gibi başa bağlı pişirilmiş ek
		c.role = role
		keep.append(c)
	a.comps = keep


func _label(c: Comp) -> String:
	if c.role == R_ITEM:
		return "eşya:" + c.label
	var s: String = ROLE_TR[c.role]
	if c.side != 0 and c.role in [R_UPPER, R_FORE, R_HAND, R_THIGH, R_SHIN, R_FOOT]:
		s += "_sağ" if c.side > 0 else "_sol"
	return s


## Eşyaları (kalıcı olmayan MeshInstance3D'ler) tarar: her biri kendi düğümü; kolu tutan taraf bulunur.
func _scan_items(a: Act, label: String) -> void:
	_trim_items(a)
	var mouth = a.node.get("_mouth")
	var groups := {}
	var n_new := 0
	for n in a.node.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if a.base_ids.has(mi.get_instance_id()) or mi == mouth or mi.mesh == null or not mi.is_visible_in_tree():
			continue
		if mi.name == "Baked":
			continue
		# Eşya kökü: kalıcı düğümün hemen altındaki ata
		var root: Node = mi
		while root.get_parent() != null and not a.base_ids.has(root.get_parent().get_instance_id()):
			root = root.get_parent()
		var gid := root.get_instance_id()
		if not groups.has(gid):
			groups[gid] = groups.size() + 1
		var side := 0
		if a.rig.elbow_l != null and _is_descendant(mi, a.rig.elbow_l):
			side = -1
		elif a.rig.elbow_r != null and _is_descendant(mi, a.rig.elbow_r):
			side = 1
		var pi := a.pn.size()
		a.pn.append(mi)
		a.pside.append(side)
		var c := _comp_from_mesh(a, pi, mi, pi)
		if c == null:
			a.pn.pop_back()
			a.pside.pop_back()
			continue
		c.role = R_ITEM
		c.side = side
		c.grp = groups[gid]
		var parts := label.split("+")
		c.label = parts[clampi(int(c.grp) - 1, 0, parts.size() - 1)] if parts.size() > 1 else label
		a.comps.append(c)
		n_new += 1


func _trim_items(a: Act) -> void:
	while a.pn.size() > a.n_base:
		a.pn.pop_back()
		a.pside.pop_back()
	while a.comps.size() > a.n_base_comps:
		a.comps.pop_back()


## Eşya düğümlerini sahneden siler (kalıcı olmayan her şey)
func _clear_items(a: Act) -> void:
	_trim_items(a)
	a.item_ids = {}
	a.keep_shield = null
	a.keep_beam = false
	a.base_act = ""
	a.rig.arm_shield = null
	a.rig.beam_arm = false
	var kill: Array = []
	for n in a.node.find_children("*", "Node", true, false):
		if not a.base_ids.has(n.get_instance_id()):
			# yalnız eşya kökleri (alt düğümler zaten onunla gider)
			var par := n.get_parent()
			if par != null and a.base_ids.has(par.get_instance_id()):
				kill.append(n)
	for n: Node in kill:
		if is_instance_valid(n):
			n.get_parent().remove_child(n)
			n.free()
	if a.kind == "person":
		var p: Person = a.node
		p._carried = null
		p._tools.clear()
		p._tip = null
		if p.has_meta("shoulder_load"):
			p.remove_meta("shoulder_load")


# ---------------------------------------------------------------- çiftler

func _pair_ok(ci: Comp, cj: Comp) -> int:
	if ci.piv == cj.piv:
		return 0
	if ci.role == R_ITEM and cj.role == R_ITEM and ci.grp == cj.grp:
		return 0
	var m := _mode[ci.role * NR + cj.role]
	if m == 0:
		return 0
	var same := ci.side != 0 and ci.side == cj.side
	if same:
		var a := mini(ci.role, cj.role)
		var b := maxi(ci.role, cj.role)
		if (a == R_UPPER and b == R_FORE) or (a == R_FORE and b == R_HAND) or (a == R_THIGH and b == R_SHIN) or (a == R_SHIN and b == R_FOOT):
			return 0
		if (a == R_UPPER and b == R_ITEM):
			return 0
	return m


func _pairs(a: Act, i0: int, i1: int, j0: int, j1: int) -> Array:
	var out: Array = []
	for i in range(i0, i1):
		var ci: Comp = a.comps[i]
		for j in range(maxi(j0, i + 1), j1):
			var m := _pair_ok(ci, a.comps[j])
			if m != 0:
				out.append(Vector3i(i, j, m))
	return out


# ---------------------------------------------------------------- eşya uygulama

func _apply_item(a: Act, item: String) -> void:
	a.item = item
	a.base_act = ""
	a.keep_beam = false
	a.keep_shield = null
	if item == "":
		_mark_items(a)
		_scan_items(a, "")
		return
	if a.kind == "person":
		var p: Person = a.node
		match item:
			"mızrak": p.equip("spear")
			"yay": p.equip("bow")
			"kalkan": p.equip("shield")
			"mızrak+kalkan": p.equip("spear_shield")
			"kandil": p.equip("lamp")
			"el_feneri": p.equip("flashlight")
			"haç": p.equip("cross")
			"buhurdan": p.equip("censer")
			"fener_sırığı": p.equip("fanari")
			"kazma": p.equip("pick")
			"değnek": p.equip("rod")
			"olta":
				var rod := Node3D.new()
				p._elbow_r.add_child(rod)
				rod.position = Vector3(0, -0.28, 0.06)
				rod.rotation_degrees = Vector3(62, 0, 0)
				Props.cyl(rod, 0.016, 3.0, Vector3(0, 1.4, 0), Color("8a6a3a"), Vector3.ZERO, 4, 0.006)
				Props.cyl(rod, 0.003, 1.6, Vector3(0, 2.5, 0.6), Color("d8d0c0"), Vector3(-62, 0, 0), 3)
			"kilij", "spathion", "kilij+kalkan", "spathion+kalkan":
				var blade := "kilij" if item.begins_with("kilij") else "spathion"
				var mount := Node3D.new()
				mount.position = Vector3(0, -0.26, 0.02)
				mount.rotation_degrees = Vector3(90, 0, 0)
				a.rig.elbow_r.add_child(mount)
				var sw := Blades.kilij(mount) if blade == "kilij" else Blades.spathion(mount)
				sw.scale = Vector3.ONE * 1.25
				if item.ends_with("kalkan"):
					var sm := Node3D.new()
					a.rig.elbow_l.add_child(sm)
					Blades.shield(sm, Color("7a2a24"))
					a.rig.arm_shield = sm
			_:
				if item.begins_with("yük:"):
					var kind: String = {"sepet": "basket", "çuval": "sack", "sini": "tray", "toprak": "earth", "fıçı": "barrel", "kalas": "plank",
						"sandık": "crate"}[item.substr(4)]
					p.carry(kind)
					a.base_act = "carry"
	elif a.kind == "soldier":
		var s: Soldier = a.node
		match item:
			"mızrak": s.equip("spear")
			"kılıç": s.equip("sword")
			"kalkan": s.equip("shield")
			"kılıç+kalkan": s.equip("sword_shield")
			"yay": s.equip("bow")
			"tüfek":
				s.equip("handgun")
				a.base_act = "soldier_aim"
			"meşale": s.equip("torch")
			"balta": s.equip("axe")
			"fener":
				var cl := CityLife.new()
				cl._lantern(s._elbow_r)
				cl.free()
	a.keep_beam = a.rig.beam_arm
	a.keep_shield = a.rig.arm_shield
	a.keep_shield_out = a.rig.arm_shield_out
	_mark_items(a)
	_scan_items(a, item)


# ---------------------------------------------------------------- hareket sürücüsü

func _reset_pose(a: Act) -> void:
	for tw in get_tree().get_processed_tweens():
		tw.kill()
	_sweep(a)
	for i in a.n_base:
		a.pn[i].transform = a.rest[i]
	var r := a.rig
	r.activity = ""
	r.lock = 0
	r.speed = 0.0
	r._last_pos = Vector3.INF
	r._walk_phase = 0.0
	r._fid_t = -1.0
	r._fid_left = 0.0
	r._fid_kind = -1
	r.mood = ""
	r._t = 0.0                 # Rig'in kurulumda rastgele aldığı evre: her koşuda aynı sonuç için sıfırlanır
	r._blink_t = 2.0
	r._look_t = 1.0
	r._look_yaw = 0.0
	r._look_pitch = 0.0
	r._eyes_shut = 0.0
	r._glance_t = 0.0
	r._glance_on = false
	r.stare_t = 0.0
	r.row_phase = -1.0
	r.shield_up = 0
	r._gesture = Vector4.ZERO
	r._gesture_t = 0.0
	r._ank_v = PackedFloat32Array([0.0, 0.0])
	r._wr_v = PackedFloat32Array([0.0, 0.0])
	r._hold_check = 0
	r._m_brow = 0.0
	r._m_roll = 0.0
	r._m_eye = 1.0
	r.beam_arm = a.keep_beam
	r.arm_shield = a.keep_shield if is_instance_valid(a.keep_shield) else null
	r._shield_out = Vector3.ZERO
	if is_instance_valid(a.keep_shield):
		r.arm_shield_out = a.keep_shield_out
	if a.kind == "person":
		var p: Person = a.node
		p.activity = ""
		p.talking = false
		p.chatting = false
		p._busy = false
		p.look_target = null
		p._t = 0.0
	elif a.kind == "soldier":
		var s: Soldier = a.node
		s.pose = "stand"
		s.talking = false
		s.heave = 0.0
		s.rope = []
		s._t = 0.0
		s._thrown = false
	else:
		var h: Hikmet = a.node
		h.talking = false
		h._t = 0.0


## Eşya katmanına ait olmayan geçici düğümleri (araç, el eşyası, eski karenin artıkları) hemen siler
func _sweep(a: Act) -> void:
	var kill: Array = []
	for n in a.node.find_children("*", "Node", true, false):
		var id := n.get_instance_id()
		if a.base_ids.has(id) or a.item_ids.has(id):
			continue
		var par := n.get_parent()
		if par != null and (a.base_ids.has(par.get_instance_id()) or a.item_ids.has(par.get_instance_id())):
			kill.append(n)
	for n: Node in kill:
		if is_instance_valid(n) and n.get_parent() != null:
			n.get_parent().remove_child(n)
			n.free()
	if a.kind == "person":
		var p: Person = a.node
		p._tools.clear()
		p._tip = null


## Eşya kuruldu: o anki kalıcı olmayan bütün düğümler eşya sayılır (temizlik bunlara dokunmaz)
func _mark_items(a: Act) -> void:
	a.item_ids = {}
	for n in a.node.find_children("*", "Node", true, false):
		if not a.base_ids.has(n.get_instance_id()):
			a.item_ids[n.get_instance_id()] = true


func _set_act(a: Act, name: String) -> void:
	if a.kind == "person":
		(a.node as Person).set_activity(name)
	else:
		a.rig.activity = name


func _snap(a: Act) -> Array:
	var out: Array = []
	for n in a.pn:
		out.append(n.global_transform)
	return out


func _tick(a: Act, d: Dictionary, f: int) -> void:
	match str(d["t"]):
		"walk":
			a.node.position.z += float(d["v"]) * DT
		"act":
			if str(d["a"]) == "row":
				a.rig.row_phase = Rig.ROW_REST if d.has("rest") else fmod(float(f) * DT * 0.5, 1.0)
		"reach":
			var tgt: Vector3 = d["p"]
			Rig.reach(a.rig.arm_r, a.rig.elbow_r, a.node.global_transform * tgt, a.node.global_transform.basis * Vector3(0.6, -1.0, 0.0))
		"clip":
			var an: LimbAnim = d["_anim"]
			an.set("_k", 1.0)
			an.scrub(str(d["c"]), float(f) * DT)
			an.set("_k", 1.0)
			an._process(0.0)
		"emote":
			for tw in get_tree().get_processed_tweens():
				if tw.is_valid():
					tw.custom_step(DT)
	a.node._process(DT)
	if str(d["t"]) == "clip":
		var an2: LimbAnim = d["_anim"]
		an2.set("_k", 1.0)
		an2._process(0.0)


## Pozu sürer. Döner: {"snaps": Array (pencere kareleri), "frames": int}. stop: pencere karesi (kare modunda orada durur).
func _drive(a: Act, pname: String, stop := -1) -> Dictionary:
	_reset_pose(a)
	seed(_rng_seed)
	var d: Dictionary = (_pose_defs[pname] as Dictionary).duplicate()
	var t := str(d["t"])
	var settle := SETTLE
	var window := int(SPAN / DT)
	var is_person := a.kind == "person"
	if t in ["idle", "talk", "walk", "fidget", "emote", "reach"] and a.base_act != "":
		if a.base_act == "soldier_aim" and a.kind == "soldier":
			(a.node as Soldier).pose = "aim"
		elif a.base_act == "carry":
			_set_act(a, "carry")
	match t:
		"talk":
			if is_person:
				(a.node as Person).talking = true
			elif a.kind == "soldier":
				(a.node as Soldier).talking = true
			else:
				(a.node as Hikmet).talking = true
		"act":
			_set_act(a, str(d["a"]))
			if str(d["a"]) == "dead":
				a.node.rotation.x = -PI * 0.5
				a.node.position.y = 0.15
			elif str(d["a"]) == "fly":
				a.node.rotation.x = 1.2
		"fidget":
			a.rig._fid_kind = int(d["k"])
			a.rig._fid_left = 99.0
		"reach":
			a.rig.lock = 1
		"sold":
			if a.kind != "soldier":
				return {"snaps": [], "frames": 0}
			var s: Soldier = a.node
			match str(d["a"]):
				"soldier_aim": s.pose = "aim"
				"soldier_push": s.pose = "push"
				"haul":
					s.pose = "haul"
					s.rope = [Vector3(0.2, 1.0, 0.9), Vector3(0.0, 0.6, 4.0)]
					s.heave = 1.0
				_: s.pose = str(d["a"])
		"clip":
			if not is_person:
				return {"snaps": [], "frames": 0}
			if not LimbAnim.has_clip(str(d["c"])):
				return {"snaps": [], "frames": 0}
			a.rig.lock = 1
			var an := LimbAnim.new()
			a.node.add_child(an)
			an.set_process(false)
			an.bind(a.rig)
			an.fade = 0.001
			d["_anim"] = an
			window = int(LimbAnim.length(str(d["c"])) / DT) + 1
			settle = 2
	var snaps: Array = []
	var fr := 0
	# Oturma
	for i in settle:
		_tick(a, d, fr)
		fr += 1
	if t == "emote":
		settle = 0
		# Önce biraz boşta, sonra hareket
		if is_person:
			a.rig.emote(str(d["k"]))
		else:
			a.rig.emote(str(d["k"]))
		if is_person:
			_scan_items(a, a.item if a.item != "" else "el_eşyası")
		var n := 0
		while n < 170:
			_tick(a, d, fr)
			fr += 1
			snaps.append(_snap(a))
			n += 1
			if stop >= 0 and n > stop:
				break
			if a.rig.lock <= 0:
				break
		var res := {"snaps": snaps, "frames": n}
		if d.has("_anim"):
			(d["_anim"] as Node).queue_free()
		return res
	if t == "act" and is_person:
		_scan_items(a, a.item if a.item != "" else "araç")
	for i in window:
		_tick(a, d, fr)
		fr += 1
		snaps.append(_snap(a))
		if stop >= 0 and i >= stop:
			break
	if d.has("_anim"):
		(d["_anim"] as Node).queue_free()
	return {"snaps": snaps, "frames": snaps.size()}


# ---------------------------------------------------------------- değerlendirme

func _is_touch(pname: String, ci: Comp, cj: Comp) -> bool:
	var ri := ci.role
	var rj := cj.role
	var limb_i := ri == R_HAND or ri == R_FORE
	var limb_j := rj == R_HAND or rj == R_FORE
	if (ri == R_ITEM and limb_j) or (rj == R_ITEM and limb_i):
		return true
	if ri == R_ITEM and rj == R_ITEM and pname in ["whittle", "write", "write_desk", "read_ground", "emote:write", "emote:stir_cup", "emote:sip"]:
		return true
	var cls: Array = POSE_TOUCH.get(pname, [])
	if cls.is_empty():
		return false
	for k: String in cls:
		match k:
			"face":
				if (limb_i and rj in [R_SKULL, R_HAT, R_BEARD, R_EYES, R_BROWS, R_NECK]) or (limb_j and ri in [R_SKULL, R_HAT, R_BEARD, R_EYES, R_BROWS, R_NECK]):
					return true
			"body":
				if (limb_i and rj in [R_CORE, R_OUTER, R_CLOTH]) or (limb_j and ri in [R_CORE, R_OUTER, R_CLOTH]):
					return true
			"hands":
				if limb_i and limb_j:
					return true
			"legs":
				if (limb_i and rj in [R_THIGH, R_SHIN, R_CLOTH, R_FOOT]) or (limb_j and ri in [R_THIGH, R_SHIN, R_CLOTH, R_FOOT]):
					return true
	return false


## Dışarıdan görünmeyen iç içe geçiş (kusur değil, düşük poligon kuruluşu): sakal/bıyık kütlesi gövde üst kubbesinin içinde
## durur; gövdenin DIŞINA çıkıp görünen kısmı ölçülmez (sakal Person'da yukarı-öne alındı: çene/göğüs önünde görünür kalır).
static func _is_hidden(ci: Comp, cj: Comp) -> bool:
	var ri := ci.role
	var rj := cj.role
	return (ri == R_CORE and rj == R_BEARD) or (rj == R_CORE and ri == R_BEARD)


## Oyunda hiç oluşmayan eşya × poz birleşimi (denetimin ürettiği yapay birleşim): elinde eşya taşıyan karakter bu pozlara
## girmez (yük taşıyan yalnız dururken/konuşurken/yürürken/koşarken; Rig boşta kıpırdanmada eşyalıya kol hareketi vermez).
const ITEM_SYNTH_POSES := ["arms_folded", "hover", "fall", "lean_down", "halay", "stir", "throw_up", "emote:facepalm", "emote:laugh",
	"emote:arms_cross", "emote:lean", "emote:shrug", "emote:think", "emote:surprise", "emote:wave", "fidget:0", "fidget:1", "fidget:3"]
const LOAD_REAL_POSES := ["idle", "talk", "walk", "run"]


static func _synthetic_combo(item: String, pname: String) -> bool:
	if item == "" or item == "-":
		return false
	if item == "yerleşik":       # türün kendi eşyası (devriye mızrağı, şehir halkı yükü): yalnız eşyalının girmediği pozlar yapay
		return pname.begins_with("reach:") or pname in ITEM_SYNTH_POSES
	if item.begins_with("yük:"):
		return not pname in LOAD_REAL_POSES
	if pname.begins_with("reach:") or pname in ITEM_SYNTH_POSES:
		return true
	# Kılıç/yatağan Person'da yalnız düello klibinde (LimbAnim, katman L) tutulur; genel poz × kılıç oyunda oluşmaz
	if item.begins_with("kilij") or item.begins_with("spathion"):
		return not pname.begins_with("klip:")
	# Olta yalnız balıkçı rolünde (dururken/otururken/yürürken); tüfek yalnız nişanda/yürürken
	if item == "olta":
		return not pname in ["idle", "talk", "walk", "sit", "sit_ground"]
	if item == "tüfek":
		return not pname in ["idle", "talk", "walk", "run", "soldier_aim", "aim"]
	return false


static func _same_snap(x: Array, y: Array) -> bool:
	if x.size() != y.size():
		return false
	for i in x.size():
		var a: Transform3D = x[i]
		var b: Transform3D = y[i]
		if absf(a.origin.x - b.origin.x) + absf(a.origin.y - b.origin.y) + absf(a.origin.z - b.origin.z) > 0.0008:
			return false
		if absf(a.basis.x.x - b.basis.x.x) + absf(a.basis.x.y - b.basis.x.y) + absf(a.basis.y.x - b.basis.y.x) + absf(a.basis.y.y - b.basis.y.y) \
				+ absf(a.basis.z.x - b.basis.z.x) + absf(a.basis.z.y - b.basis.z.y) + absf(a.basis.x.z - b.basis.x.z) + absf(a.basis.y.z - b.basis.y.z) \
				+ absf(a.basis.z.z - b.basis.z.z) > 0.002:
			return false
	return true


## Bir adımdaki çift derinliği. Döner [derinlik (m), dünya noktası]
func _pair_depth(ci: Comp, cj: Comp, mode: int, sn: Array, xc: Dictionary) -> Array:
	var ti: Transform3D = sn[ci.piv]
	var tj: Transform3D = sn[cj.piv]
	var si := ti.basis.x.length()
	var sj := tj.basis.x.length()
	var key := ci.piv * 4096 + cj.piv
	var xij: Transform3D
	var xji: Transform3D
	if xc.has(key):
		xij = xc[key]
	else:
		xij = tj.affine_inverse() * ti
		xc[key] = xij
	var kb := cj.piv * 4096 + ci.piv
	if xc.has(kb):
		xji = xc[kb]
	else:
		xji = ti.affine_inverse() * tj
		xc[kb] = xji
	if mode == 2:
		# Kumaş: kesme derinliği = min(içine giren, dışarıda kalan)
		if ci.role == R_CLOTH:
			var r := _cloth_cross(cj.pts, xji, ci) if ci.shape == S_CYL else _pts_in(cj.pts, xji, ci)
			if _opt.has("pdc"):
				print("PDC cloth=%s other=%s r=%s" % [ci.dims, _label(cj), r])
			return [maxf(minf(r[0], r[1]), 0.0) * si, tj * (r[2] as Vector3)]
		var r2 := _cloth_cross(ci.pts, xij, cj) if cj.shape == S_CYL else _pts_in(ci.pts, xij, cj)
		return [maxf(minf(r2[0], r2[1]), 0.0) * sj, ti * (r2[2] as Vector3)]
	if _depth(cj, xij * ci.bc) * sj < -ci.br * si * 1.3 and _depth(ci, xji * cj.bc) * si < -cj.br * sj * 1.3:
		return [0.0, Vector3.ZERO]
	var r1 := _pts_in(ci.pts, xij, cj)
	var r2b := _pts_in(cj.pts, xji, ci)
	var d1: float = r1[0] * sj
	var d2: float = r2b[0] * si
	if cj.thin >= 0:
		d1 = maxf(d1, _thin_push(ci.pts, xij, cj, ci.hmin) * sj)
	if ci.thin >= 0:
		d2 = maxf(d2, _thin_push(cj.pts, xji, ci, cj.hmin) * si)
	if _opt.has("pd") and maxf(d1, d2) >= DEPTH_MIN:
		print("PD %s <-> %s  d1=%.3f d2=%.3f  wc_i=%s wc_j=%s at1=%s at2=%s" % [_label(ci), _label(cj), d1, d2, ti * ci.bc, tj * cj.bc, ti * (r1[2] as Vector3), tj * (r2b[2] as Vector3)])
		print("   ci: %s c=%s h=%s k=%d s=%d" % [ci.dims, ci.c, ci.h, ci.k, ci.shape])
		print("   cj: %s c=%s h=%s k=%d s=%d" % [cj.dims, cj.c, cj.h, cj.k, cj.shape])
	if d1 >= d2:
		return [d1, ti * (r1[2] as Vector3)]
	return [d2, tj * (r2b[2] as Vector3)]


## Bir pozun değerlendirmesi. Döner: { "etiket_a|etiket_b|temas": {d, n, step, wp, tag} }
func _eval(a: Act, pname: String, snaps: Array) -> Dictionary:
	var out := {}
	if snaps.is_empty():
		return out
	var idxs: Array = []
	for i in STEPS:
		idxs.append(roundi(float(i) * float(snaps.size() - 1) / float(STEPS - 1)))
	var pairs: Array = a.base_pairs.duplicate()
	var nb := a.n_base_comps
	var nc := a.comps.size()
	if nc > nb:
		pairs.append_array(_pairs(a, nb, nc, nb, nc))
		for i in range(nb, nc):
			var ci: Comp = a.comps[i]
			for j in nb:
				var m := _pair_ok(ci, a.comps[j])
				if m != 0:
					pairs.append(Vector3i(j, i, m))
	var labels: Array = []
	for c: Comp in a.comps:
		labels.append(_label(c))
	var prev_sn: Array = []
	var prev_res := {}
	var first := true
	for s in idxs.size():
		var sn: Array = snaps[idxs[s]]
		var step_res := {}
		if not first and _same_snap(sn, prev_sn):
			step_res = prev_res
			_skip_static += 1
		else:
			var wc := PackedVector3Array()
			var wr := PackedFloat32Array()
			wc.resize(nc)
			wr.resize(nc)
			for i in nc:
				var ci: Comp = a.comps[i]
				var tf: Transform3D = sn[ci.piv]
				wc[i] = tf * ci.bc
				wr[i] = ci.br * tf.basis.x.length()
			var xc := {}
			for pr: Vector3i in pairs:
				var i := pr.x
				var j := pr.y
				var rr := wr[i] + wr[j]
				if wc[i].distance_squared_to(wc[j]) > rr * rr:
					continue
				var ci: Comp = a.comps[i]
				var cj: Comp = a.comps[j]
				var res := _pair_depth(ci, cj, pr.z, sn, xc)
				var dep: float = res[0]
				if dep < DEPTH_MIN:
					continue
				var la: String = labels[i]
				var lb: String = labels[j]
				var ia := i
				var ib := j
				if la > lb:
					var tmp := la
					la = lb
					lb = tmp
					ia = j
					ib = i
				var tag := "temas" if _is_touch(pname, ci, cj) else ("gorunmez" if _is_hidden(ci, cj) else "")
				var k := la + "|" + lb + "|" + tag
				if not step_res.has(k) or step_res[k]["d"] < dep:
					step_res[k] = {"d": dep, "wp": res[1], "tag": tag, "a": la, "b": lb, "ia": ia, "ib": ib}
		for k: String in step_res:
			var r: Dictionary = step_res[k]
			if not out.has(k):
				out[k] = {"d": 0.0, "n": 0, "step": 0, "wp": Vector3.ZERO, "tag": r["tag"], "a": r["a"], "b": r["b"], "ia": 0, "ib": 0}
			out[k]["n"] += 1
			if r["d"] > out[k]["d"]:
				out[k]["d"] = r["d"]
				out[k]["step"] = s
				out[k]["wp"] = r["wp"]
				out[k]["ia"] = r["ia"]
				out[k]["ib"] = r["ib"]
		prev_sn = sn
		prev_res = step_res
		first = false
	for k: String in out:
		out[k]["idx"] = idxs[out[k]["step"]]
	return out


# ---------------------------------------------------------------- çalıştırma

func _item_label(a: Act) -> String:
	return a.item if a.item != "" else "-"


func _record(a: Act, pname: String, res: Dictionary) -> void:
	var any_bad := false
	var any_touch := false
	for k: String in res:
		var r: Dictionary = res[k]
		var oran := int(round(100.0 * float(r["n"]) / float(STEPS)))
		var tagname := "TEMAS" if r["tag"] == "temas" else ("GÖRÜNMEZ" if r["tag"] == "gorunmez" else "OVERLAP")
		if tagname == "OVERLAP" and (str(r["a"]).begins_with("eşya:") or str(r["b"]).begins_with("eşya:")) and _synthetic_combo(a.item, pname):
			tagname = "OYUNDIŞI"
		if tagname == "OVERLAP":
			any_bad = true
		elif tagname == "TEMAS":
			any_touch = true
		var rec := {"cls": tagname, "tur": a.tname, "key": str(a.spec.get("key", "")), "poz": pname, "esya": _item_label(a), "a": r["a"], "b": r["b"],
			"d": r["d"], "oran": oran, "step": r["idx"], "wp": r["wp"], "kind": a.kind}
		_recs.append(rec)
		var line := "%s tür=%s poz=%s eşya=%s a=%s b=%s derinlik=%.1fcm oran=%d%%" % [tagname, a.tname, pname, _item_label(a), r["a"], r["b"],
			r["d"] * 100.0, oran]
		if not _quiet:
			print(line)
		if _tsv != null:
			var wp: Vector3 = r["wp"]
			_tsv.store_line("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.4f\t%d\t%d\t%.3f\t%.3f\t%.3f\t%s\t%s" % [tagname, a.tname, a.spec.get("key", ""), pname,
				_item_label(a), r["a"], r["b"], r["d"], oran, r["idx"], wp.x, wp.y, wp.z, _desc(a, r["ia"]), _desc(a, r["ib"])])
	_n_combo += 1
	if any_bad:
		_n_bad += 1
	if any_touch:
		_n_touch_combo += 1


func _run_combo(a: Act, pname: String) -> void:
	var t0 := Time.get_ticks_msec()
	var dr := _drive(a, pname)
	var snaps: Array = dr["snaps"]
	if snaps.is_empty():
		return
	var res := _eval(a, pname, snaps)
	_eval_ms += Time.get_ticks_msec() - t0
	_record(a, pname, res)


func _want(kind: String, name: String) -> bool:
	if not _opt.has(kind):
		return true
	return name in str(_opt[kind]).split(",")


func _generic_poses(a: Act) -> Array:
	var out: Array = []
	for k: String in _pose_defs:
		var d: Dictionary = _pose_defs[k]
		var t := str(d["t"])
		if t == "sold" or t == "clip":
			continue
		out.append(k)
	return out


func _run() -> void:
	var t_start := Time.get_ticks_msec()
	_collect_types()
	print("OVERLAP tür sayısı=%d" % _types.size())
	if _opt.has("list"):
		for t: Dictionary in _types:
			print("TÜR %s | anahtar=%s | sınıf=%s | benzer görünüş=%d: %s" % [t["name"], t["key"], t["cls"], (t["alias"] as Array).size(),
				", ".join((t["alias"] as Array).slice(0, 12))])
		get_tree().quit()
		return
	if _opt.has("shots"):
		await _shots(str(_opt["shots"]))
		get_tree().quit()
		return
	if _opt.has("out"):
		_tsv = FileAccess.open(str(_opt["out"]), FileAccess.WRITE)
		_tsv.store_line("sınıf\ttür\tanahtar\tpoz\teşya\ta\tb\tderinlik_m\toran\tadım_kare\tx\ty\tz\tparça_a\tparça_b")
	var layer := str(_opt.get("layer", "ALL"))
	var limit := int(_opt.get("limit", 0))
	var shard_i := 0
	var shard_n := 1
	if _opt.has("shard"):
		var sp := str(_opt["shard"]).split("/")
		shard_i = int(sp[0])
		shard_n = int(sp[1])
	var counter := 0
	# --- Katman A: bütün türler × bütün pozlar (eşyasız / yerleşik eşya)
	if layer in ["A", "ALL"]:
		for t: Dictionary in _types:
			counter += 1
			if counter % shard_n != shard_i or not _want("types", str(t["name"])):
				continue
			var a := await _build_act(t)
			if a == null:
				continue
			if _opt.has("dump"):
				_dump(a)
			var plist: Array = t.get("poses", _generic_poses(a))
			if a.item != "":
				plist = (SOLDIER_ITEM_POSES if a.kind == "soldier" else ITEM_POSES).duplicate()      # yerleşik eşyası olanlar: eşyayla anlamlı pozlar
			if str(t["cls"]) == "soldier":
				plist = plist + SOLDIER_POSES
			for pn: String in plist:
				if not _want("poses", pn):
					continue
				_run_combo(a, pn)
				if limit > 0 and _n_combo >= limit:
					break
			_free_act(a)
			print("TÜR bitti: %s (kombinasyon=%d sorunlu=%d, %.0f sn)" % [t["name"], _n_combo, _n_bad, (Time.get_ticks_msec() - t_start) / 1000.0])
			if limit > 0 and _n_combo >= limit:
				break
	# --- Katman B: gövde türleri × eşyalar × pozlar
	if layer in ["B", "ALL"] and not (limit > 0 and _n_combo >= limit):
		for t: Dictionary in _types:
			var nm := str(t["name"])
			var is_item_type := nm in ITEM_TYPES or str(t["cls"]) == "soldier" and str(t["hat"]) in ["bork", "helm", "turban"]
			if not is_item_type:
				continue
			counter += 1
			if counter % shard_n != shard_i or not _want("types", nm):
				continue
			var a := await _build_act(t)
			if a == null:
				continue
			var items: Array = SOLDIER_ITEMS if a.kind == "soldier" else PERSON_ITEMS
			for it: String in items:
				if not _want("items", it):
					continue
				_clear_items(a)
				_reset_pose(a)
				_apply_item(a, it)
				var plist: Array = SOLDIER_ITEM_POSES if a.kind == "soldier" else ITEM_POSES
				if it.begins_with("yük:"):
					plist = ["idle", "talk", "walk", "run", "emote:bow", "emote:lean", "emote:shrug", "emote:surprise", "fidget:0"]
				for pn: String in plist:
					if not _want("poses", pn):
						continue
					_run_combo(a, pn)
					if limit > 0 and _n_combo >= limit:
						break
				if limit > 0 and _n_combo >= limit:
					break
			_free_act(a)
			print("EŞYA TÜRÜ bitti: %s (kombinasyon=%d sorunlu=%d, %.0f sn)" % [nm, _n_combo, _n_bad, (Time.get_ticks_msec() - t_start) / 1000.0])
			if limit > 0 and _n_combo >= limit:
				break
	# --- Katman L: LimbAnim klipleri × kılıç/kalkan
	if layer in ["L", "ALL"] and not (limit > 0 and _n_combo >= limit):
		for t: Dictionary in _types:
			var nm := str(t["name"])
			if not nm in ITEM_TYPES:
				continue
			counter += 1
			if counter % shard_n != shard_i or not _want("types", nm):
				continue
			var a := await _build_act(t)
			if a == null:
				continue
			for it: String in CLIP_ITEMS:
				if not _want("items", it if it != "" else "-"):
					continue
				_clear_items(a)
				_reset_pose(a)
				_apply_item(a, it)
				for c: String in CLIPS:
					if not _want("poses", "klip:" + c):
						continue
					_run_combo(a, "klip:" + c)
					if limit > 0 and _n_combo >= limit:
						break
				if limit > 0 and _n_combo >= limit:
					break
			_free_act(a)
			print("KLİP TÜRÜ bitti: %s (kombinasyon=%d sorunlu=%d, %.0f sn)" % [nm, _n_combo, _n_bad, (Time.get_ticks_msec() - t_start) / 1000.0])
			if limit > 0 and _n_combo >= limit:
				break
	_summary(t_start)
	if _tsv != null:
		_tsv.close()
	get_tree().quit()


func _free_act(a: Act) -> void:
	for tw in get_tree().get_processed_tweens():
		tw.kill()
	a.node.queue_free()


func _summary(t_start: int) -> void:
	var bad: Array = []
	var touch: Array = []
	var bad_combos := {}
	for r: Dictionary in _recs:
		if r["cls"] == "OVERLAP":
			bad.append(r)
		else:
			touch.append(r)
	bad.sort_custom(func(x, y): return x["d"] * float(x["oran"]) > y["d"] * float(y["oran"]))
	print("OVERLAP-ÖZET kayıt=%d temas_kaydı=%d" % [bad.size(), touch.size()])
	print("OVERLAP-ÖZET en kötü 40 (derinlik × oran sırasıyla):")
	for i in mini(40, bad.size()):
		var r: Dictionary = bad[i]
		print("  #%d tür=%s poz=%s eşya=%s a=%s b=%s derinlik=%.1fcm oran=%d%%" % [i + 1, r["tur"], r["poz"], r["esya"], r["a"], r["b"],
			r["d"] * 100.0, r["oran"]])
	print("OVERLAP-ÖZET en kötü 40, her (a, b, eşya) çifti en çok bir kez (kök neden çeşitliliği):")
	var seen := {}
	var shown := 0
	for r: Dictionary in bad:
		var key := "%s|%s|%s" % [r["a"], r["b"], "" if r["esya"] in ["-", "yerleşik"] else r["esya"]]
		if seen.has(key):
			continue
		seen[key] = true
		shown += 1
		print("  #%d tür=%s poz=%s eşya=%s a=%s b=%s derinlik=%.1fcm oran=%d%%" % [shown, r["tur"], r["poz"], r["esya"], r["a"], r["b"],
			r["d"] * 100.0, r["oran"]])
		if shown >= 40:
			break
	print("OVERLAP-ÖZET süre: kurulum=%d ms, sürüş+değerlendirme=%d ms, toplam=%.0f sn, durağan adım atlandı=%d" % [_fit_ms, _eval_ms,
		(Time.get_ticks_msec() - t_start) / 1000.0, _skip_static])
	print("OVERLAPCHECK DONE combos=%d bad=%d touch_combos=%d" % [_n_combo, _n_bad, _n_touch_combo])



func _dump(a: Act) -> void:
	print("DUMP %s parça=%d (taban %d) düğüm=%d" % [a.tname, a.comps.size(), a.n_base_comps, a.pn.size()])
	for i in a.comps.size():
		var c: Comp = a.comps[i]
		print("  [%d] %s piv=%s %s c=(%.2f,%.2f,%.2f) res=%.3f ex=%d thin=%d br=%.2f %s" % [i, _label(c), a.pn[c.piv].name, c.dims, c.c.x, c.c.y, c.c.z, c.res,
			0, c.thin, c.br, c.label])


func _desc(a: Act, i: int) -> String:
	if i < 0 or i >= a.comps.size():
		return "?"
	var c: Comp = a.comps[i]
	return "#%d %s %s c=(%.2f,%.2f,%.2f) piv=%s" % [i, _label(c), c.dims, c.c.x, c.c.y, c.c.z, a.pn[c.piv].name]


# ---------------------------------------------------------------- kare modu

func _stage() -> Camera3D:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("a9c4dc")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("dfe6ee")
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 35, 0)
	sun.light_energy = 1.1
	add_child(sun)
	var sun2 := DirectionalLight3D.new()
	sun2.rotation_degrees = Vector3(-30, -150, 0)
	sun2.light_energy = 0.5
	add_child(sun2)
	Props.box(self, Vector3(40, 0.2, 40), Vector3(0, -0.1, 0), Color("7a8466"))
	var cam := Camera3D.new()
	cam.fov = 40.0
	cam.current = true
	add_child(cam)
	return cam


func _grab(cam: Camera3D, pos: Vector3, look: Vector3, size: int) -> Image:
	cam.global_position = pos
	cam.look_at(look, Vector3.UP)
	await get_tree().process_frame
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var w := img.get_width()
	var h := img.get_height()
	var side := mini(w, h)
	var crop := img.get_region(Rect2i((w - side) / 2, (h - side) / 2, side, side))
	crop.resize(size, size, Image.INTERPOLATE_BILINEAR)
	return crop


## Dosya satırı: no|tür|poz|eşya|kare|çıkış.png|x|y|z
func _shots(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		print("OVERLAP kare dosyası açılamadı: ", path)
		return
	var cam := _stage()
	var marker := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.012
	sm.height = 0.024
	marker.mesh = sm
	var mm := StandardMaterial3D.new()
	mm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mm.albedo_color = Color(1.0, 0.1, 0.8)
	mm.no_depth_test = true
	marker.material_override = mm
	marker.visible = false
	add_child(marker)
	var last_key := ""
	var a: Act = null
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line == "":
			continue
		var c := line.split("|")
		var tname := c[1]
		var pname := c[2]
		var item := c[3]
		var frame := int(c[4])
		var out := c[5]
		var wp := Vector3(float(c[6]), float(c[7]), float(c[8]))
		var tspec: Dictionary = {}
		for t: Dictionary in _types:
			if str(t["name"]) == tname:
				tspec = t
		if tspec.is_empty():
			print("OVERLAP kare: tür yok ", tname)
			continue
		var key := tname + "|" + item
		if key != last_key:
			if a != null:
				_free_act(a)
				await get_tree().process_frame
			tspec = tspec.duplicate()
			a = await _build_act(tspec)
			last_key = key
			if item != "-" and item != "yerleşik" and item != "":
				_clear_items(a)
				_reset_pose(a)
				_apply_item(a, item)
		var dr := _drive(a, pname, frame)
		for tw in get_tree().get_processed_tweens():
			tw.pause()
		var imgs: Array = []
		marker.visible = false
		if wp.x > 900.0:
			# Gövde modu (x=999): wp.y = bakılan yükseklik, wp.z = uzaklık. Önden, yandan, üç-çeyrek, önden yakın.
			var bc := Vector3(a.node.global_position.x, wp.y, a.node.global_position.z)
			var dd := wp.z
			imgs.append(await _grab(cam, bc + Vector3(0, 0.1, dd), bc, 400))
			imgs.append(await _grab(cam, bc + Vector3(dd, 0.1, 0), bc, 400))
			imgs.append(await _grab(cam, bc + Vector3(dd * 0.7, 0.3, dd * 0.7), bc, 400))
			imgs.append(await _grab(cam, bc + Vector3(-dd * 0.7, 0.3, dd * 0.7), bc, 400))
			var sheet2 := Image.create(1600, 400, false, Image.FORMAT_RGB8)
			for i in 4:
				var im2: Image = imgs[i]
				im2.convert(Image.FORMAT_RGB8)
				sheet2.blit_rect(im2, Rect2i(0, 0, 400, 400), Vector2i(i * 400, 0))
			sheet2.save_png(out)
			print("KARE %s -> %s (gövde, kare=%d)" % [line.get_slice("|", 0), out, frame])
			continue
		var out_dir := Vector3(wp.x, 0.0, wp.z)
		if out_dir.length() < 0.12:
			out_dir = Vector3(0, 0, 1)
		out_dir = out_dir.normalized()
		var side_dir := Vector3(1, 0, 0) if wp.x >= -0.02 else Vector3(-1, 0, 0)
		var base := a.node.global_position
		imgs.append(await _grab(cam, wp + Vector3(0, 0.1, 1.9), wp, 400))
		imgs.append(await _grab(cam, wp + side_dir * 1.9 + Vector3(0, 0.1, 0), wp, 400))
		imgs.append(await _grab(cam, wp + out_dir * 0.7 + Vector3(0, 0.12, 0), wp, 400))
		marker.global_position = wp
		marker.visible = true
		imgs.append(await _grab(cam, wp + out_dir * 0.7 + Vector3(0, 0.12, 0), wp, 400))
		marker.visible = false
		var sheet := Image.create(1600, 400, false, Image.FORMAT_RGB8)
		for i in 4:
			var im: Image = imgs[i]
			im.convert(Image.FORMAT_RGB8)
			sheet.blit_rect(im, Rect2i(0, 0, 400, 400), Vector2i(i * 400, 0))
		sheet.save_png(out)
		print("KARE %s -> %s (kare=%d, nokta=%s)" % [line.get_slice("|", 0), out, frame, wp])
	if a != null:
		_free_act(a)
