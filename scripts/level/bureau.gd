class_name Bureau
extends Node3D


## Oturanın katmanlı dönüşü. Rig'de ayrı bel eklemi yok (bacaklar, kaftan ve baş tek _body düğümünün çocuğu) ve
## Person.look_target bütün kişiyi çevirir: oturan konuşana dönünce kalçası ve bacakları bankın içinden geçiyordu.
## Burada kişi kökü sabit kalır (kalça bankta); gövde (_body) belirgin döner, bacaklar gövdeye ters yönde kısmen
## karşılanır (dizler azıcık kayar), baş kalan açıyı tamamlar. Person._process'ten SONRA çalışır (çocuk düğüm).
class SeatTwist extends Node:
	var target: Node3D
	var rest_yaw := 0.0         # kökün (kalçanın) bakışı, radyan
	var max_torso := 0.75       # gövdenin en çok dönüşü (~43 derece)
	var max_head := 1.2         # başın gövdeye göre en çok dönüşü
	var astride := false        # ters oturan: önünde sırtlık var, dönerken gövde biraz geri çekilir
	var _torso := 0.0
	var _head := 0.0

	func _process(delta: float) -> void:
		var p := get_parent() as Person
		if p == null or p._body == null or p._head == null:
			return
		var tt := 0.0
		var ht := 0.0
		if is_instance_valid(target):
			var to := target.global_position - p.global_position
			if p.get_parent() is Node3D:
				to = (p.get_parent() as Node3D).global_transform.basis.inverse() * to
			if Vector2(to.x, to.z).length() > 0.1:
				var rel := wrapf(atan2(to.x, to.z) - rest_yaw, -PI, PI)
				tt = clampf(rel * 0.7, -max_torso, max_torso)
				ht = clampf(rel - tt, -max_head, max_head)
		elif absf(_torso) < 0.01 and absf(_head) < 0.01:
			_torso = 0.0
			_head = 0.0
			return
		var k := 1.0 - exp(-3.2 * delta)
		_torso = lerpf(_torso, tt, k)
		_head = lerpf(_head, ht, k)
		p._body.rotation.y = _torso
		p._body.position.z = (-0.09 if astride else 0.06) * absf(_torso) / max_torso
		p._head.rotation.y = _head
		for leg: Node3D in [p._leg_l, p._leg_r]:
			if leg:
				leg.rotation.y = -_torso * 0.8
## Zaman Bürosu: zamanın dışında duran bir devlet dairesi (CHAPTERS §3.2, Bölüm 3).
## Nihat'ın odası (Form Z-1, akrepsiz saat, hiçliğe bakan pencere), sise gömülüp
## sonsuza uzanan koridor (her kapıda bir yıl), kostüm deposu, Başdenetçi'nin
## kâğıt dağları arasındaki masası ve saha asansörü.

const OFFICE_W := 6.0
const OFFICE_D := 6.0
const OFFICE_H := 3.0
const COR_W := 4.0
const COR_H := 3.4
const COR_LEN := 84.0
const DEPOT_Z0 := -10.5
const DEPOT_Z1 := -17.5
const DESK_Z := -26.0
const LIFT_Z := -34.0

const SPAWN_POS := Vector3(0.0, 0.0, 1.6)
## Saha asansörü (v0.99.6): Nihat tarih panelinin yanında, yolcu kabinin ortasında
## (Nihat açıklığın kenarında: kabindeki yolcu onu açıklıktan görür; açık kapı kanadı duvarın içine kayar)
const NIHAT_PANEL_POS := Vector3(-1.25, 0.0, -33.25)
const LIFT_IN := Vector3(-2.75, 0.0, -34.0)
const LIFT_FRONT := Vector3(0.4, 0.0, -34.0)
const LIFT_OUT := Vector3(-0.55, 0.0, -34.15)
const PANEL_POS := Vector3(-1.9, 1.32, -32.75)
const NIHAT_OFFICE_POS := Vector3(1.5, 0.0, 3.3)   # ofiste Nihat: masanın sağ önü, kapıdan girenin karşısında
const DESK_X := 4.4          # Başdenetçi masası artık koridorun doğusundaki odasında (koridorun ortasındaydı)
const MUFIDE_POS := Vector3(DESK_X + 1.0, 0.0, DESK_Z)
## Ziyaretçinin durduğu yer: masanın önü (masa koridora, -x'e bakar; ortadaki kâğıt yığınları alçak)
const VISITOR_POS := Vector3(DESK_X - 1.1, 0.0, DESK_Z)
const RIZA_POS := Vector3(4.3, 0.0, -14.0)

const C_WALL := Color("7d8a78")
const C_WALL_LOW := Color("5d6b5c")
const C_WOOD := Color("7a4f30")
const C_WOOD_DARK := Color("5a3820")
const C_BRASS := Color("c49a45")
const C_PAPER := Color("efe9d8")
const C_METAL := Color("8b939a")

const YEARS := ["MÖ 2560", "MÖ 776", "MÖ 44", "1215", "1347", "1453", "1455", "1492", "1517", "1687", "1769", "1789",
	"1815", "1903", "1914", "1945", "1969", "1989", "2026", "2150"]

var mufide: Person
var riza: Person
var file_node: Node3D
var capsule: Node3D
var fedora_node: Node3D
var lift_door: Node3D
var lift_dial: Label3D        # koridordaki kat göstergesi (◀ 1453 ▶): Nihat'ın kadranıyla döner
var lift_dial_in: Label3D     # kabinin içindeki gösterge: kapı kapanınca yolcunun karşısında
var lift_light: OmniLight3D
var lift_open := false
var panel_wheel: Node3D       # tarih panelinin çarkı
var env_node: WorldEnvironment

# ---------------------------------------------------------------- v0.99.96 yeniden tasarım: ortak altyapı
# Büro eskiden düz yeşil bir kutuydu (oynanış denetimi: "en sıkıcı yer"). Artık gezilecek bir daire: çay ocağı, bekleme
# salonu, kayıp zaman bürosu, arşiv, şikâyet masası, müdür kapısı, atrium ve zamanın dışına bakan pencereler; çağ ışığı
# sızan aralık kapılar, tüplerde uçan kapsüller, memurlar. Etkileşimler Büro'nun kendisinde (bölümlere dokunmadan):
# _reg ile kaydedilen "bur_" kimlikleri oyuncunun sinyallerinden yakalanır.
const C_CREAM := Color("e9dcb8")
const C_TEAL := Color("3f6f68")
const C_COR_WALL := Color("d8caa0")
const C_COR_LOW := Color("4d7c6e")
const C_RUG := Color("7c2f2c")
const C_RUG_EDGE := Color("d9a84a")
const C_MUSTARD := Color("d9a22e")
const C_ORANGE := Color("d9702a")
const C_WALNUT := Color("3a2218")
const C_CEIL := Color("e8e0c8")
## Koridorun açıklıkları (oda kapıları): [z_üst, z_alt] (z_üst > z_alt). Batı (-x) ve doğu (+x) duvarları buralarda açık.
const OPEN_W := [[-4.2, -8.6], [-15.3, -18.7], [-27.3, -31.2], [-33.0, -35.0]]       # bekleme, arşiv, şikâyet, asansör
const OPEN_E := [[-2.2, -7.0], [-10.5, -17.5], [-19.0, -23.4], [-25.0, -28.5], [-29.2, -31.2], [-36.5, -55.5]]   # çay, depo, kayıp, başdenetçi, müdür, atrium
## Yıllı kapılar: [taraf, z, yıl]. 1492 doğuda z -8.5'te kalır (Bölüm 13 önüne birini koyar); 1453, 1923, 2026 şart (Bölüm 3).
## Kapılar dünya tarihinin dönüm noktaları, ofisten koridorun sonuna kronolojik (v0.99.101; eskiden çoğu Türk tarihiydi:
## 1071, 1299, 1453 üç kez, 1683 iki kez). Her kapının ardında o olayın minyatür sahnesi (DoorScenes).
const DOORS := [[1, -8.5, "MÖ 2560"], [-1, -12.25, "MÖ 776"], [-1, -25.5, "MÖ 44"], [-1, -38.0, "1215"], [-1, -42.5, "1347"],
	[-1, -47.0, "1453"], [-1, -51.5, "1455"], [-1, -56.0, "1492"], [1, -58.5, "1517"], [-1, -60.5, "1687"], [1, -63.0, "1769"],
	[-1, -65.0, "1789"], [1, -67.5, "1815"], [-1, -69.5, "1903"], [1, -72.0, "1914"], [-1, -74.0, "1945"], [1, -76.5, "1969"],
	[-1, -78.5, "1989"], [1, -81.0, "2026"], [-1, -82.0, "2150"]]
const ERA_COLORS := {"MÖ 2560": Color("e8c070"), "MÖ 776": Color("ffe090"), "MÖ 44": Color("f0e8d8"), "1215": Color("9a7ad8"),
	"1347": Color("7a9a6a"), "1453": Color("ff6a2a"), "1455": Color("e8b878"), "1492": Color("5ab0e8"), "1517": Color("c8883a"),
	"1687": Color("8ad860"), "1769": Color("b0a090"), "1789": Color("cc4a4a"), "1815": Color("6a8ac8"), "1903": Color("f0d890"),
	"1914": Color("9a9aa0"), "1945": Color("e8e0c0"), "1969": Color("d8e8ff"), "1989": Color("e83a8a"), "2026": Color("6ad0ff"),
	"2150": Color("ff40d0")}

## Konuşan: oyuncu Nihat'ken nesne replikleri onun sesiyle; başka biri (Bölüm 13/17) Büro'daysa nesneler sessiz kalır,
## memurlar yine konuşur.
## Seslendirme eşlemesi (tools/voice_map.py okur): _say(anahtar, sn, konuşan) çağrıları desenle yakalanmıyor
const _BUR_VOICE := [
	["SPK_NAPOLEON", "BUR_AMB_G1_4_1"], ["SPK_GENGHIS", "BUR_AMB_G1_4_2"], ["SPK_NAPOLEON", "BUR_AMB_G1_4_3"], ["SPK_GENGHIS", "BUR_AMB_G1_5_1"],
	["SPK_NAPOLEON", "BUR_AMB_G1_5_2"], ["SPK_GENGHIS", "BUR_AMB_G1_5_3"], ["SPK_NAPOLEON", "BUR_AMB_G1_6_1"], ["SPK_GENGHIS", "BUR_AMB_G1_6_2"],
	["SPK_NAPOLEON", "BUR_AMB_G1_6_3"], ["SPK_GENGHIS", "BUR_AMB_G1_7_1"], ["SPK_NAPOLEON", "BUR_AMB_G1_7_2"], ["SPK_GENGHIS", "BUR_AMB_G1_7_3"],
	["SPK_NAPOLEON", "BUR_AMB_G1_8_1"], ["SPK_GENGHIS", "BUR_AMB_G1_8_2"], ["SPK_NAPOLEON", "BUR_AMB_G1_8_3"], ["SPK_GENGHIS", "BUR_AMB_G1_9_1"],
	["SPK_NAPOLEON", "BUR_AMB_G1_9_2"], ["SPK_GENGHIS", "BUR_AMB_G1_9_3"], ["SPK_NAPOLEON", "BUR_AMB_G1_9_4"], ["SPK_ROBOT", "BUR_AMB_G2_4_1"],
	["SPK_HITLER", "BUR_AMB_G2_4_2"], ["SPK_ROBOT", "BUR_AMB_G2_4_3"], ["SPK_NAPOLEON", "BUR_AMB_G2_5_1"], ["SPK_ROBOT", "BUR_AMB_G2_5_2"],
	["SPK_HITLER", "BUR_AMB_G2_5_3"], ["SPK_HITLER", "BUR_AMB_G2_6_1"], ["SPK_ROBOT", "BUR_AMB_G2_6_2"], ["SPK_HITLER", "BUR_AMB_G2_6_3"],
	["SPK_ROBOT", "BUR_AMB_G2_6_4"], ["SPK_ROBOT", "BUR_AMB_G2_7_1"], ["SPK_HITLER", "BUR_AMB_G2_7_2"], ["SPK_ROBOT", "BUR_AMB_G2_7_3"],
	["SPK_NAPOLEON", "BUR_AMB_G2_8_1"], ["SPK_HITLER", "BUR_AMB_G2_8_2"], ["SPK_ROBOT", "BUR_AMB_G2_8_3"], ["SPK_ROBOT", "BUR_AMB_G2_9_1"],
	["SPK_HITLER", "BUR_AMB_G2_9_2"], ["SPK_ROBOT", "BUR_AMB_G2_9_3"], ["SPK_MARCOPOLO", "BUR_AMB_G3_3_1"], ["SPK_GALILEO", "BUR_AMB_G3_3_2"],
	["SPK_MARCOPOLO", "BUR_AMB_G3_3_3"], ["SPK_MARCOPOLO", "BUR_AMB_G3_4_1"], ["SPK_GALILEO", "BUR_AMB_G3_4_2"], ["SPK_MARCOPOLO", "BUR_AMB_G3_4_3"],
	["SPK_MARCOPOLO", "BUR_AMB_G3_5_1"], ["SPK_GALILEO", "BUR_AMB_G3_5_2"], ["SPK_MARCOPOLO", "BUR_AMB_G3_5_3"], ["SPK_GALILEO", "BUR_AMB_G3_6_1"],
	["SPK_MARCOPOLO", "BUR_AMB_G3_6_2"], ["SPK_GALILEO", "BUR_AMB_G3_6_3"], ["SPK_GALILEO", "BUR_AMB_G3_7_1"], ["SPK_MARCOPOLO", "BUR_AMB_G3_7_2"],
	["SPK_GALILEO", "BUR_AMB_G3_7_3"], ["SPK_MARCOPOLO", "BUR_AMB_G3_8_1"], ["SPK_GALILEO", "BUR_AMB_G3_8_2"], ["SPK_MARCOPOLO", "BUR_AMB_G3_8_3"],
	["SPK_MOZART", "BUR_AMB_G4_3_1"], ["SPK_CURIE", "BUR_AMB_G4_3_2"], ["SPK_MOZART", "BUR_AMB_G4_3_3"], ["SPK_CURIE", "BUR_AMB_G4_4_1"],
	["SPK_MOZART", "BUR_AMB_G4_4_2"], ["SPK_CURIE", "BUR_AMB_G4_4_3"], ["SPK_MOZART", "BUR_AMB_G4_5_1"], ["SPK_CURIE", "BUR_AMB_G4_5_2"],
	["SPK_MOZART", "BUR_AMB_G4_5_3"], ["SPK_CURIE", "BUR_AMB_G4_6_1"], ["SPK_MOZART", "BUR_AMB_G4_6_2"], ["SPK_CURIE", "BUR_AMB_G4_6_3"],
	["SPK_MOZART", "BUR_AMB_G4_7_1"], ["SPK_CURIE", "BUR_AMB_G4_7_2"], ["SPK_MOZART", "BUR_AMB_G4_7_3"], ["SPK_MOZART", "BUR_AMB_G4_8_1"],
	["SPK_CURIE", "BUR_AMB_G4_8_2"], ["SPK_MOZART", "BUR_AMB_G4_8_3"], ["SPK_SINAN", "BUR_AMB_G5_3_1"], ["SPK_NASREDDIN", "BUR_AMB_G5_3_2"],
	["SPK_SINAN", "BUR_AMB_G5_3_3"], ["SPK_NASREDDIN", "BUR_AMB_G5_3_4"], ["SPK_NASREDDIN", "BUR_AMB_G5_4_1"], ["SPK_SINAN", "BUR_AMB_G5_4_2"],
	["SPK_NASREDDIN", "BUR_AMB_G5_4_3"], ["SPK_SINAN", "BUR_AMB_G5_4_4"], ["SPK_SINAN", "BUR_AMB_G5_5_1"], ["SPK_NASREDDIN", "BUR_AMB_G5_5_2"],
	["SPK_SINAN", "BUR_AMB_G5_5_3"], ["SPK_NASREDDIN", "BUR_AMB_G5_6_1"], ["SPK_SINAN", "BUR_AMB_G5_6_2"], ["SPK_NASREDDIN", "BUR_AMB_G5_6_3"],
	["SPK_SINAN", "BUR_AMB_G5_7_1"], ["SPK_NASREDDIN", "BUR_AMB_G5_7_2"], ["SPK_SINAN", "BUR_AMB_G5_7_3"], ["SPK_NASREDDIN", "BUR_AMB_G5_8_1"],
	["SPK_SINAN", "BUR_AMB_G5_8_2"], ["SPK_NASREDDIN", "BUR_AMB_G5_8_3"], ["SPK_GAGARIN", "BUR_AMB_G6_3_1"], ["SPK_GALILEO", "BUR_AMB_G6_3_2"],
	["SPK_GAGARIN", "BUR_AMB_G6_3_3"], ["SPK_GAGARIN", "BUR_AMB_G6_4_1"], ["SPK_GALILEO", "BUR_AMB_G6_4_2"], ["SPK_GAGARIN", "BUR_AMB_G6_4_3"],
	["SPK_GALILEO", "BUR_AMB_G6_4_4"], ["SPK_GALILEO", "BUR_AMB_G6_5_1"], ["SPK_GAGARIN", "BUR_AMB_G6_5_2"], ["SPK_GALILEO", "BUR_AMB_G6_5_3"],
	["SPK_GAGARIN", "BUR_AMB_G6_5_4"], ["SPK_GALILEO", "BUR_AMB_G6_6_1"], ["SPK_GAGARIN", "BUR_AMB_G6_6_2"], ["SPK_GALILEO", "BUR_AMB_G6_6_3"],
	["SPK_GAGARIN", "BUR_AMB_G6_7_1"], ["SPK_GALILEO", "BUR_AMB_G6_7_2"], ["SPK_GAGARIN", "BUR_AMB_G6_7_3"], ["SPK_GALILEO", "BUR_AMB_G6_8_1"],
	["SPK_GAGARIN", "BUR_AMB_G6_8_2"], ["SPK_GALILEO", "BUR_AMB_G6_8_3"], ["SPK_GAGARIN", "BUR_AMB_G6_9_1"], ["SPK_GALILEO", "BUR_AMB_G6_9_2"],
	["SPK_GAGARIN", "BUR_AMB_G6_9_3"], ["SPK_CAESAR", "BUR_AMB_G7_4_1"], ["SPK_SHAKESPEARE", "BUR_AMB_G7_4_2"], ["SPK_CAESAR", "BUR_AMB_G7_4_3"],
	["SPK_CAESAR", "BUR_AMB_G7_5_1"], ["SPK_SHAKESPEARE", "BUR_AMB_G7_5_2"], ["SPK_NECMI", "BUR_AMB_G7_5_3"], ["SPK_SHAKESPEARE", "BUR_AMB_G7_6_1"],
	["SPK_NECMI", "BUR_AMB_G7_6_2"], ["SPK_CAESAR", "BUR_AMB_G7_6_3"], ["SPK_CAESAR", "BUR_AMB_G7_7_1"], ["SPK_SHAKESPEARE", "BUR_AMB_G7_7_2"],
	["SPK_CAESAR", "BUR_AMB_G7_7_3"], ["SPK_NECMI", "BUR_AMB_G7_7_4"], ["SPK_SHAKESPEARE", "BUR_AMB_G7_8_1"], ["SPK_CAESAR", "BUR_AMB_G7_8_2"],
	["SPK_SHAKESPEARE", "BUR_AMB_G7_8_3"], ["SPK_NECMI", "BUR_AMB_G7_8_4"], ["SPK_SHAKESPEARE", "BUR_AMB_G7_9_1"], ["SPK_CAESAR", "BUR_AMB_G7_9_2"],
	["SPK_NECMI", "BUR_AMB_G7_9_3"], ["SPK_COLUMBUS", "BUR_AMB_G8_3_1"], ["SPK_SABRI", "BUR_AMB_G8_3_2"], ["SPK_COLUMBUS", "BUR_AMB_G8_3_3"],
	["SPK_SABRI", "BUR_AMB_G8_3_4"], ["SPK_COLUMBUS", "BUR_AMB_G8_4_1"], ["SPK_SABRI", "BUR_AMB_G8_4_2"], ["SPK_COLUMBUS", "BUR_AMB_G8_4_3"],
	["SPK_SABRI", "BUR_AMB_G8_4_4"], ["SPK_COLUMBUS", "BUR_AMB_G8_5_1"], ["SPK_SABRI", "BUR_AMB_G8_5_2"], ["SPK_COLUMBUS", "BUR_AMB_G8_5_3"],
	["SPK_SABRI", "BUR_AMB_G8_5_4"], ["SPK_COLUMBUS", "BUR_AMB_G8_6_1"], ["SPK_SABRI", "BUR_AMB_G8_6_2"], ["SPK_COLUMBUS", "BUR_AMB_G8_6_3"],
	["SPK_SABRI", "BUR_AMB_G8_6_4"], ["SPK_COLUMBUS", "BUR_AMB_G8_7_1"], ["SPK_SABRI", "BUR_AMB_G8_7_2"], ["SPK_COLUMBUS", "BUR_AMB_G8_7_3"],
	["SPK_SABRI", "BUR_AMB_G8_7_4"], ["SPK_COLUMBUS", "BUR_AMB_G8_8_1"], ["SPK_SABRI", "BUR_AMB_G8_8_2"], ["SPK_COLUMBUS", "BUR_AMB_G8_8_3"],
	["SPK_SABRI", "BUR_AMB_G8_8_4"], ["SPK_CLEOPATRA", "BUR_AMB_G9_3_1"], ["SPK_SULEYMAN", "BUR_AMB_G9_3_2"], ["SPK_CLEOPATRA", "BUR_AMB_G9_3_3"],
	["SPK_CLEOPATRA", "BUR_AMB_G9_4_1"], ["SPK_SULEYMAN", "BUR_AMB_G9_4_2"], ["SPK_CLEOPATRA", "BUR_AMB_G9_4_3"], ["SPK_SULEYMAN", "BUR_AMB_G9_5_1"],
	["SPK_CLEOPATRA", "BUR_AMB_G9_5_2"], ["SPK_SULEYMAN", "BUR_AMB_G9_5_3"], ["SPK_CLEOPATRA", "BUR_AMB_G9_6_1"], ["SPK_CLEOPATRA", "BUR_AMB_G9_6_2"],
	["SPK_SULEYMAN", "BUR_AMB_G9_6_3"], ["SPK_SULEYMAN", "BUR_AMB_G9_7_1"], ["SPK_CLEOPATRA", "BUR_AMB_G9_7_2"], ["SPK_SULEYMAN", "BUR_AMB_G9_7_3"],
	["SPK_CLEOPATRA", "BUR_AMB_G9_8_1"], ["SPK_SULEYMAN", "BUR_AMB_G9_8_2"], ["SPK_CLEOPATRA", "BUR_AMB_G9_8_3"], ["SPK_LEONARDO", "BUR_AMB_G10_3_1"],
	["SPK_EINSTEIN", "BUR_AMB_G10_3_2"], ["SPK_LEONARDO", "BUR_AMB_G10_3_3"], ["SPK_EINSTEIN", "BUR_AMB_G10_4_1"], ["SPK_LEONARDO", "BUR_AMB_G10_4_2"],
	["SPK_EINSTEIN", "BUR_AMB_G10_4_3"], ["SPK_EINSTEIN", "BUR_AMB_G10_5_1"], ["SPK_LEONARDO", "BUR_AMB_G10_5_2"], ["SPK_EINSTEIN", "BUR_AMB_G10_5_3"],
	["SPK_LEONARDO", "BUR_AMB_G10_6_1"], ["SPK_EINSTEIN", "BUR_AMB_G10_6_2"], ["SPK_LEONARDO", "BUR_AMB_G10_6_3"], ["SPK_EINSTEIN", "BUR_AMB_G10_7_1"],
	["SPK_LEONARDO", "BUR_AMB_G10_7_2"], ["SPK_EINSTEIN", "BUR_AMB_G10_7_3"], ["SPK_LEONARDO", "BUR_AMB_G10_7_4"], ["SPK_LEONARDO", "BUR_AMB_G10_8_1"],
	["SPK_EINSTEIN", "BUR_AMB_G10_8_2"], ["SPK_LEONARDO", "BUR_AMB_G10_8_3"], ["SPK_GUIDE", "BUR_AMB_G11_3_1"], ["SPK_GUIDE", "BUR_AMB_G11_3_2"],
	["SPK_GUIDE", "BUR_AMB_G11_4_1"], ["SPK_GUIDE", "BUR_AMB_G11_4_2"], ["SPK_GUIDE", "BUR_AMB_G11_5_1"], ["SPK_GUIDE", "BUR_AMB_G11_5_2"],
	["SPK_GUIDE", "BUR_AMB_G11_6_1"], ["SPK_GUIDE", "BUR_AMB_G11_6_2"], ["SPK_GUIDE", "BUR_AMB_G11_7_1"], ["SPK_GUIDE", "BUR_AMB_G11_7_2"],
	["SPK_GUIDE", "BUR_AMB_G11_8_1"], ["SPK_GUIDE", "BUR_AMB_G11_8_2"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_3_1"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_3_2"],
	["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_4_1"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_4_2"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_5_1"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_5_2"],
	["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_6_1"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_6_2"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_7_1"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_7_2"],
	["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_8_1"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_8_2"], ["SPK_TESLA", "BUR_AMB_G13_1_1"], ["SPK_EDISON", "BUR_AMB_G13_1_2"],
	["SPK_TESLA", "BUR_AMB_G13_1_3"], ["SPK_EDISON", "BUR_AMB_G13_2_1"], ["SPK_TESLA", "BUR_AMB_G13_2_2"], ["SPK_EDISON", "BUR_AMB_G13_2_3"],
	["SPK_TESLA", "BUR_AMB_G13_2_4"], ["SPK_TESLA", "BUR_AMB_G13_3_1"], ["SPK_EDISON", "BUR_AMB_G13_3_2"], ["SPK_TESLA", "BUR_AMB_G13_3_3"],
	["SPK_TESLA", "BUR_AMB_G13_4_1"], ["SPK_EDISON", "BUR_AMB_G13_4_2"], ["SPK_TESLA", "BUR_AMB_G13_4_3"], ["SPK_EDISON", "BUR_AMB_G13_5_1"],
	["SPK_TESLA", "BUR_AMB_G13_5_2"], ["SPK_EDISON", "BUR_AMB_G13_5_3"], ["SPK_EINSTEIN", "BUR_AMB_G13_6_1"], ["SPK_TESLA", "BUR_AMB_G13_6_2"],
	["SPK_EDISON", "BUR_AMB_G13_6_3"], ["SPK_TESLA", "BUR_AMB_G13_7_1"], ["SPK_EDISON", "BUR_AMB_G13_7_2"], ["SPK_TESLA", "BUR_AMB_G13_7_3"],
	["SPK_EDISON", "BUR_AMB_G13_7_4"], ["SPK_SOCRATES", "BUR_AMB_G14_1_1"], ["SPK_DIOGENES", "BUR_AMB_G14_1_2"], ["SPK_SOCRATES", "BUR_AMB_G14_1_3"],
	["SPK_DIOGENES", "BUR_AMB_G14_1_4"], ["SPK_DIOGENES", "BUR_AMB_G14_2_1"], ["SPK_SOCRATES", "BUR_AMB_G14_2_2"], ["SPK_DIOGENES", "BUR_AMB_G14_2_3"],
	["SPK_SOCRATES", "BUR_AMB_G14_3_1"], ["SPK_DIOGENES", "BUR_AMB_G14_3_2"], ["SPK_SOCRATES", "BUR_AMB_G14_3_3"], ["SPK_DIOGENES", "BUR_AMB_G14_4_1"],
	["SPK_SOCRATES", "BUR_AMB_G14_4_2"], ["SPK_DIOGENES", "BUR_AMB_G14_4_3"], ["SPK_SOCRATES", "BUR_AMB_G14_5_1"], ["SPK_DIOGENES", "BUR_AMB_G14_5_2"],
	["SPK_SOCRATES", "BUR_AMB_G14_5_3"], ["SPK_SOCRATES", "BUR_AMB_G14_6_1"], ["SPK_DIOGENES", "BUR_AMB_G14_6_2"], ["SPK_SOCRATES", "BUR_AMB_G14_6_3"],
	["SPK_ARCHAEOLOGIST", "BUR_AMB_G14_7_1"], ["SPK_SOCRATES", "BUR_AMB_G14_7_2"], ["SPK_DIOGENES", "BUR_AMB_G14_7_3"], ["SPK_NEWTON", "BUR_AMB_G15_1_1"],
	["SPK_EINSTEIN", "BUR_AMB_G15_1_2"], ["SPK_NEWTON", "BUR_AMB_G15_1_3"], ["SPK_NEWTON", "BUR_AMB_G15_2_1"], ["SPK_EINSTEIN", "BUR_AMB_G15_2_2"],
	["SPK_LEONARDO", "BUR_AMB_G15_2_3"], ["SPK_NEWTON", "BUR_AMB_G15_3_1"], ["SPK_EINSTEIN", "BUR_AMB_G15_3_2"], ["SPK_NEWTON", "BUR_AMB_G15_3_3"],
	["SPK_NEWTON", "BUR_AMB_G15_4_1"], ["SPK_EINSTEIN", "BUR_AMB_G15_4_2"], ["SPK_LEONARDO", "BUR_AMB_G15_4_3"], ["SPK_NEWTON", "BUR_AMB_G15_5_1"],
	["SPK_EINSTEIN", "BUR_AMB_G15_5_2"], ["SPK_NEWTON", "BUR_AMB_G15_5_3"], ["SPK_NEWTON", "BUR_AMB_G15_6_1"], ["SPK_EINSTEIN", "BUR_AMB_G15_6_2"],
	["SPK_NEWTON", "BUR_AMB_G15_6_3"], ["SPK_EINSTEIN", "BUR_AMB_G15_6_4"], ["SPK_LEONARDO", "BUR_AMB_G15_7_1"], ["SPK_NEWTON", "BUR_AMB_G15_7_2"],
	["SPK_LEONARDO", "BUR_AMB_G15_7_3"], ["SPK_SABRI", "BUR_AMB_G16_1_1"], ["SPK_EVLIYA", "BUR_AMB_G16_1_2"], ["SPK_SABRI", "BUR_AMB_G16_1_3"],
	["SPK_EVLIYA", "BUR_AMB_G16_2_1"], ["SPK_SABRI", "BUR_AMB_G16_2_2"], ["SPK_EVLIYA", "BUR_AMB_G16_2_3"], ["SPK_COLUMBUS", "BUR_AMB_G16_3_1"],
	["SPK_EVLIYA", "BUR_AMB_G16_3_2"], ["SPK_SABRI", "BUR_AMB_G16_3_3"], ["SPK_EVLIYA", "BUR_AMB_G16_4_1"], ["SPK_COLUMBUS", "BUR_AMB_G16_4_2"],
	["SPK_SABRI", "BUR_AMB_G16_4_3"], ["SPK_EVLIYA", "BUR_AMB_G16_5_1"], ["SPK_SABRI", "BUR_AMB_G16_5_2"], ["SPK_COLUMBUS", "BUR_AMB_G16_5_3"],
	["SPK_SABRI", "BUR_AMB_G16_5_4"], ["SPK_SABRI", "BUR_AMB_G16_6_1"], ["SPK_EVLIYA", "BUR_AMB_G16_6_2"], ["SPK_SABRI", "BUR_AMB_G16_6_3"],
	["SPK_COLUMBUS", "BUR_AMB_G16_6_4"], ["SPK_COLUMBUS", "BUR_AMB_G16_7_1"], ["SPK_EVLIYA", "BUR_AMB_G16_7_2"], ["SPK_SABRI", "BUR_AMB_G16_7_3"],
	["SPK_TESLA", "BUR_FG_TES_1"], ["SPK_TESLA", "BUR_FG_TES_2"], ["SPK_TESLA", "BUR_FG_TES_3"], ["SPK_EDISON", "BUR_FG_EDI_1"],
	["SPK_EDISON", "BUR_FG_EDI_2"], ["SPK_EDISON", "BUR_FG_EDI_3"], ["SPK_SOCRATES", "BUR_FG_SOK_1"], ["SPK_SOCRATES", "BUR_FG_SOK_2"],
	["SPK_SOCRATES", "BUR_FG_SOK_3"], ["SPK_DIOGENES", "BUR_FG_DIO_1"], ["SPK_DIOGENES", "BUR_FG_DIO_2"], ["SPK_DIOGENES", "BUR_FG_DIO_3"],
	["SPK_NEWTON", "BUR_FG_NEW_1"], ["SPK_NEWTON", "BUR_FG_NEW_2"], ["SPK_NEWTON", "BUR_FG_NEW_3"], ["SPK_EVLIYA", "BUR_FG_EVL_1"],
	["SPK_EVLIYA", "BUR_FG_EVL_2"], ["SPK_EVLIYA", "BUR_FG_EVL_3"],
	["SPK_NIHAT", "BUR_ORNITHOPTER"], ["SPK_NIHAT", "BUR_ORNITHOPTER_2"], ["SPK_NIHAT", "BUR_COIL"], ["SPK_NIHAT", "BUR_COIL_2"], ["SPK_NIHAT", "BUR_PHONO"], ["SPK_NIHAT", "BUR_PHONO_2"], ["SPK_NIHAT", "BUR_APPLETREE"], ["SPK_NIHAT", "BUR_APPLETREE_2"], ["SPK_NIHAT", "BUR_HOURGLASS"], ["SPK_NIHAT", "BUR_HOURGLASS_2"], ["SPK_NIHAT", "BUR_CLOCKS"], ["SPK_NIHAT", "BUR_CLOCKS_2"],
	["SPK_NIHAT", "BUR_APPEALS_1"], ["SPK_NIHAT", "BUR_APPEALS_2"], ["SPK_NIHAT", "BUR_APPEALS_3"], ["SPK_NIHAT", "BUR_APPEALS_4"],
	["SPK_NIHAT", "D3_N_DOOR_1453"], ["SPK_NIHAT", "D3_N_DOOR_2026"], ["SPK_MARCOPOLO", "BUR_FG_POL_1"],
	["SPK_MARCOPOLO", "BUR_FG_POL_2"], ["SPK_MARCOPOLO", "BUR_FG_POL_V2_1"], ["SPK_MARCOPOLO", "BUR_FG_POL_V2_2"],
	["SPK_MARCOPOLO", "BUR_FG_POL_V3_1"], ["SPK_MARCOPOLO", "BUR_FG_POL_V3_2"], ["SPK_GALILEO", "BUR_FG_GAL_1"],
	["SPK_GALILEO", "BUR_FG_GAL_2"], ["SPK_GALILEO", "BUR_FG_GAL_V2_1"], ["SPK_GALILEO", "BUR_FG_GAL_V2_2"],
	["SPK_GALILEO", "BUR_FG_GAL_V3_1"], ["SPK_GALILEO", "BUR_FG_GAL_V3_2"], ["SPK_CURIE", "BUR_FG_CUR_1"],
	["SPK_CURIE", "BUR_FG_CUR_2"], ["SPK_CURIE", "BUR_FG_CUR_V2_1"], ["SPK_CURIE", "BUR_FG_CUR_V2_2"],
	["SPK_CURIE", "BUR_FG_CUR_V3_1"], ["SPK_CURIE", "BUR_FG_CUR_V3_2"], ["SPK_MOZART", "BUR_FG_MOZ_1"],
	["SPK_MOZART", "BUR_FG_MOZ_2"], ["SPK_MOZART", "BUR_FG_MOZ_V2_1"], ["SPK_MOZART", "BUR_FG_MOZ_V2_2"],
	["SPK_MOZART", "BUR_FG_MOZ_V3_1"], ["SPK_MOZART", "BUR_FG_MOZ_V3_2"], ["SPK_SINAN", "BUR_FG_SIN_1"],
	["SPK_SINAN", "BUR_FG_SIN_2"], ["SPK_SINAN", "BUR_FG_SIN_V2_1"], ["SPK_SINAN", "BUR_FG_SIN_V2_2"],
	["SPK_SINAN", "BUR_FG_SIN_V3_1"], ["SPK_SINAN", "BUR_FG_SIN_V3_2"], ["SPK_NASREDDIN", "BUR_FG_NAS_1"],
	["SPK_NASREDDIN", "BUR_FG_NAS_2"], ["SPK_NASREDDIN", "BUR_FG_NAS_V2_1"], ["SPK_NASREDDIN", "BUR_FG_NAS_V2_2"],
	["SPK_NASREDDIN", "BUR_FG_NAS_V3_1"], ["SPK_NASREDDIN", "BUR_FG_NAS_V3_2"], ["SPK_GAGARIN", "BUR_FG_GAG_1"],
	["SPK_GAGARIN", "BUR_FG_GAG_2"], ["SPK_GAGARIN", "BUR_FG_GAG_V2_1"], ["SPK_GAGARIN", "BUR_FG_GAG_V2_2"],
	["SPK_GAGARIN", "BUR_FG_GAG_V3_1"], ["SPK_GAGARIN", "BUR_FG_GAG_V3_2"], ["SPK_NIHAT", "BUR_DOOR_1453_1"],
	["SPK_NIHAT", "BUR_DOOR_1453_2"], ["SPK_NIHAT", "BUR_DOOR_1453_3"], ["SPK_NIHAT", "BUR_DOOR_1453_4"],
	["SPK_NIHAT", "BUR_DOOR_1492_1"], ["SPK_NIHAT", "BUR_DOOR_1492_2"], ["SPK_NIHAT", "BUR_DOOR_1492_3"],
	["SPK_NIHAT", "BUR_DOOR_1517_1"], ["SPK_NIHAT", "BUR_DOOR_1517_2"], ["SPK_NIHAT", "BUR_DOOR_1517_3"],
	["SPK_NIHAT", "BUR_DOOR_1789_1"], ["SPK_NIHAT", "BUR_DOOR_1789_2"], ["SPK_NIHAT", "BUR_DOOR_1789_3"],
	["SPK_NIHAT", "BUR_DOOR_1969_1"], ["SPK_NIHAT", "BUR_DOOR_1969_2"], ["SPK_NIHAT", "BUR_DOOR_1969_3"],
	["SPK_NIHAT", "BUR_DOOR_2026_1"], ["SPK_NIHAT", "BUR_DOOR_2026_2"], ["SPK_NIHAT", "BUR_DOOR_2026_3"],
	["SPK_NIHAT", "BUR_DOOR_2150_1"], ["SPK_NIHAT", "BUR_DOOR_2150_2"], ["SPK_NIHAT", "BUR_DOOR_2150_3"],
	["SPK_NIHAT", "BUR_DOOR_MO44_1"], ["SPK_NIHAT", "BUR_DOOR_MO44_2"], ["SPK_NIHAT", "BUR_DOOR_MO44_3"],
	["SPK_NIHAT", "BUR_DOOR_MO776_1"], ["SPK_NIHAT", "BUR_DOOR_MO776_2"], ["SPK_NIHAT", "BUR_DOOR_MO776_3"],
	["SPK_NAPOLEON", "BUR_FG_NAP_V2_1"], ["SPK_NAPOLEON", "BUR_FG_NAP_V2_2"], ["SPK_NAPOLEON", "BUR_FG_NAP_V3_1"],
	["SPK_NAPOLEON", "BUR_FG_NAP_V3_2"], ["SPK_HITLER", "BUR_FG_HIT_V2_1"], ["SPK_HITLER", "BUR_FG_HIT_V2_2"],
	["SPK_HITLER", "BUR_FG_HIT_V3_1"], ["SPK_HITLER", "BUR_FG_HIT_V3_2"], ["SPK_CLEOPATRA", "BUR_FG_CLE_V2_1"],
	["SPK_CLEOPATRA", "BUR_FG_CLE_V2_2"], ["SPK_CLEOPATRA", "BUR_FG_CLE_V3_1"], ["SPK_CLEOPATRA", "BUR_FG_CLE_V3_2"],
	["SPK_CAESAR", "BUR_FG_CAE_V2_1"], ["SPK_CAESAR", "BUR_FG_CAE_V2_2"], ["SPK_CAESAR", "BUR_FG_CAE_V3_1"],
	["SPK_CAESAR", "BUR_FG_CAE_V3_2"], ["SPK_SHAKESPEARE", "BUR_FG_SHK_V2_1"], ["SPK_SHAKESPEARE", "BUR_FG_SHK_V2_2"],
	["SPK_SHAKESPEARE", "BUR_FG_SHK_V3_1"], ["SPK_SHAKESPEARE", "BUR_FG_SHK_V3_2"], ["SPK_LEONARDO", "BUR_FG_LEO_V2_1"],
	["SPK_LEONARDO", "BUR_FG_LEO_V2_2"], ["SPK_LEONARDO", "BUR_FG_LEO_V3_1"], ["SPK_LEONARDO", "BUR_FG_LEO_V3_2"],
	["SPK_EINSTEIN", "BUR_FG_EIN_V2_1"], ["SPK_EINSTEIN", "BUR_FG_EIN_V2_2"], ["SPK_EINSTEIN", "BUR_FG_EIN_V3_1"],
	["SPK_EINSTEIN", "BUR_FG_EIN_V3_2"], ["SPK_GENGHIS", "BUR_FG_GEN_V2_1"], ["SPK_GENGHIS", "BUR_FG_GEN_V2_2"],
	["SPK_GENGHIS", "BUR_FG_GEN_V3_1"], ["SPK_GENGHIS", "BUR_FG_GEN_V3_2"], ["SPK_COLUMBUS", "BUR_FG_COL_V2_1"],
	["SPK_COLUMBUS", "BUR_FG_COL_V2_2"], ["SPK_COLUMBUS", "BUR_FG_COL_V3_1"], ["SPK_COLUMBUS", "BUR_FG_COL_V3_2"],
	["SPK_SULEYMAN", "BUR_FG_SUL_V2_1"], ["SPK_SULEYMAN", "BUR_FG_SUL_V2_2"], ["SPK_SULEYMAN", "BUR_FG_SUL_V3_1"],
	["SPK_SULEYMAN", "BUR_FG_SUL_V3_2"], ["SPK_GUIDE", "BUR_FG_GUI_V2_1"], ["SPK_GUIDE", "BUR_FG_GUI_V2_2"],
	["SPK_GUIDE", "BUR_FG_GUI_V3_1"], ["SPK_GUIDE", "BUR_FG_GUI_V3_2"], ["SPK_ROBOT", "BUR_FG_ROB_V2_1"],
	["SPK_ROBOT", "BUR_FG_ROB_V2_2"], ["SPK_ROBOT", "BUR_FG_ROB_V3_1"], ["SPK_ROBOT", "BUR_FG_ROB_V3_2"],
	["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_V2_1"], ["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_V2_2"], ["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_V3_1"],
	["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_V3_2"], ["SPK_SULEYMAN", "BUR_FG_SUL_1"], ["SPK_SULEYMAN", "BUR_FG_SUL_2"],
	["SPK_SULEYMAN", "BUR_FG_SUL_3"], ["SPK_GUIDE", "BUR_FG_GUI_1"], ["SPK_GUIDE", "BUR_FG_GUI_2"],
	["SPK_ROBOT", "BUR_FG_ROB_1"], ["SPK_ROBOT", "BUR_FG_ROB_2"], ["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_1"],
	["SPK_ARCHAEOLOGIST", "BUR_FG_ARC_2"], ["SPK_NAPOLEON", "BUR_FG_NAP_1"], ["SPK_NAPOLEON", "BUR_FG_NAP_2"],
	["SPK_NAPOLEON", "BUR_FG_NAP_3"], ["SPK_HITLER", "BUR_FG_HIT_R"], ["SPK_NAPOLEON", "BUR_FG_NAP_4"],
	["SPK_HITLER", "BUR_FG_HIT_1"], ["SPK_HITLER", "BUR_FG_HIT_2"], ["SPK_CLEOPATRA", "BUR_FG_CLE_1"],
	["SPK_CLEOPATRA", "BUR_FG_CLE_2"], ["SPK_CAESAR", "BUR_FG_CAE_1"], ["SPK_CAESAR", "BUR_FG_CAE_2"],
	["SPK_CAESAR", "BUR_FG_CAE_3"], ["SPK_SHAKESPEARE", "BUR_FG_SHK_R"], ["SPK_SHAKESPEARE", "BUR_FG_SHK_1"],
	["SPK_SHAKESPEARE", "BUR_FG_SHK_2"], ["SPK_LEONARDO", "BUR_FG_LEO_1"], ["SPK_LEONARDO", "BUR_FG_LEO_2"],
	["SPK_LEONARDO", "BUR_FG_LEO_3"], ["SPK_EINSTEIN", "BUR_FG_EIN_1"], ["SPK_EINSTEIN", "BUR_FG_EIN_2"],
	["SPK_GENGHIS", "BUR_FG_GEN_1"], ["SPK_GENGHIS", "BUR_FG_GEN_2"], ["SPK_COLUMBUS", "BUR_FG_COL_1"],
	["SPK_COLUMBUS", "BUR_FG_COL_2"], ["SPK_NIHAT", "BUR_BLIND"], ["SPK_NIHAT", "BUR_BLIND_2"],
	["SPK_NIHAT", "BUR_CLOCKKNOB"], ["SPK_NIHAT", "BUR_CLOCKKNOB_2"], ["SPK_NIHAT", "BUR_TYPEWRITER"],
	["SPK_NIHAT", "BUR_TYPEWRITER_2"], ["SPK_NIHAT", "BUR_STAMP_OK"], ["SPK_NIHAT", "BUR_STAMP_NO"],
	["SPK_NIHAT", "BUR_STAMP_MISSING"], ["SPK_NIHAT", "BUR_TUBE"], ["SPK_NIHAT", "BUR_TUBE_2"],
	["SPK_NIHAT", "BUR_DRAWER"], ["SPK_NIHAT", "BUR_DRAWER_2"], ["SPK_NIHAT", "BUR_DRAWER_3"],
	["SPK_NIHAT", "BUR_FOUNDER"], ["SPK_NIHAT", "BUR_FOUNDER_2"], ["SPK_NIHAT", "BUR_CALENDAR"],
	["SPK_NIHAT", "BUR_CALENDAR_2"], ["SPK_NIHAT", "BUR_GLOBE"], ["SPK_NIHAT", "BUR_GLOBE_2"],
	["SPK_NIHAT", "BUR_GLOBE_3"], ["SPK_NIHAT", "BUR_SECOND_1"], ["SPK_NIHAT", "BUR_SECOND_2"],
	["SPK_NIHAT", "BUR_SECOND_3"], ["SPK_NIHAT", "BUR_SECOND_4"], ["SPK_NIHAT", "BUR_SECOND_ALL"],
	["SPK_NIHAT", "BUR_NOTICE_A"], ["SPK_NIHAT", "BUR_NOTICE_A_2"], ["SPK_NIHAT", "BUR_NOTICE_B"],
	["SPK_NIHAT", "BUR_NOTICE_C"], ["SPK_NIHAT", "BUR_NOTICE_D"], ["SPK_NIHAT", "BUR_CCLOCK0"],
	["SPK_NIHAT", "BUR_CCLOCK1"], ["SPK_NIHAT", "BUR_CCLOCK2"], ["SPK_NIHAT", "BUR_CCLOCK3"],
	["SPK_NIHAT", "BUR_CCLOCK4"], ["SPK_NIHAT", "BUR_COOLER"], ["SPK_NIHAT", "BUR_COOLER_2"],
	["SPK_NIHAT", "BUR_PALM"], ["SPK_NIHAT", "BUR_PALM_2"], ["SPK_CEMAL", "BUR_CEMAL"],
	["SPK_CEMAL", "BUR_CEMAL_2"], ["SPK_ZEKI", "BUR_TROLLEY"], ["SPK_ZEKI", "BUR_TROLLEY_2"],
	["SPK_NIHAT", "BUR_MEHTER"], ["SPK_NIHAT", "BUR_MEHTER_2"], ["SPK_NIHAT", "BUR_TEAPOT"],
	["SPK_NIHAT", "BUR_TEAPOT_2"], ["SPK_NECMI", "BUR_NECMI"], ["SPK_NECMI", "BUR_NECMI_2"],
	["SPK_NECMI", "BUR_NECMI_3"], ["SPK_NIHAT", "BUR_DISPLAY"], ["SPK_NIHAT", "BUR_DISPLAY_2"],
	["SPK_NIHAT", "BUR_TICKET"], ["SPK_NIHAT", "BUR_TICKET_2"], ["SPK_NIHAT", "BUR_TICKET_3"],
	["SPK_NIHAT", "BUR_GHOST"], ["SPK_NIHAT", "BUR_GHOST_2"], ["SPK_NIHAT", "BUR_GHOST_3"],
	["SPK_SABRI", "BUR_BELL"], ["SPK_SABRI", "BUR_BELL_2"], ["SPK_NIHAT", "BUR_NOKIA"],
	["SPK_NIHAT", "BUR_NOKIA_2"], ["SPK_NIHAT", "BUR_SANDAL"], ["SPK_NIHAT", "BUR_SANDAL_2"],
	["SPK_NIHAT", "BUR_LOSTSHELF"], ["SPK_NIHAT", "BUR_LOSTSHELF_2"], ["SPK_NIHAT", "BUR_LOSTSHELF_3"],
	["SPK_NIHAT", "BUR_LOSTSHELF_4"], ["SPK_NIHAT", "BUR_TOLGA_FILE"], ["SPK_NIHAT", "BUR_TOLGA_FILE_2"],
	["SPK_NIHAT", "BUR_ARCHDRAWER"], ["SPK_NIHAT", "BUR_ARCHDRAWER_2"], ["SPK_HATICE", "BUR_HATICE"],
	["SPK_HATICE", "BUR_HATICE_2"], ["SPK_NURAN", "BUR_PARADOKS"], ["SPK_NURAN", "BUR_PARADOKS_2"],
	["SPK_NURAN", "BUR_PARADOKS_3"], ["SPK_NIHAT", "BUR_DIRECTOR"], ["SPK_NIHAT", "BUR_DIRECTOR_2"],
	["SPK_NIHAT", "BUR_DIRECTOR_3"], ["SPK_NIHAT", "BUR_REGWALL"], ["SPK_NIHAT", "BUR_REGWALL_2"],
	["SPK_NIHAT", "BUR_ATRIUMWIN"], ["SPK_NIHAT", "BUR_ATRIUMWIN_2"], ["SPK_NIHAT", "BUR_TIMELINE"],
	["SPK_NIHAT", "BUR_TIMELINE_2"], ["SPK_NIHAT", "BUR_PENDULUM"], ["SPK_NIHAT", "BUR_PENDULUM_2"],
	["SPK_NIHAT", "BUR_DOOR_MO2560_1"], ["SPK_NIHAT", "BUR_DOOR_MO2560_2"], ["SPK_NIHAT", "BUR_DOOR_MO2560_3"],
	["SPK_NIHAT", "BUR_DOOR_1215_1"], ["SPK_NIHAT", "BUR_DOOR_1215_2"], ["SPK_NIHAT", "BUR_DOOR_1215_3"],
	["SPK_NIHAT", "BUR_DOOR_1347_1"], ["SPK_NIHAT", "BUR_DOOR_1347_2"], ["SPK_NIHAT", "BUR_DOOR_1347_3"],
	["SPK_NIHAT", "BUR_DOOR_1455_1"], ["SPK_NIHAT", "BUR_DOOR_1455_2"], ["SPK_NIHAT", "BUR_DOOR_1455_3"],
	["SPK_NIHAT", "BUR_DOOR_1687_1"], ["SPK_NIHAT", "BUR_DOOR_1687_2"], ["SPK_NIHAT", "BUR_DOOR_1687_3"],
	["SPK_NIHAT", "BUR_DOOR_1769_1"], ["SPK_NIHAT", "BUR_DOOR_1769_2"], ["SPK_NIHAT", "BUR_DOOR_1769_3"],
	["SPK_NIHAT", "BUR_DOOR_1815_1"], ["SPK_NIHAT", "BUR_DOOR_1815_2"], ["SPK_NIHAT", "BUR_DOOR_1815_3"],
	["SPK_NIHAT", "BUR_DOOR_1903_1"], ["SPK_NIHAT", "BUR_DOOR_1903_2"], ["SPK_NIHAT", "BUR_DOOR_1903_3"],
	["SPK_NIHAT", "BUR_DOOR_1914_1"], ["SPK_NIHAT", "BUR_DOOR_1914_2"], ["SPK_NIHAT", "BUR_DOOR_1914_3"],
	["SPK_NIHAT", "BUR_DOOR_1945_1"], ["SPK_NIHAT", "BUR_DOOR_1945_2"], ["SPK_NIHAT", "BUR_DOOR_1945_3"],
	["SPK_NIHAT", "BUR_DOOR_1989_1"], ["SPK_NIHAT", "BUR_DOOR_1989_2"], ["SPK_NIHAT", "BUR_DOOR_1989_3"],
	["SPK_NAPOLEON", "BUR_AMB_G1_1_1"], ["SPK_GENGHIS", "BUR_AMB_G1_1_2"], ["SPK_NAPOLEON", "BUR_AMB_G1_2_1"],
	["SPK_GENGHIS", "BUR_AMB_G1_2_2"], ["SPK_NAPOLEON", "BUR_AMB_G1_2_3"], ["SPK_GENGHIS", "BUR_AMB_G1_2_4"],
	["SPK_GENGHIS", "BUR_AMB_G1_3_1"], ["SPK_NAPOLEON", "BUR_AMB_G1_3_2"], ["SPK_GENGHIS", "BUR_AMB_G1_3_3"],
	["SPK_ROBOT", "BUR_AMB_G2_1_1"], ["SPK_HITLER", "BUR_AMB_G2_1_2"], ["SPK_ROBOT", "BUR_AMB_G2_1_3"],
	["SPK_NAPOLEON", "BUR_AMB_G2_2_1"], ["SPK_HITLER", "BUR_AMB_G2_2_2"], ["SPK_ROBOT", "BUR_AMB_G2_2_3"],
	["SPK_HITLER", "BUR_AMB_G2_3_1"], ["SPK_ROBOT", "BUR_AMB_G2_3_2"], ["SPK_HITLER", "BUR_AMB_G2_3_3"],
	["SPK_ROBOT", "BUR_AMB_G2_3_4"], ["SPK_MARCOPOLO", "BUR_AMB_G3_1_1"], ["SPK_GALILEO", "BUR_AMB_G3_1_2"],
	["SPK_MARCOPOLO", "BUR_AMB_G3_1_3"], ["SPK_GALILEO", "BUR_AMB_G3_2_1"], ["SPK_MARCOPOLO", "BUR_AMB_G3_2_2"],
	["SPK_GALILEO", "BUR_AMB_G3_2_3"], ["SPK_MOZART", "BUR_AMB_G4_1_1"], ["SPK_CURIE", "BUR_AMB_G4_1_2"],
	["SPK_MOZART", "BUR_AMB_G4_1_3"], ["SPK_CURIE", "BUR_AMB_G4_2_1"], ["SPK_MOZART", "BUR_AMB_G4_2_2"],
	["SPK_CURIE", "BUR_AMB_G4_2_3"], ["SPK_SINAN", "BUR_AMB_G5_1_1"], ["SPK_NASREDDIN", "BUR_AMB_G5_1_2"],
	["SPK_NASREDDIN", "BUR_AMB_G5_2_1"], ["SPK_SINAN", "BUR_AMB_G5_2_2"], ["SPK_NASREDDIN", "BUR_AMB_G5_2_3"],
	["SPK_GALILEO", "BUR_AMB_G6_1_1"], ["SPK_GAGARIN", "BUR_AMB_G6_1_2"], ["SPK_GALILEO", "BUR_AMB_G6_1_3"],
	["SPK_GAGARIN", "BUR_AMB_G6_2_1"], ["SPK_GALILEO", "BUR_AMB_G6_2_2"], ["SPK_GAGARIN", "BUR_AMB_G6_2_3"],
	["SPK_CAESAR", "BUR_AMB_G7_1_1"], ["SPK_SHAKESPEARE", "BUR_AMB_G7_1_2"], ["SPK_CAESAR", "BUR_AMB_G7_1_3"],
	["SPK_CAESAR", "BUR_AMB_G7_2_1"], ["SPK_SHAKESPEARE", "BUR_AMB_G7_2_2"], ["SPK_CAESAR", "BUR_AMB_G7_2_3"],
	["SPK_CAESAR", "BUR_AMB_G7_3_1"], ["SPK_NECMI", "BUR_AMB_G7_3_2"], ["SPK_COLUMBUS", "BUR_AMB_G8_1_1"],
	["SPK_SABRI", "BUR_AMB_G8_1_2"], ["SPK_COLUMBUS", "BUR_AMB_G8_1_3"], ["SPK_SABRI", "BUR_AMB_G8_1_4"],
	["SPK_COLUMBUS", "BUR_AMB_G8_2_1"], ["SPK_SABRI", "BUR_AMB_G8_2_2"], ["SPK_COLUMBUS", "BUR_AMB_G8_2_3"],
	["SPK_SABRI", "BUR_AMB_G8_2_4"], ["SPK_CLEOPATRA", "BUR_AMB_G9_1_1"], ["SPK_SULEYMAN", "BUR_AMB_G9_1_2"],
	["SPK_CLEOPATRA", "BUR_AMB_G9_1_3"], ["SPK_SULEYMAN", "BUR_AMB_G9_2_1"], ["SPK_CLEOPATRA", "BUR_AMB_G9_2_2"],
	["SPK_LEONARDO", "BUR_AMB_G10_1_1"], ["SPK_EINSTEIN", "BUR_AMB_G10_1_2"], ["SPK_LEONARDO", "BUR_AMB_G10_1_3"],
	["SPK_EINSTEIN", "BUR_AMB_G10_2_1"], ["SPK_LEONARDO", "BUR_AMB_G10_2_2"], ["SPK_EINSTEIN", "BUR_AMB_G10_2_3"],
	["SPK_LEONARDO", "BUR_AMB_G10_2_4"], ["SPK_GUIDE", "BUR_AMB_G11_1_1"], ["SPK_GUIDE", "BUR_AMB_G11_1_2"],
	["SPK_GUIDE", "BUR_AMB_G11_2_1"], ["SPK_GUIDE", "BUR_AMB_G11_2_2"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_1_1"],
	["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_1_2"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_2_1"], ["SPK_ARCHAEOLOGIST", "BUR_AMB_G12_2_2"],
	["SPK_NIHAT", "BUR_WAIT_N_1"], ["SPK_NIHAT", "BUR_WAIT_N_2"], ["SPK_NIHAT", "BUR_WAIT_N_3"],
]

var bark_speaker := "SPK_NIHAT"
var player: Player
var hud: Hud
var _handlers := {}       # kimlik → Callable() (etkileşim)
var _prompts := {}        # kimlik → istem anahtarı (UI_BUR_*)
var _prompt_args := {}    # kimlik → isteme konan ad anahtarı ("Konuş: %s")
var _nihat_only := {}     # kimlik → true: yalnız Nihat oynarken
var _cycles := {}         # kimlik → sayaç (replik varyantları sırayla)
var _spinners: Array = []         # [Node3D, eksen Vector3, hız rad/sn]: dişliler, saat ibreleri
var _bobbers: Array = []          # [Node3D, taban y, genlik, hız, faz]: hayaletler, süzülenler
var _fog_t := 0.0
var _focus_bur := ""


## Etkileşimli nesne kaydı: görünmez kutu + istem + iş. fn çağrılınca hud/player hazırdır.
func _reg(id: String, size: Vector3, pos: Vector3, prompt_key: String, fn: Callable, parent: Node3D = null, nihat_only := true) -> StaticBody3D:
	_handlers[id] = fn
	_prompts[id] = prompt_key
	if nihat_only:
		_nihat_only[id] = true
	return Props.interactable(parent if parent else self, id, size, pos)


func _active(id: String) -> bool:
	if not _handlers.has(id):
		return false
	if _nihat_only.has(id) and (player == null or player.hand_style != "nihat"):
		return false
	return true


## Bölümler de sorabilir (Bölüm 3 kendi isteminin yanında bunu kullanır)
func prompt_for(id: String) -> String:
	return _prompt_text(id) if _active(id) else ""


func _prompt_text(id: String) -> String:
	var t := tr(_prompts[id])
	if _prompt_args.has(id):
		t = t % tr(_prompt_args[id])
	return t


func handle_interact(id: String) -> bool:
	if not _active(id):
		return false
	if player and player.frozen:
		return true
	(_handlers[id] as Callable).call()
	return true


## Oyuncunun sinyallerine bağlanır (bölüm hangisi olursa olsun): istem ve etkileşim Büro'nun kendi kimlikleri için.
func _attach() -> void:
	if not is_inside_tree():
		return
	player = get_tree().get_first_node_in_group("player") as Player
	hud = get_tree().get_first_node_in_group("hud") as Hud
	if player == null:
		return
	if not player.focus_changed.is_connected(_on_focus):
		player.focus_changed.connect(_on_focus)
		player.interacted.connect(_on_interacted)


func _on_focus(id: String) -> void:
	if hud == null:
		return
	if _active(id):
		_focus_bur = id
		hud.set_prompt.call_deferred(_prompt_text(id))      # bölümün kendi istem temizliğinden sonra
	elif _focus_bur != "":
		_focus_bur = ""
		if id == "":
			hud.set_prompt.call_deferred("")      # bölüm istemini kendisi temizlemiyorsa (13, 17) Büro'nunki kalmasın


func _on_interacted(id: String) -> void:
	if not visible or hud == null:
		return
	if handle_interact(id) and _active(id) and player and player.focus_id == id:
		hud.set_prompt.call_deferred(_prompt_text(id))      # bölüm etkileşimden sonra istemi silebiliyor (Bölüm 3)


## Nesne repliği (oyuncunun sesi); konuşan verilirse o (memurlar)
func _say(key: String, secs := 3.5, spk := "") -> void:
	if hud:
		hud.bark(spk if spk != "" else bark_speaker, key, secs)


## Sıradaki varyant: keys dizisinden sırayla (son elemandan sonra başa döner)
func _next(id: String, keys: Array) -> String:
	var n: int = _cycles.get(id, 0)
	_cycles[id] = n + 1
	return keys[n % keys.size()]


func _count(id: String) -> int:
	return int(_cycles.get(id, 0))


## İki dilli tabela: İngilizce oynanırken en metni (Props.LABEL_EN'e her yazıyı eklemek yerine)
func _lbl(parent: Node3D, text_tr: String, text_en: String, pos: Vector3, size := 32, color := Color.WHITE, rot := Vector3.ZERO, max_w := 0.0) -> Label3D:
	var t := text_en if TranslationServer.get_locale().begins_with("en") and text_en != "" else text_tr
	return Props.label(parent, t, pos, size, color, rot, max_w)


func _bulb(pos: Vector3, color: Color, energy: float, range_m: float, shadow := false, parent: Node3D = null) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = range_m
	l.shadow_enabled = shadow
	(parent if parent else self).add_child(l)
	return l


## Sahte ışık: zemine ya da duvara toplamsal, kenarı sönen dörtgen (gerçek ışık maliyeti olmadan sızan çağ ışığı)
static var _glow_tex: GradientTexture2D
func _glow(parent: Node3D, pos: Vector3, size: Vector2, color: Color, rot := Vector3(-90, 0, 0), strength := 1.0) -> MeshInstance3D:
	if _glow_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		_glow_tex = GradientTexture2D.new()
		_glow_tex.gradient = g
		_glow_tex.fill = GradientTexture2D.FILL_RADIAL
		_glow_tex.fill_from = Vector2(0.5, 0.5)
		_glow_tex.fill_to = Vector2(1.0, 0.5)
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_texture = _glow_tex
	m.albedo_color = Color(color.r * strength, color.g * strength, color.b * strength, 1.0)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return mi


## Kayıp saniyeler (5 gizli, kozmetik): ev sahibi nesneye ikinci etkileşimde altın bir disk fışkırır.
func _second(idx: int, at: Vector3) -> bool:
	var mask := int(GameState.flags.get("bureau_seconds", 0))
	if mask & (1 << idx):
		return false
	mask |= 1 << idx
	GameState.flags["bureau_seconds"] = mask
	var n := 0
	for i in 5:
		if mask & (1 << i):
			n += 1
	var d := Node3D.new()
	add_child(d)
	d.position = at
	Props.cyl(d, 0.06, 0.012, Vector3.ZERO, Color("ffd24a"), Vector3(90, 0, 0), 12, -1.0, 2.5)
	var tw := d.create_tween()
	tw.tween_property(d, "position", at + Vector3(0, 0.7, 0), 0.05 if GameState.autotest else 0.9).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(d, "rotation:y", TAU * 2.0, 0.05 if GameState.autotest else 0.9)
	tw.tween_callback(d.queue_free)
	Audio.sfx("ui_confirm", -6.0, 1.3)
	if hud:
		hud.bark(bark_speaker, "BUR_SECOND_ALL" if n >= 5 else "BUR_SECOND_%d" % n, 5.0 if n >= 5 else 2.8, true)
	_seconds_changed(n)
	return true


func seconds_found() -> int:
	var mask := int(GameState.flags.get("bureau_seconds", 0))
	var n := 0
	for i in 5:
		if mask & (1 << i):
			n += 1
	return n


## Kayıp saniye sayısı değişince (ilan panosundaki sayaç, müdür kapısının ışığı): odaları kuranlar bağlar
signal seconds_changed(n: int)
func _seconds_changed(n: int) -> void:
	seconds_changed.emit(n)


func _process(delta: float) -> void:
	# Sis nefes alır: mor ile camgöbeği arasında 40 sn (düz yeşil sis yerine)
	_fog_t += delta
	if is_instance_valid(env_node) and env_node.environment:
		var k := 0.5 + 0.5 * sin(_fog_t * TAU / 40.0)
		env_node.environment.fog_light_color = Color("2a2238").lerp(Color("1f3a40"), k)
	for s in _spinners:
		var n: Node3D = s[0]
		if is_instance_valid(n):
			n.rotate_object_local(s[1], float(s[2]) * delta)
	for b in _bobbers:
		var n: Node3D = b[0]
		if is_instance_valid(n):
			n.position.y = float(b[1]) + sin(_fog_t * float(b[3]) + float(b[4])) * float(b[2])
	_amb_tick(delta)
	_coil_tick(delta)
	# Sabri konuşurken gazeteyi göğsüne indirir, susunca yine yüzünün önüne kaldırır (eller "hold_paper" duruşunda)
	if is_instance_valid(_rb_paper) and is_instance_valid(_rb_sabri_p):
		var py := 1.1 if _rb_sabri_p.talking else 1.42
		_rb_paper.position.y = lerpf(_rb_paper.position.y, py, clampf(delta * 6.0, 0.0, 1.0))
		_rb_paper.position.z = lerpf(_rb_paper.position.z, 0.4 if _rb_sabri_p.talking else 0.36, clampf(delta * 6.0, 0.0, 1.0))


func _ready() -> void:
	Audio.voice_space("room")
	_build_env()
	_build_office()
	_build_corridor()
	_build_depot()
	_build_desk()
	_build_lift()
	_build_rooms()
	_build_life()
	_defight()
	_lod_pass()
	_attach.call_deferred()


## Uzaktaki küçük ayrıntılar çizilmez (görünürlük menzili): 84 m'lik koridor boyunca yüzlerce kulp, kâğıt, düğme
## ve küçük yazı her karede çiziliyordu (her biri dış hat geçişiyle iki çizim). Kişiler ve büyük parçalar dokunulmaz.
func _lod_pass() -> void:
	var st: Array = get_children()
	while st.size() > 0:
		var n: Node = st.pop_back()
		if n is Person:
			continue
		st.append_array(n.get_children())
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			if mi.mesh == null:
				continue
			var sz := mi.mesh.get_aabb().size
			var sc := mi.global_basis.get_scale()
			var big := maxf(sz.x * absf(sc.x), maxf(sz.y * absf(sc.y), sz.z * absf(sc.z)))
			if big < 0.35:
				mi.visibility_range_end = 14.0
			elif big < 1.2:
				mi.visibility_range_end = 30.0
		elif n is Label3D:
			var lb := n as Label3D
			lb.visibility_range_end = 16.0 if lb.font_size <= 24 else (32.0 if lb.font_size <= 40 else 0.0)
		elif n is OmniLight3D:
			var ol := n as OmniLight3D
			if not ol.shadow_enabled and ol.omni_range < 9.0:
				ol.distance_fade_enabled = true
				ol.distance_fade_begin = 24.0
				ol.distance_fade_length = 8.0


## Aynı düzlemde üst üste binen farklı renkli yüzeyler titrer (kullanıcı: "duvar köşeleri, kenarlar yanıp sönüyor").
## Kural: bir kutunun ucu (yüz normali en uzun ekseninde) diğerinin geniş yüzüyle aynı düzlemdeyse uç 8 mm kısalır
## (oda duvarının ucu koridor duvarının yüzünde); iki geniş yüz aynı düzlemdeyse küçük olan 8 mm öne çıkar
## (pano lambrinin, levha duvarın önünde), büyük yapı yerinde kalır. Yüzün önü başka bir katının içindeyse (görünmez)
## dokunulmaz. tests/_tmp/zfight.gd aynı taramayı rapor olarak yapar.
func _defight() -> void:
	const EPS := 0.004
	const NUDGE := 0.008
	var meshes: Array = []
	var st: Array = [self]
	while st.size() > 0:
		var n: Node = st.pop_back()
		if n is Person:
			continue
		for c in n.get_children():
			st.push_front(c)
		if n is MeshInstance3D and (n as MeshInstance3D).mesh and (n as MeshInstance3D).is_visible_in_tree():
			var mi := n as MeshInstance3D
			var bs := mi.global_basis
			var ok := true
			for col in [bs.x.normalized(), bs.y.normalized(), bs.z.normalized()]:
				if maxf(absf(col.x), maxf(absf(col.y), absf(col.z))) < 0.999:
					ok = false
			if not ok:
				continue
			var m = mi.material_override
			if m == null and mi.mesh.get_surface_count() > 0:
				m = mi.mesh.surface_get_material(0)
			var c: Color = (m as StandardMaterial3D).albedo_color if m is StandardMaterial3D else Color(0.123, 0.456, 0.789)
			meshes.append([mi, c])
	# Bir kaydırma yeni bir çakışma doğurabilir (paspas yukarı kayınca üstündeki ışık lekesine değer): en çok 5 tur
	var focus := {}
	for _pass in 5:
		var all: Array = []
		for e in meshes:
			var mi: MeshInstance3D = e[0]
			all.append([mi.global_transform * mi.mesh.get_aabb(), mi, e[1]])
		var buckets := {}
		for it in all:
			var ab: AABB = it[0]
			if ab.size[ab.size.min_axis_index()] >= 0.015:
				for bz in range(floori(ab.position.z), floori(ab.end.z) + 1):
					if not buckets.has(bz):
						buckets[bz] = []
					buckets[bz].append(ab.grow(-0.001))
		# 2. turdan sonra yalnız bir önceki turda oynayanlar ve onlara değenler yeniden taranır
		var items: Array = all
		if _pass > 0:
			items = []
			var fb: Array = []
			for it in all:
				if focus.has((it[1] as Node).get_instance_id()):
					fb.append((it[0] as AABB).grow(0.02))
			for it in all:
				for g in fb:
					if (g as AABB).intersects(it[0]):
						items.append(it)
						break
		# Koridor z boyunca 84 m uzun, x'te dar: z'ye göre sıralı süpürme ve 1 m'lik z kovaları
		items.sort_custom(func(p, q): return (p[0] as AABB).position.z < (q[0] as AABB).position.z)
		focus = {}
		var moved := {}
		var count := 0
		for i in items.size():
			var a: AABB = items[i][0]
			for j in range(i + 1, items.size()):
				var c: AABB = items[j][0]
				if c.position.z > a.end.z + EPS:
					break
				if (items[i][2] as Color).is_equal_approx(items[j][2]):
					continue
				for ax in 3:
					var o1 := (ax + 1) % 3
					var o2 := (ax + 2) % 3
					if minf(a.end[o1], c.end[o1]) - maxf(a.position[o1], c.position[o1]) <= 0.01:
						continue
					if minf(a.end[o2], c.end[o2]) - maxf(a.position[o2], c.position[o2]) <= 0.01:
						continue
					for sd in [1, -1]:
						var fa: float = a.end[ax] if sd > 0 else a.position[ax]
						var fc: float = c.end[ax] if sd > 0 else c.position[ax]
						if absf(fa - fc) >= EPS:
							continue
						# Ortak yüzün 1 cm önü başka bir katının içindeyse ya da zeminin altındaysa görünmez: dokunma.
						# Ortası ve dört yanı yoklanır: ortadaki bir eşya ışık lekesinin yalnız ortasını örter
						var lo1 := maxf(a.position[o1], c.position[o1])
						var hi1 := minf(a.end[o1], c.end[o1])
						var lo2 := maxf(a.position[o2], c.position[o2])
						var hi2 := minf(a.end[o2], c.end[o2])
						var ga := a.grow(-0.001)
						var gc := c.grow(-0.001)
						var hidden := true
						for f in [Vector2(0.5, 0.5), Vector2(0.15, 0.15), Vector2(0.85, 0.15), Vector2(0.15, 0.85), Vector2(0.85, 0.85)]:
							var p := Vector3.ZERO
							p[o1] = lerpf(lo1, hi1, f.x)
							p[o2] = lerpf(lo2, hi2, f.y)
							p[ax] = fa + 0.01 * sd
							if p.y < 0.0:
								continue
							var cover := false
							for h in buckets.get(floori(p.z), []):
								if (h as AABB).has_point(p) and h != ga and h != gc:
									cover = true
									break
							if not cover:
								hidden = false
								break
						if hidden:
							continue
						var cap_a := a.size.max_axis_index() == ax and a.size[ax] > 0.05
						var cap_c := c.size.max_axis_index() == ax and c.size[ax] > 0.05
						var pick: int
						var dir := float(sd)
						if cap_a != cap_c:
							pick = i if cap_a else j        # uç geri çekilir
							dir = -dir
						elif cap_a:
							# iki uç aynı düzlemde (iki odanın ortak duvarı koridorda bitiyor): küçüğü geri çekilir
							pick = i if a.size[o1] * a.size[o2] < c.size[o1] * c.size[o2] else j
							dir = -dir
						else:
							# küçük olan öne çıkar; koridor duvarı, tavan gibi büyükler yerinde kalır
							pick = i if a.size[o1] * a.size[o2] < c.size[o1] * c.size[o2] else j
						var mi: MeshInstance3D = items[pick][1]
						var box := mi.mesh is BoxMesh
						var key := "%d_%d_%d" % [mi.get_instance_id(), ax, sd if box else 0]
						if moved.has(key):
							continue
						moved[key] = true
						focus[mi.get_instance_id()] = true
						count += 1
						var pb: AABB = items[pick][0]
						if not box and pb.size[ax] < 0.001:
							# ince düzlem (QuadMesh): baktığı yöne çıkar, yoksa büyüğün arkasına gömülür
							var nz := mi.global_basis.z[ax]
							if absf(nz) > 0.5:
								dir = signf(nz)
						var off := Vector3.ZERO
						off[ax] = dir * NUDGE
						if box:
							# Kutunun yalnız o yüzü oynar (uç kısalır ya da yüz öne uzar), karşı yüz yerinde kalır:
							# bütün kutu kaysa karşı yüz başka bir yüzle çakışır ya da kıl payı yarık açılırdı
							var bs := mi.global_basis
							for k in 3:
								if absf(bs[k].normalized()[ax]) > 0.999:
									var bm := (mi.mesh as BoxMesh).duplicate() as BoxMesh
									var sz := bm.size
									sz[k] = maxf(0.01, sz[k] + dir * float(sd) * NUDGE / bs[k].length())
									bm.size = sz
									mi.mesh = bm
									break
							mi.global_position += off * 0.5
						else:
							mi.global_position += off
		if count == 0:
			break


## Odalar (v0.99.96): her biri kendi duvarı, ışığı, yazısı ve etkileşimiyle
func _build_rooms() -> void:
	_rb_build()
	_rc_build()
	_fg_build()
	_wait_sign()
	_amb_setup()


## Canlılık (v0.99.96): memurlar, kapsüller, saatler, sesler
func _build_life() -> void:
	_ld_build()


# ---------------------------------------------------------------- ortam

func _build_env() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("1b1626")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("f1d9b0")
	e.ambient_light_energy = 0.5
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	# Koridor sise gömülür ama sis düz yeşil değil: mor ile camgöbeği arasında nefes alır (_process)
	e.fog_enabled = true
	e.fog_light_color = Color("2a2238")
	e.fog_density = 0.035
	e.glow_enabled = true
	e.glow_intensity = 0.6
	e.glow_hdr_threshold = 1.0
	env.environment = e
	add_child(env)
	env_node = env


func _checker(c1: Color, c2: Color) -> ImageTexture:
	var img := Image.create(2, 2, false, Image.FORMAT_RGB8)
	img.set_pixel(0, 0, c1)
	img.set_pixel(1, 1, c1)
	img.set_pixel(1, 0, c2)
	img.set_pixel(0, 1, c2)
	return ImageTexture.create_from_image(img)


func _floor(size: Vector2, pos: Vector3, c1: Color, c2: Color, tiles: float) -> void:
	var body := Props.solid(self, Vector3(size.x, 0.2, size.y), pos + Vector3(0, -0.1, 0), c1)
	var m := StandardMaterial3D.new()
	m.albedo_texture = _checker(c1, c2)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3(tiles, tiles, tiles)
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.roughness = 0.6
	(body.get_child(0) as MeshInstance3D).material_override = m


func _wall(size: Vector3, pos: Vector3, color := C_WALL) -> void:
	Props.set_pattern(Props.solid(self, size, pos, color), color, "wall")


func _tube(pos: Vector3, lit := true) -> void:
	Props.box(self, Vector3(0.18, 0.06, 1.3), pos, Color("e8f4e0"), Vector3.ZERO, 2.2 if lit else 0.2)
	Props.box(self, Vector3(0.26, 0.04, 1.4), pos + Vector3(0, 0.05, 0), C_METAL)


# ---------------------------------------------------------------- Nihat'ın odası

## Krem üst duvar + petrol yeşili lambri, parke, kilim, kaset tavan, sarkıt lamba, doğu duvarda büyük zaman penceresi.

const _OF_YEARS := YEARS
## Çağlar küresinin durabileceği yerler: [TR, EN]; sonuncusu "Bütçe Yok" (BUR_GLOBE_2 şakası)
const _OF_ERAS := [["Roma", "Rome"], ["Selçuklu", "Seljuk"], ["Bizans", "Byzantium"], ["1453 Kuşatması", "Siege of 1453"],
	["Cumhuriyet", "Republic"], ["Yeniçağ", "Early Modern"], ["2150", "2150"], ["Bütçe Yok", "No Budget"]]

var _of_slats: Array = []             # jaluzi çıtaları (9)
var _of_blind_closed := false
var _of_ring: Node3D                  # saatin rakam halkası (akrepsiz, yalnız döner)
var _of_ring_step := 0
var _of_tw_paper: MeshInstance3D      # daktiloda yükselen kâğıt
var _of_tw_busy := false
var _of_stamp_node: Node3D
var _of_stamp_lbl: Label3D
var _of_stamp_busy := false
var _of_lever: Node3D
var _of_tube_busy := false
var _of_drawer: Node3D
var _of_drawer_lbl: Label3D
var _of_drawer_busy := false
var _of_founder: Node3D
var _of_cal: Node3D
var _of_cal_busy := false
var _of_globe: Node3D
var _of_globe_lbl: Label3D
var _of_globe_busy := false


func _build_office() -> void:
	var w := OFFICE_W
	var d := OFFICE_D
	var h := OFFICE_H
	_of_slats.clear()
	_of_blind_closed = false
	_of_ring_step = 0
	# Zemin: sıcak parke (iki kahve) + kilim; tavan
	_floor(Vector2(w, d), Vector3(0, 0, d / 2), Color("8a6038"), Color("73502e"), 1.2)
	Props.solid(self, Vector3(w, 0.2, d), Vector3(0, h + 0.1, d / 2), C_CEIL)
	Props.box(self, Vector3(3.4, 0.01, 2.4), Vector3(0, 0.005, 2.8), C_RUG_EDGE)
	Props.box(self, Vector3(3.2, 0.012, 2.2), Vector3(0, 0.01, 2.8), C_RUG)
	_of_shell(w, d, h)
	_of_ceiling(w, d, h)
	_of_window()
	_of_desk()
	_of_cabinets()
	_of_wall_art(d)
	_of_clock_and_calendar(w)
	_of_corner_props()
	# Kapının üstünde tabela (koridor tarafı)
	Props.label(self, "DENETÇİ N. ZAMANOĞLU", Vector3(0, 2.55, -0.21), 30, Color("e8e2c8"), Vector3(0, 180, 0), 1.3)


## Duvarlar: krem üst, petrol yeşili lambri, pirinç bant; doğu duvarda pencere boşluğu (z 1.7..4.3, y 0.95..2.55)
func _of_shell(w: float, d: float, h: float) -> void:
	# Arka duvar
	_wall(Vector3(w, h, 0.2), Vector3(0, h / 2, d + 0.1), C_CREAM)
	_of_wain(Vector3(0, 0.5, d - 0.02), Vector3(w, 1.0, 0.04))
	# Batı duvar (z 0.15..1.85, y 1.05..2.25 boş kalır: lambri 1.04'te biter)
	_wall(Vector3(0.2, h, d), Vector3(-w / 2 - 0.1, h / 2, d / 2), C_CREAM)
	_of_wain(Vector3(-w / 2 + 0.02, 0.5, d / 2), Vector3(0.04, 1.0, d))
	# Kapılı ön duvar (koridora açılır, 1.4 m kapı)
	_wall(Vector3(w / 2 - 0.7, h, 0.2), Vector3(-(w / 2 + 0.7) / 2, h / 2, -0.1), C_CREAM)
	_wall(Vector3(w / 2 - 0.7, h, 0.2), Vector3((w / 2 + 0.7) / 2, h / 2, -0.1), C_CREAM)
	_wall(Vector3(1.4, h - 2.3, 0.2), Vector3(0, 2.3 + (h - 2.3) / 2, -0.1), C_CREAM)
	_of_wain(Vector3(-(w / 2 + 0.7) / 2, 0.5, 0.02), Vector3(w / 2 - 0.7, 1.0, 0.04))
	_of_wain(Vector3((w / 2 + 0.7) / 2, 0.5, 0.02), Vector3(w / 2 - 0.7, 1.0, 0.04))
	# Kapı kasası (ceviz)
	Props.box(self, Vector3(0.08, 2.3, 0.26), Vector3(-0.74, 1.15, -0.1), C_WOOD_DARK)
	Props.box(self, Vector3(0.08, 2.3, 0.26), Vector3(0.74, 1.15, -0.1), C_WOOD_DARK)
	Props.box(self, Vector3(1.56, 0.08, 0.26), Vector3(0, 2.34, -0.1), C_WOOD_DARK)
	# Doğu duvar: pencere boşluğunun iki yanı normal duvar, altı/üstü 0.4 m kalın (pencere yuvası)
	_wall(Vector3(0.2, h, 1.7), Vector3(w / 2 + 0.1, h / 2, 0.85), C_CREAM)
	_wall(Vector3(0.2, h, 1.7), Vector3(w / 2 + 0.1, h / 2, 5.15), C_CREAM)
	_wall(Vector3(0.4, 0.95, 2.6), Vector3(w / 2 + 0.2, 0.475, 3.0), C_TEAL)
	_wall(Vector3(0.4, h - 2.55, 2.6), Vector3(w / 2 + 0.2, 2.55 + (h - 2.55) / 2, 3.0), C_CREAM)
	_of_wain(Vector3(w / 2 - 0.02, 0.5, 0.85), Vector3(0.04, 1.0, 1.7))
	_of_wain(Vector3(w / 2 - 0.02, 0.5, 5.15), Vector3(0.04, 1.0, 1.7))


## Lambri: petrol yeşili kutu + üstünde pirinç bant (pos: lambrinin merkezi, y 0.5)
func _of_wain(pos: Vector3, size: Vector3) -> void:
	Props.box(self, size, pos, C_TEAL)
	var bs := Vector3(size.x + (0.02 if size.x < 0.1 else 0.0), 0.05, size.z + (0.02 if size.z < 0.1 else 0.0))
	Props.box(self, bs, Vector3(pos.x, 1.015, pos.z), C_BRASS)


## Kaset tavan kirişleri + sarkıt lamba (gölgeli tungsten) -- floresan yok
func _of_ceiling(w: float, d: float, h: float) -> void:
	# Kirişler gölge atmaz: lambanın üstünde kalırlar, tavana ve duvar başına düşen gölgeleri (düşük çözünürlüklü
	# küp gölge haritası) testere dişi gibi tırtıklı görünüyordu
	for z in [1.5, 4.5]:
		var bm := Props.box(self, Vector3(w - 0.2, 0.14, 0.22), Vector3(0, h - 0.07, z), C_WOOD_DARK)
		bm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for x in [-1.5, 1.5]:
		var bm := Props.box(self, Vector3(0.22, 0.14, d - 0.2), Vector3(x, h - 0.07, d / 2), C_WOOD_DARK)
		bm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Sarkıt: ip, abajur (gölge atmaz), ampul
	Props.cyl(self, 0.008, 0.3, Vector3(0, h - 0.15, 3.0), Color("222222"), Vector3.ZERO, 4)
	var shade := Props.cyl(self, 0.3, 0.2, Vector3(0, 2.72, 3.0), Color("2f5a4a"), Vector3.ZERO, 12, 0.07)
	shade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var bulb := Props.ball(self, 0.08, Vector3(0, 2.58, 3.0), Color("ffe6b0"), Vector3.ONE, 8, 2.0)
	bulb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_bulb(Vector3(0, 2.5, 3.0), Color("ffd9a0"), 1.0, 7.0, true)


## BÜYÜK PENCERE (doğu duvar): yuva, ahşap çerçeve, zaman manzarası, pencere oturağı, perde, jaluzi
func _of_window() -> void:
	# Çerçeve: yuvanın iç yüzünü kaplayan ceviz sövesi (0.4 derin) + orta denk
	Props.box(self, Vector3(0.4, 0.1, 2.7), Vector3(3.2, 2.5, 3.0), C_WOOD_DARK)
	Props.box(self, Vector3(0.45, 0.06, 2.8), Vector3(3.18, 0.98, 3.0), C_WOOD)
	Props.box(self, Vector3(0.4, 1.6, 0.1), Vector3(3.2, 1.75, 1.75), C_WOOD_DARK)
	Props.box(self, Vector3(0.4, 1.6, 0.1), Vector3(3.2, 1.75, 4.25), C_WOOD_DARK)
	Props.box(self, Vector3(0.08, 1.5, 0.06), Vector3(3.34, 1.75, 3.0), C_WOOD_DARK)
	# Manzara: gölgelendirici dörtgen, +Z odanın içine baksın (rotasyon y -90: +Z → -x)
	var win := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(2.6, 1.6)
	win.mesh = q
	var sm := ShaderMaterial.new()
	sm.shader = load("res://assets/shaders/time_window.gdshader")
	sm.set_shader_parameter("quad_size", Vector2(2.6, 1.6))
	sm.set_shader_parameter("view_ref", 1.6)
	win.material_override = sm
	win.position = Vector3(3.38, 1.75, 3.0)
	win.rotation_degrees = Vector3(0, -90, 0)
	win.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(win)
	# Görünmez cam: oyuncu oturağa çıkıp yuvaya girmesin
	var gb := StaticBody3D.new()
	gb.position = Vector3(3.3, 1.75, 3.0)
	var gcs := CollisionShape3D.new()
	var gbs := BoxShape3D.new()
	gbs.size = Vector3(0.1, 1.6, 2.6)
	gcs.shape = gbs
	gb.add_child(gcs)
	add_child(gb)
	# Pencere oturağı: ahşap sedir + hardal minder
	Props.solid(self, Vector3(0.5, 0.42, 2.2), Vector3(2.7, 0.21, 3.0), C_WOOD)
	Props.box(self, Vector3(0.46, 0.08, 2.1), Vector3(2.7, 0.46, 3.0), C_MUSTARD)
	# Perdeler: iki yanda toplanmış kalın bordo-altın kumaş, korniş
	for cz: float in [1.45, 4.55]:
		for k in 4:
			var fz := cz - 0.21 + k * 0.14
			Props.box(self, Vector3(0.1 if k % 2 == 0 else 0.16, 2.75, 0.15), Vector3(2.88 - (0.0 if k % 2 == 0 else 0.03), 1.45, fz), Color("8a2a2c") if k % 2 == 0 else Color("a8383a"))
		Props.box(self, Vector3(0.2, 0.06, 0.6), Vector3(2.86, 1.25, cz), C_BRASS)       # perde bağı
	Props.cyl(self, 0.02, 3.9, Vector3(2.85, 2.88, 3.0), C_BRASS, Vector3(90, 0, 0), 8)
	# Jaluzi: 9 çıta; açıkken üstte yığılı, kapalıyken pencereyi örter (ip sağ yanda)
	Props.box(self, Vector3(0.06, 0.06, 2.4), Vector3(3.02, 2.46, 3.0), C_WOOD_DARK)
	for i in 9:
		var s := Props.box(self, Vector3(0.03, 0.17, 2.38), Vector3(3.02, 2.4 + i * 0.012, 3.0), Color("e0d2a8"))
		_of_slats.append(s)
	Props.cyl(self, 0.008, 1.1, Vector3(3.0, 1.9, 4.12), Color("e9dcb8"), Vector3.ZERO, 4)
	Props.ball(self, 0.025, Vector3(3.0, 1.33, 4.12), C_BRASS, Vector3.ONE, 6)
	# Pencereden odaya sızan soğuk mor ışık (gölgesiz)
	_bulb(Vector3(2.5, 1.7, 3.0), Color("9a8cff"), 0.9, 4.5)
	# Etkileşimler. "window" bölüm 3'ün: yuvanın içinde, jaluzinin arkasında
	Props.interactable(self, "window", Vector3(0.3, 1.6, 2.6), Vector3(3.15, 1.75, 3.0))
	_reg("bur_blind", Vector3(0.3, 1.2, 0.5), Vector3(2.85, 1.75, 4.12), "UI_BUR_PULL", _of_blind_use)


func _of_blind_use() -> void:
	_of_blind_closed = not _of_blind_closed
	Audio.sfx("cloth", -8.0)
	var tw := create_tween()
	tw.set_parallel(true)
	for i in _of_slats.size():
		var s: Node3D = _of_slats[i]
		if not is_instance_valid(s):
			continue
		var ty: float = (2.4 - i * 0.18) if _of_blind_closed else (2.4 + i * 0.012)
		tw.tween_property(s, "position:y", ty, 0.5 + i * 0.05).set_trans(Tween.TRANS_SINE)
	_say("BUR_BLIND" if _of_blind_closed else "BUR_BLIND_2")


## Masa, sandalye, daktilo, yeşil lamba, damga takımı, pnömatik tüp ve kolu
func _of_desk() -> void:
	var desk_z := 4.3
	Props.set_pattern(Props.solid(self, Vector3(2.2, 0.08, 1.0), Vector3(0, 0.78, desk_z), C_WOOD), C_WOOD, "wood")
	for x in [-1.0, 1.0]:
		Props.box(self, Vector3(0.12, 0.74, 0.9), Vector3(x, 0.37, desk_z), C_WOOD_DARK)
	Props.box(self, Vector3(0.5, 0.05, 0.5), Vector3(0, 0.48, desk_z + 0.9), C_WOOD_DARK)
	Props.box(self, Vector3(0.5, 0.6, 0.05), Vector3(0, 0.8, desk_z + 1.15), C_WOOD_DARK)
	for lx in [-0.21, 0.21]:   # sandalye ayakları (oturak havada durmasın)
		for lz in [desk_z + 0.69, desk_z + 1.11]:
			Props.box(self, Vector3(0.04, 0.456, 0.04), Vector3(lx, 0.228, lz), C_WOOD_DARK)
	_typewriter(Vector3(0.45, 0.82, desk_z - 0.05), 0.0)
	# Daktiloda yükselen kâğıt (başta gizli)
	_of_tw_paper = Props.box(self, Vector3(0.26, 0.2, 0.004), Vector3(0.45, 1.1, 4.07), Color("fffbe8"))
	_of_tw_paper.visible = false
	# Dosya (pnömatik tüpten gelecek)
	file_node = Node3D.new()
	file_node.position = Vector3(-0.45, 0.83, desk_z - 0.15)
	add_child(file_node)
	Props.box(file_node, Vector3(0.36, 0.03, 0.26), Vector3.ZERO, Color("c9a45a"))
	Props.box(file_node, Vector3(0.2, 0.005, 0.05), Vector3(0, 0.017, -0.05), Color("a8242a"))
	Props.label(file_node, "1453-T", Vector3(0.0, 0.021, 0.04), 30, Color("3a2a18"), Vector3(-90, 0, 0), 0.22)
	file_node.visible = false
	Props.interactable(file_node, "file", Vector3(0.5, 0.3, 0.4), Vector3(0, 0.1, 0)).collision_layer = 0
	# Pnömatik pirinç tüp: tavandan masanın köşesine inen kap
	Props.cyl(self, 0.09, 2.1, Vector3(-1.0, 1.95, 4.6), C_BRASS, Vector3.ZERO, 10)
	Props.cyl(self, 0.13, 0.12, Vector3(-1.0, 0.88, 4.6), C_BRASS, Vector3.ZERO, 10)
	capsule = Node3D.new()
	capsule.position = Vector3(-1.0, 2.9, 4.6)
	add_child(capsule)
	Props.cyl(capsule, 0.07, 0.22, Vector3.ZERO, Color("6f8a96"), Vector3.ZERO, 8)
	capsule.visible = false
	# Kırmızı kol tüpün yanında
	Props.box(self, Vector3(0.1, 0.05, 0.07), Vector3(-0.78, 0.845, 4.6), C_WOOD_DARK)
	_of_lever = Node3D.new()
	_of_lever.position = Vector3(-0.78, 0.87, 4.6)
	add_child(_of_lever)
	Props.cyl(_of_lever, 0.012, 0.2, Vector3(0, 0.1, 0), Color("b8323a"), Vector3.ZERO, 6)
	Props.ball(_of_lever, 0.03, Vector3(0, 0.21, 0), Color("b8323a"), Vector3.ONE, 8)
	_reg("bur_tube", Vector3(0.5, 0.8, 0.5), Vector3(-1.0, 1.25, 4.6), "UI_BUR_PULL", _of_tube_use)
	# Yeşil bankacı lambası + küçük sıcak ışık
	Props.box(self, Vector3(0.14, 0.025, 0.1), Vector3(-0.35, 0.8325, 4.62), C_BRASS)
	Props.cyl(self, 0.008, 0.24, Vector3(-0.35, 0.965, 4.62), C_BRASS, Vector3.ZERO, 5)
	Props.cyl(self, 0.055, 0.26, Vector3(-0.35, 1.1, 4.62), Color("1f6a45"), Vector3(0, 0, 90), 10, -1.0, 0.25)
	_glow(self, Vector3(-0.35, 0.83, 4.55), Vector2(0.7, 0.5), Color("ffd890"), Vector3(-90, 0, 0), 0.35)     # masaya düşen ışık
	# Damga takımı: kırmızı ped, sap damga, iki form
	Props.box(self, Vector3(0.14, 0.015, 0.1), Vector3(0.82, 0.8275, 3.95), Color("a8242a"))
	_of_stamp_node = Node3D.new()
	_of_stamp_node.position = Vector3(0.98, 0.82, 3.95)
	add_child(_of_stamp_node)
	Props.box(_of_stamp_node, Vector3(0.08, 0.025, 0.05), Vector3(0, 0.0125, 0), C_WOOD_DARK)
	Props.cyl(_of_stamp_node, 0.02, 0.1, Vector3(0, 0.075, 0), C_WOOD, Vector3.ZERO, 8)
	Props.ball(_of_stamp_node, 0.03, Vector3(0, 0.14, 0), C_WOOD, Vector3.ONE, 8)
	Props.box(self, Vector3(0.22, 0.004, 0.3), Vector3(0.93, 0.822, 4.42), C_PAPER, Vector3(0, -6, 0))
	Props.box(self, Vector3(0.22, 0.004, 0.3), Vector3(0.95, 0.826, 4.4), Color("f4eed8"), Vector3(0, 8, 0))
	_reg("bur_stamp", Vector3(0.45, 0.3, 0.6), Vector3(0.98, 0.97, 4.15), "UI_BUR_STAMP", _of_stamp_use)
	_reg("bur_typewriter", Vector3(0.6, 0.4, 0.5), Vector3(0.45, 1.0, 4.25), "UI_BUR_USE", _of_typewriter_use)


func _of_typewriter_use() -> void:
	_say(_next("bur_typewriter", ["BUR_TYPEWRITER", "BUR_TYPEWRITER_2"]))
	if _of_tw_busy or not is_instance_valid(_of_tw_paper):
		return
	_of_tw_busy = true
	Audio.sfx("typewriter", -8.0)
	_of_tw_paper.position.y = 1.1
	_of_tw_paper.visible = true
	var tw := create_tween()
	tw.tween_property(_of_tw_paper, "position:y", 1.3, 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func(): Audio.sfx("typewriter_bell", -8.0))
	tw.tween_interval(2.2)
	tw.tween_callback(_of_typewriter_done)


func _of_typewriter_done() -> void:
	if is_instance_valid(_of_tw_paper):
		_of_tw_paper.visible = false
		_of_tw_paper.position.y = 1.1
	_of_tw_busy = false


func _of_stamp_use() -> void:
	if _of_stamp_busy or not is_instance_valid(_of_stamp_node):
		return
	var idx: int = _count("bur_stamp") % 3
	var key: String = _next("bur_stamp", ["BUR_STAMP_OK", "BUR_STAMP_NO", "BUR_STAMP_MISSING"])
	_of_stamp_busy = true
	var rest := Vector3(0.98, 0.82, 3.95)
	var spot := Vector3(0.95, 0.83, 4.4)
	var tw := create_tween()
	tw.tween_property(_of_stamp_node, "position", rest + Vector3(0, 0.1, 0), 0.15)
	tw.tween_property(_of_stamp_node, "position", spot + Vector3(0, 0.1, 0), 0.25).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_of_stamp_node, "position", spot, 0.1)
	tw.tween_callback(_of_stamp_hit.bind(idx, key))
	tw.tween_property(_of_stamp_node, "position", spot + Vector3(0, 0.1, 0), 0.12)
	tw.tween_property(_of_stamp_node, "position", rest, 0.25).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_of_stamp_done)


func _of_stamp_hit(idx: int, key: String) -> void:
	Audio.sfx("stamp", -4.0)
	if is_instance_valid(_of_stamp_lbl):
		_of_stamp_lbl.queue_free()
	var tr_txt := ["ONAYLANDI", "RED", "EKSİK EVRAK"]
	var en_txt := ["APPROVED", "REJECTED", "MISSING"]
	var cols := [Color("2a6a3a"), Color("a8242a"), Color("b86a1a")]
	_of_stamp_lbl = _lbl(self, tr_txt[idx], en_txt[idx], Vector3(0.95, 0.832, 4.4), 36, cols[idx], Vector3(-90, 180, 0), 0.2)
	_say(key)


func _of_stamp_done() -> void:
	_of_stamp_busy = false


func _of_tube_use() -> void:
	_say(_next("bur_tube", ["BUR_TUBE", "BUR_TUBE_2"]))
	if _of_tube_busy or not is_instance_valid(_of_lever):
		return
	_of_tube_busy = true
	Audio.sfx("whoosh_fly", -8.0)
	var lt := create_tween()
	lt.tween_property(_of_lever, "rotation_degrees:x", -50.0, 0.2)
	lt.tween_property(_of_lever, "rotation_degrees:x", 0.0, 0.35).set_trans(Tween.TRANS_BACK)
	lt.tween_callback(_of_tube_done)
	# Ayrı, boş bir kapsül (Bölüm 3'ün `capsule`ına dokunmaz): tüpün dışında bir manşon gibi fırlar
	var cap := Node3D.new()
	cap.position = Vector3(-1.0, 1.0, 4.6)
	add_child(cap)
	Props.cyl(cap, 0.1, 0.2, Vector3.ZERO, Color("6f8a96"), Vector3.ZERO, 8)
	var ct := cap.create_tween()
	ct.tween_property(cap, "position:y", 2.95, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	ct.tween_callback(cap.queue_free)


func _of_tube_done() -> void:
	_of_tube_busy = false


## Dosya dolapları (sol: çekmeceli, üstünde radyo; sağ: saksı) -- ayrıca "plant"
func _of_cabinets() -> void:
	for x in [-2.5, 2.5]:
		Props.set_pattern(Props.solid(self, Vector3(0.6, 1.4, 0.6), Vector3(x, 0.7, 5.55), Color("6f7a70")), Color("6f7a70"), "wall")
		for i in 3:
			if x < 0.0 and i == 1:
				continue       # ortadaki çekmece hareketli
			Props.box(self, Vector3(0.5, 0.02, 0.02), Vector3(x, 0.35 + i * 0.42, 5.24), C_BRASS)
	# Hareketli çekmece (sol dolap, orta): ön yüz, tutamak, tepsi, klasör, yıl etiketi
	_of_drawer = Node3D.new()
	_of_drawer.position = Vector3(-2.5, 0.77, 5.24)
	add_child(_of_drawer)
	Props.box(_of_drawer, Vector3(0.5, 0.36, 0.03), Vector3(0, 0, -0.02), Color("5c6e66"))
	Props.box(_of_drawer, Vector3(0.14, 0.025, 0.025), Vector3(0, 0.05, -0.045), C_BRASS)
	Props.box(_of_drawer, Vector3(0.46, 0.02, 0.5), Vector3(0, -0.15, 0.25), C_WOOD_DARK)
	Props.box(_of_drawer, Vector3(0.34, 0.03, 0.4), Vector3(0, -0.125, 0.25), Color("c9a45a"))
	_of_drawer_lbl = Props.label(_of_drawer, "MÖ 776", Vector3(0, -0.108, 0.2), 34, Color("3a2a18"), Vector3(-90, 180, 0), 0.3)
	_of_drawer_lbl.visible = false
	_reg("bur_drawer", Vector3(0.5, 0.4, 0.4), Vector3(-2.5, 0.77, 5.2), "UI_BUR_OPEN", _of_drawer_use)
	# Radyo (sol dolabın üstünde)
	Props.box(self, Vector3(0.34, 0.2, 0.16), Vector3(-2.5, 1.5, 5.55), Color("8a5a30"))
	Props.box(self, Vector3(0.15, 0.13, 0.01), Vector3(-2.56, 1.5, 5.468), Color("2b2118"))
	Props.cyl(self, 0.02, 0.02, Vector3(-2.4, 1.54, 5.465), C_BRASS, Vector3(90, 0, 0), 8)
	Props.cyl(self, 0.02, 0.02, Vector3(-2.4, 1.47, 5.465), C_BRASS, Vector3(90, 0, 0), 8)
	Props.cyl(self, 0.004, 0.3, Vector3(-2.38, 1.7, 5.6), C_METAL, Vector3(0, 0, -20), 4)
	# Saksı bitkisi (sağ dolabın üstünde) + "plant" etkileşimi (Bölüm 3)
	Props.cyl(self, 0.18, 0.35, Vector3(2.5, 1.58, 5.55), Color("8a5a3a"), Vector3.ZERO, 8, 0.22)
	for i in 5:
		Props.cyl(self, 0.02, 0.4, Vector3(2.5 + (i - 2) * 0.05, 1.9, 5.55), Color("4f7a3a") if i % 2 == 0 else Color("62924a"), Vector3(0, i * 30, 20 - i * 10), 4)
	Props.interactable(self, "plant", Vector3(0.5, 0.6, 0.5), Vector3(2.5, 1.8, 5.55))


func _of_drawer_use() -> void:
	if _of_drawer_busy or not is_instance_valid(_of_drawer):
		return
	_of_drawer_busy = true
	var year: String = _OF_YEARS[randi() % _OF_YEARS.size()]
	_of_drawer_lbl.text = year
	_of_drawer_lbl.visible = true
	Audio.sfx("wood_creak", -8.0)
	_say(_next("bur_drawer", ["BUR_DRAWER", "BUR_DRAWER_2", "BUR_DRAWER_3"]))
	var third := _count("bur_drawer") == 3
	var tw := create_tween()
	tw.tween_property(_of_drawer, "position:z", 4.82, 0.4).set_trans(Tween.TRANS_SINE)
	if third:
		tw.tween_interval(1.3)
		tw.tween_callback(_of_drawer_second)
		tw.tween_interval(1.2)
	else:
		tw.tween_interval(2.4)
	tw.tween_property(_of_drawer, "position:z", 5.24, 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(_of_drawer_done)


func _of_drawer_second() -> void:
	_second(0, Vector3(-2.5, 0.77, 5.24) + Vector3(0, 0.2, 0))


func _of_drawer_done() -> void:
	if is_instance_valid(_of_drawer_lbl):
		_of_drawer_lbl.visible = false
	_of_drawer_busy = false


## Arka duvar: Form Z-1 (Bölüm 3), kurucu çerçevesi, "Ayın Memuru" çerçevesi
func _of_wall_art(d: float) -> void:
	# Form Z-1: arka duvarda çerçeve
	var fz := Node3D.new()
	fz.position = Vector3(0, 1.95, d - 0.02)
	fz.rotation_degrees.y = 180
	add_child(fz)
	Props.box(fz, Vector3(0.78, 0.98, 0.04), Vector3(0, 0, 0.0), C_BRASS)
	Props.box(fz, Vector3(0.66, 0.86, 0.045), Vector3(0, 0, 0.0), C_PAPER)
	Props.label(fz, "ZAMAN BÜROSU", Vector3(0, 0.33, 0.03), 26, Color("2a2a2a"), Vector3.ZERO, 0.5)
	Props.label(fz, "FORM Z-1", Vector3(0, 0.25, 0.03), 34, Color("8a1f1f"), Vector3.ZERO, 0.4)
	Props.label(fz, "KURULUŞ BELGESİ", Vector3(0, 0.17, 0.03), 18, Color("3a3a3a"), Vector3.ZERO, 0.4)
	for i in 6:
		Props.box(fz, Vector3(0.5, 0.008, 0.005), Vector3(0, 0.08 - i * 0.055, 0.025), Color("9a9a90"))
	Props.label(fz, "Kurucu:", Vector3(-0.17, -0.28, 0.03), 18, Color("3a3a3a"), Vector3.ZERO, 0.2)
	Props.label(fz, "T.", Vector3(0.08, -0.29, 0.03), 44, Color("1a2a6a"), Vector3.ZERO, 0.12)
	Props.cyl(fz, 0.07, 0.01, Vector3(0.2, -0.33, 0.03), Color("b8323a"), Vector3(90, 0, 0), 12)
	Props.interactable(self, "formz1", Vector3(0.9, 1.1, 0.4), Vector3(0, 1.95, d - 0.2))
	# Kurucunun çerçevesi: boş altın çerçeve, solmamış dikdörtgen, pirinç plaka "KURUCU"
	_of_founder = Node3D.new()
	_of_founder.position = Vector3(-1.5, 1.95, d - 0.02)
	_of_founder.rotation_degrees.y = 180
	add_child(_of_founder)
	Props.box(_of_founder, Vector3(0.62, 0.8, 0.03), Vector3.ZERO, Color("c9a23a"))
	Props.box(_of_founder, Vector3(0.5, 0.68, 0.035), Vector3.ZERO, Color("f6ecd0"))
	Props.box(_of_founder, Vector3(0.22, 0.05, 0.02), Vector3(0, -0.46, 0.015), C_BRASS)
	Props.label(_of_founder, "KURUCU", Vector3(0, -0.46, 0.03), 20, Color("3a2a18"), Vector3.ZERO, 0.19)
	_reg("bur_founder", Vector3(0.7, 0.9, 0.4), Vector3(-1.5, 1.9, 5.8), "UI_BUR_LOOK", _of_founder_use)
	# Ayın Memuru: koyu zeminde silüet
	var am := Node3D.new()
	am.position = Vector3(-2.35, 1.95, d - 0.02)
	am.rotation_degrees.y = 180
	add_child(am)
	Props.box(am, Vector3(0.5, 0.62, 0.03), Vector3.ZERO, C_BRASS)
	Props.box(am, Vector3(0.4, 0.52, 0.035), Vector3.ZERO, Color("2d3a48"))
	Props.ball(am, 0.07, Vector3(0, 0.06, 0.03), Color("d9b48f"), Vector3.ONE, 8)
	Props.box(am, Vector3(0.3, 0.14, 0.01), Vector3(0, -0.1, 0.03), Color("1f2a33"))
	Props.box(am, Vector3(0.16, 0.035, 0.02), Vector3(0, -0.36, 0.015), C_BRASS)


func _of_founder_use() -> void:
	_say(_next("bur_founder", ["BUR_FOUNDER", "BUR_FOUNDER_2"]))
	if not is_instance_valid(_of_founder):
		return
	Audio.sfx("wood_creak", -14.0)
	var tw := create_tween()
	tw.tween_property(_of_founder, "rotation_degrees:z", 4.0, 0.2)
	tw.tween_property(_of_founder, "rotation_degrees:z", 0.0, 0.5).set_trans(Tween.TRANS_BOUNCE)


## Akrepsiz saat (batı duvar, rakam halkası döner) + saat topuzu + yaprak takvim
func _of_clock_and_calendar(w: float) -> void:
	var clock := Node3D.new()
	clock.position = Vector3(-w / 2 + 0.03, 2.2, 3.0)
	clock.rotation_degrees.y = 90
	add_child(clock)
	Props.cyl(clock, 0.28, 0.05, Vector3.ZERO, Color("f4f1e6"), Vector3(90, 0, 0), 20)
	Props.ring(clock, 0.26, 0.3, Vector3.ZERO, C_BRASS, Vector3(90, 0, 0))
	_of_ring = Node3D.new()
	_of_ring.position = Vector3(0, 0, 0.03)
	clock.add_child(_of_ring)
	for i in 12:
		var a := TAU * i / 12.0
		var tick_col := Color("a8242a") if i == 0 else Color("2a2a2a")
		var tick_len := 0.08 if i % 3 == 0 else 0.05
		Props.box(_of_ring, Vector3(0.02, tick_len, 0.01), Vector3(sin(a) * 0.22, cos(a) * 0.22, 0), tick_col, Vector3(0, 0, -rad_to_deg(a)))
	Props.interactable(self, "clock", Vector3(0.3, 0.7, 0.7), Vector3(-w / 2 + 0.2, 2.2, 3.0))
	# Saatin altında pirinç ayar topuzu
	Props.cyl(self, 0.035, 0.06, Vector3(-w / 2 + 0.05, 1.72, 3.0), C_BRASS, Vector3(0, 0, 90), 10)
	_reg("bur_clockknob", Vector3(0.3, 0.25, 0.4), Vector3(-w / 2 + 0.15, 1.7, 3.0), "UI_BUR_SPIN", _of_clockknob_use)
	# Yaprak takvim (z 4.5: bölüm 17'nin panosuna ayrılan z 0.15..1.85 dışında)
	_of_cal = Node3D.new()
	_of_cal.position = Vector3(-w / 2 + 0.03, 1.75, 4.5)
	_of_cal.rotation_degrees.y = 90
	add_child(_of_cal)
	Props.box(_of_cal, Vector3(0.3, 0.42, 0.02), Vector3.ZERO, C_WOOD_DARK)
	Props.box(_of_cal, Vector3(0.26, 0.3, 0.035), Vector3(0, -0.03, 0.02), C_PAPER)
	Props.box(_of_cal, Vector3(0.26, 0.07, 0.03), Vector3(0, 0.17, 0.02), Color("a8242a"))
	_reg("bur_calendar", Vector3(0.3, 0.5, 0.4), Vector3(-w / 2 + 0.12, 1.75, 4.5), "UI_BUR_TAKE", _of_calendar_use)


func _of_clockknob_use() -> void:
	_of_ring_step += 1
	Audio.sfx("timer_tick", -8.0)
	if is_instance_valid(_of_ring):
		var tw := create_tween()
		tw.tween_property(_of_ring, "rotation_degrees:z", -30.0 * _of_ring_step, 0.25).set_trans(Tween.TRANS_BACK)
	_say(_next("bur_clockknob", ["BUR_CLOCKKNOB", "BUR_CLOCKKNOB_2"]))


func _of_calendar_use() -> void:
	_say(_next("bur_calendar", ["BUR_CALENDAR", "BUR_CALENDAR_2"]))
	Audio.sfx("paper_tear", -8.0)
	if _of_cal_busy or not is_instance_valid(_of_cal):
		return
	_of_cal_busy = true
	var leaf := Node3D.new()
	leaf.position = Vector3(0, -0.03, 0.045)
	_of_cal.add_child(leaf)
	Props.box(leaf, Vector3(0.26, 0.3, 0.004), Vector3.ZERO, C_PAPER)
	_lbl(leaf, "BUGÜN", "TODAY", Vector3(0, 0, 0.004), 36, Color("a8242a"), Vector3.ZERO, 0.22)
	var tw := leaf.create_tween()
	tw.tween_property(leaf, "position:y", -1.6, 1.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(leaf, "rotation_degrees:z", 35.0, 1.3)
	tw.parallel().tween_property(leaf, "position:z", 0.3, 1.3)
	tw.tween_property(leaf, "scale", Vector3(0.01, 0.01, 0.01), 0.3)
	tw.tween_callback(leaf.queue_free)
	tw.tween_callback(_of_calendar_done)


func _of_calendar_done() -> void:
	_of_cal_busy = false


## Portmanto (v0.99.100): kullanıcı "şapkayı astığı tahta şey çok kötü, şapka ceket havada duruyor". Palto direkten
## 5 cm açıkta asılıydı, şapka direğin tepesinde disk gibiydi. Şimdi: ağır ayaklık, tornalı direk, uçları pirinç toplu
## dört kanca; palto yakasından kancaya asılı (hafifçe direğe yaslanır), fötr kancanın ucuna geçmiş, atkı öbür kancada,
## şemsiye direğe yaslı. Yerel +z odanın ortasına bakar.
func _of_coat_rack() -> void:
	var r := Node3D.new()
	r.position = Vector3(2.45, 0.0, 0.45)
	r.rotation_degrees.y = -50.0
	add_child(r)
	var wd := C_WOOD_DARK
	# ayaklık: geniş disk + basamak, direk, ortada bilezik, tepede topuz
	Props.cyl(r, 0.2, 0.035, Vector3(0, 0.0175, 0), wd, Vector3.ZERO, 14)
	Props.cyl(r, 0.12, 0.05, Vector3(0, 0.06, 0), wd, Vector3.ZERO, 12)
	Props.cyl(r, 0.03, 1.66, Vector3(0, 0.915, 0), wd, Vector3.ZERO, 8)
	Props.cyl(r, 0.045, 0.04, Vector3(0, 1.05, 0), C_BRASS, Vector3.ZERO, 10)
	Props.cyl(r, 0.05, 0.06, Vector3(0, 1.64, 0), wd, Vector3.ZERO, 10)
	Props.ball(r, 0.05, Vector3(0, 1.78, 0), wd, Vector3.ONE, 10)
	# kancalar: 40 derece yukarı kalkık kol + pirinç uç
	var tips := {}
	for d in [Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, -1)]:
		var dir: Vector3 = d
		var mid := Vector3(0, 1.64, 0) + dir * (0.03 + 0.11 * cos(deg_to_rad(40.0))) + Vector3(0, 0.11 * sin(deg_to_rad(40.0)), 0)
		var rot := Vector3(50.0 * dir.z, 0, -50.0 * dir.x)
		Props.cyl(r, 0.012, 0.22, mid, wd, rot, 6)
		var tip := Vector3(0, 1.64, 0) + dir * (0.03 + 0.22 * cos(deg_to_rad(40.0))) + Vector3(0, 0.22 * sin(deg_to_rad(40.0)), 0)
		Props.ball(r, 0.018, tip, C_BRASS, Vector3.ONE, 8)
		tips[dir] = tip
	# palto (+z kancası, odaya bakar): yakasından asılı, eteği direğe doğru hafifçe yaslanır
	var coat := Node3D.new()
	coat.position = tips[Vector3(0, 0, 1)] + Vector3(0, -0.01, 0.016)
	coat.rotation_degrees.x = 6.0
	r.add_child(coat)
	var cc := Color("8c7a58")
	var cd := Color("6e5f44")
	# Askıdaki palto kutu gibi durmasın: yassılaştırılmış koni (yakada dar, etekte geniş), yanlarda sarkan kollar
	Props.ball(coat, 0.06, Vector3(0, -0.03, 0), cd, Vector3(1.2, 0.8, 0.9), 8)          # yakada toplanan kumaş
	var body := Props.cyl(coat, 0.21, 0.82, Vector3(0, -0.47, 0), cc, Vector3.ZERO, 12, 0.1)
	body.scale = Vector3(1.0, 1.0, 0.42)
	for sx: float in [-1.0, 1.0]:
		var sl := Props.cyl(coat, 0.05, 0.6, Vector3(sx * 0.15, -0.42, 0.01), cc, Vector3(0, 0, sx * 6.0), 8, 0.04)
		sl.scale = Vector3(1.0, 1.0, 0.9)
		Props.cyl(coat, 0.052, 0.05, Vector3(sx * 0.18, -0.72, 0.01), cd, Vector3(0, 0, sx * 6.0), 8)     # kol ağzı
		Props.box(coat, Vector3(0.04, 0.26, 0.006), Vector3(sx * 0.035, -0.2, 0.05), cd, Vector3(0, 0, sx * 12.0))   # devrik yaka
	# düğmeler (koni yüzeyine oturur: aşağı indikçe palto genişler, yüzey öne gelir)
	for by: float in [-0.36, -0.5, -0.64]:
		Props.ball(coat, 0.011, Vector3(0.0, by, (0.1 + 0.11 * (-0.06 - by) / 0.82) * 0.42 + 0.002), Color("2e2620"), Vector3(1, 1, 0.5), 6)
	# fötr (+x kancası): kancanın ucu tepeliğin içinde, şapka dışa doğru yatık
	var hat := Node3D.new()
	hat.position = tips[Vector3(1, 0, 0)]
	hat.rotation_degrees.z = -18.0
	r.add_child(hat)
	var hc := Color("2e2a28")
	Props.cyl(hat, 0.08, 0.1, Vector3(0.0, -0.028, 0), hc, Vector3.ZERO, 10, 0.07)
	Props.cyl(hat, 0.082, 0.022, Vector3(0.0, -0.064, 0), Color("6a2a24"), Vector3.ZERO, 10)
	Props.cyl(hat, 0.13, 0.012, Vector3(0.0, -0.079, 0), hc, Vector3.ZERO, 14)
	# atkı (-x kancası): kancanın üstünden iki yana sarkar, hardal çizgili
	var sc := Vector3(tips[Vector3(-1, 0, 0)])
	Props.box(r, Vector3(0.085, 0.03, 0.07), sc + Vector3(0, 0.022, 0), Color("8a2a2a"))
	for sz: float in [-1.0, 1.0]:
		Props.box(r, Vector3(0.085, 0.5, 0.014), sc + Vector3(0, -0.23, sz * 0.03), Color("8a2a2a"))
		for sy: float in [-0.3, -0.36]:
			Props.box(r, Vector3(0.087, 0.022, 0.016), sc + Vector3(0, sy, sz * 0.03), Color("d4a640"))
		for fx: float in [-0.03, 0.0, 0.03]:
			Props.box(r, Vector3(0.008, 0.05, 0.008), sc + Vector3(fx, -0.505, sz * 0.03), Color("8a2a2a"))
	# şemsiye (+x yanı, odadan görünür): ucu yerde, sapı direğe yaslı
	var u := Node3D.new()
	u.position = Vector3(0.27, 0.0, -0.02)
	u.rotation_degrees.z = 14.1
	r.add_child(u)
	Props.cyl(u, 0.005, 0.06, Vector3(0, 0.03, 0), C_METAL, Vector3.ZERO, 6)
	Props.cyl(u, 0.012, 0.55, Vector3(0, 0.335, 0), Color("2a3446"), Vector3.ZERO, 8, 0.04)
	Props.cyl(u, 0.04, 0.06, Vector3(0, 0.64, 0), Color("2a3446"), Vector3.ZERO, 8, 0.015)
	Props.cyl(u, 0.032, 0.02, Vector3(0, 0.42, 0), Color("3a4a64"), Vector3.ZERO, 8)
	Props.cyl(u, 0.008, 0.14, Vector3(0, 0.74, 0), C_METAL, Vector3.ZERO, 6)
	Props.cyl(u, 0.016, 0.1, Vector3(0, 0.85, 0), C_WOOD, Vector3.ZERO, 8)
	Props.ball(u, 0.02, Vector3(0, 0.9, 0), C_WOOD, Vector3.ONE, 8)


## Portmanto (kapının doğusunda) ve çağlar küresi
func _of_corner_props() -> void:
	_of_coat_rack()
	# Çağlar küresi: ayaklık, direk, bakır meridyen, dönen küre + kıtalar
	Props.cyl(self, 0.16, 0.03, Vector3(2.3, 0.015, 1.5), C_WOOD_DARK, Vector3.ZERO, 8)
	Props.cyl(self, 0.025, 0.8, Vector3(2.3, 0.45, 1.5), C_WOOD, Vector3.ZERO, 6)
	Props.ring(self, 0.27, 0.285, Vector3(2.3, 1.1, 1.5), Color("b8743a"), Vector3(90, 90, 0))
	_of_globe = Node3D.new()
	_of_globe.position = Vector3(2.3, 1.1, 1.5)
	add_child(_of_globe)
	Props.ball(_of_globe, 0.25, Vector3.ZERO, Color("3a6a98"), Vector3.ONE, 14)
	Props.ball(_of_globe, 0.09, Vector3(0.1, 0.13, 0.2), Color("7a8a4a"), Vector3(1, 0.8, 0.5), 8)
	Props.ball(_of_globe, 0.09, Vector3(-0.2, -0.05, 0.12), Color("7a8a4a"), Vector3(0.6, 1, 0.8), 8)
	Props.ball(_of_globe, 0.09, Vector3(-0.05, 0.1, -0.22), Color("7a8a4a"), Vector3(1, 0.8, 0.5), 8)
	_reg("bur_globe", Vector3(0.6, 0.8, 0.6), Vector3(2.3, 1.15, 1.5), "UI_BUR_SPIN", _of_globe_use)


func _of_globe_use() -> void:
	if _of_globe_busy or not is_instance_valid(_of_globe):
		return
	_of_globe_busy = true
	if is_instance_valid(_of_globe_lbl):
		_of_globe_lbl.queue_free()
		_of_globe_lbl = null
	Audio.sfx("machine_spin", -18.0)
	var pick: int = randi() % _OF_ERAS.size()
	var tw := create_tween()
	tw.tween_property(_of_globe, "rotation:y", _of_globe.rotation.y + TAU * 3.0 + randf() * TAU, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_of_globe_stop.bind(pick))


func _of_globe_stop(pick: int) -> void:
	var era: Array = _OF_ERAS[pick]
	_of_globe_lbl = _lbl(self, era[0], era[1], Vector3(2.3, 1.55, 1.5), 30, Color("ffe9b0"), Vector3(0, -90, 0), 0.6)
	if pick == _OF_ERAS.size() - 1:
		_say("BUR_GLOBE_2")
	else:
		_say(_next("bur_globe", ["BUR_GLOBE", "BUR_GLOBE_3"]))
	_of_globe_busy = false


func _typewriter(pos: Vector3, rot: float) -> Node3D:
	var t := Node3D.new()
	t.position = pos
	t.rotation_degrees.y = rot
	add_child(t)
	Props.box(t, Vector3(0.42, 0.1, 0.34), Vector3(0, 0.05, 0), Color("1f2426"))
	Props.box(t, Vector3(0.4, 0.06, 0.12), Vector3(0, 0.12, -0.08), Color("2b3134"), Vector3(-15, 0, 0))
	Props.cyl(t, 0.035, 0.46, Vector3(0, 0.16, -0.15), Color("15191a"), Vector3(0, 0, 90), 8)
	Props.box(t, Vector3(0.28, 0.2, 0.005), Vector3(0, 0.26, -0.16), C_PAPER, Vector3(-10, 0, 0))
	for r in 3:
		for c in 7:
			Props.box(t, Vector3(0.025, 0.012, 0.025), Vector3(-0.13 + c * 0.043, 0.105 + r * 0.012, 0.06 + r * 0.035 - 0.06), Color("d8d2c0"))
	return t


# ---------------------------------------------------------------- koridor

func _build_corridor() -> void:
	var z1 := -COR_LEN
	var mid := z1 / 2.0
	# Zemin: sıcak linolyum; ortada oksit kırmızısı kilim şeridi, altın kenarlı (düz siyah-beyaz dama yerine)
	_floor(Vector2(COR_W, COR_LEN), Vector3(0, 0, mid), Color("c8b88a"), Color("a08a62"), 1.0)
	Props.box(self, Vector3(1.4, 0.012, COR_LEN - 0.4), Vector3(0, 0.006, mid), C_RUG)
	for sx in [-0.72, 0.72]:
		Props.box(self, Vector3(0.06, 0.014, COR_LEN - 0.4), Vector3(sx, 0.007, mid), C_RUG_EDGE)
	Props.solid(self, Vector3(COR_W, 0.2, COR_LEN), Vector3(0, COR_H + 0.1, mid), C_CEIL)
	# Duvarlar yalnız odaların açıklıkları dışında; açıklıkların üstünde lento (kapı ağzı)
	for side in [-1, 1]:
		var opens: Array = OPEN_W if side < 0 else OPEN_E
		# Kapılar gerçek açıklık: ardında çağın girintisi var (eskiden duvara yapışık parlak bir levhaydı)
		var gaps: Array = opens.duplicate()
		for d in DOORS:
			if int(d[0]) == side:
				gaps.append([float(d[1]) + 0.52, float(d[1]) - 0.52])
				_wall(Vector3(0.2, COR_H - 2.34, 1.04), Vector3(side * (COR_W / 2 + 0.1), 2.34 + (COR_H - 2.34) / 2.0, float(d[1])), C_COR_WALL)
		gaps.sort_custom(func(a, b): return float(a[0]) > float(b[0]))
		for seg in _solid_ranges(0.0, z1, gaps):
			_cor_wall(side, seg[0], seg[1])
		for o in opens:
			var za: float = o[0]
			var zb: float = o[1]
			if (side < 0 and absf(za - (LIFT_Z + 1.0)) < 0.01) or (side > 0 and absf(za - -36.5) < 0.01):
				continue       # asansörün kendi kasası, atriumun sütunları var
			Props.box(self, Vector3(0.2, 0.55, za - zb), Vector3(side * (COR_W / 2 + 0.1), COR_H - 0.275, (za + zb) / 2.0), C_COR_WALL)
			Props.box(self, Vector3(0.24, 0.08, za - zb + 0.2), Vector3(side * (COR_W / 2 + 0.08), COR_H - 0.58, (za + zb) / 2.0), C_WOOD_DARK)
			for zz in [za, zb]:
				Props.box(self, Vector3(0.24, COR_H - 0.55, 0.1), Vector3(side * (COR_W / 2 + 0.08), (COR_H - 0.55) / 2.0, zz), C_WOOD_DARK)
	_wall(Vector3(COR_W, COR_H, 0.2), Vector3(0, COR_H / 2, z1 - 0.1), C_COR_WALL)
	# Tavan floresanları: her yedincisi bozuk (titrer); dört tavan ışığı
	var z := -3.0
	var n := 0
	while z > z1:
		_tube(Vector3(0, COR_H - 0.05, z), n % 7 != 5)
		z -= 5.0
		n += 1
	for lz in [-6.0, -20.0, -30.0, -60.0]:
		_bulb(Vector3(0, COR_H - 0.4, lz), Color("e6f0d8"), 1.0, 11.0)
	# Kapılar: her birinde bir yıl, kanat aralık, ardından çağının ışığı sızar
	for d in DOORS:
		_door(int(d[0]), float(d[1]), String(d[2]))
	# 1453 kapılarının önünde gerçek, titrek turuncu ışık (kuşatma ateşi)
	var fire := _bulb(Vector3(1.2, 1.4, -67.5), Color("ff7a30"), 0.9, 7.0)
	var ft := fire.create_tween().set_loops()
	ft.tween_property(fire, "light_energy", 1.3, 0.35).set_trans(Tween.TRANS_SINE)
	ft.tween_property(fire, "light_energy", 0.7, 0.5).set_trans(Tween.TRANS_SINE)


## [za, zb] aralığında açıklıklar (azalan sırada) dışında kalan dolu duvar parçaları
func _solid_ranges(za: float, zb: float, opens: Array) -> Array:
	var out: Array = []
	var cur := za
	for o in opens:
		if float(o[0]) < cur - 0.01:
			out.append([cur, float(o[0])])
		cur = minf(cur, float(o[1]))
	if cur > zb + 0.01:
		out.append([cur, zb])
	return out


## Koridor duvarı parçası: krem üst, 1,1 m petrol yeşili lambri, pirinç bant, ceviz süpürgelik
func _cor_wall(side: int, za: float, zb: float) -> void:
	var length := za - zb
	var zc := (za + zb) / 2.0
	Props.set_pattern(Props.solid(self, Vector3(0.2, COR_H, length), Vector3(side * (COR_W / 2 + 0.1), COR_H / 2, zc), C_COR_WALL), C_COR_WALL, "wall")
	var xi := side * (COR_W / 2 - 0.015)
	Props.box(self, Vector3(0.03, 1.1, length), Vector3(xi, 0.55, zc), C_COR_LOW)
	Props.box(self, Vector3(0.04, 0.05, length), Vector3(xi, 1.12, zc), C_BRASS)
	Props.box(self, Vector3(0.05, 0.12, length), Vector3(xi, 0.06, zc), C_WOOD_DARK)


## Kapı yılı → zaman penceresinin odaklandığı çağ (0 Mısır 1 Roma 2 Konstantiniyye 3 1453 4 kalyon 5 1970'ler 6 modern 7 roket)
const DOOR_ERA := {"MÖ 2560": 0, "MÖ 776": 1, "MÖ 44": 1, "1215": 2, "1347": 2, "1453": 3, "1455": 3, "1492": 4,
	"1517": 4, "1687": 4, "1769": 4, "1789": 4, "1815": 4, "1903": 5, "1914": 5, "1945": 5, "1969": 7, "1989": 6,
	"2026": 6, "2150": 7}


func _door(side: int, z: float, year: String) -> void:
	var x := side * (COR_W / 2 - 0.02)
	var col: Color = ERA_COLORS.get(year, Color("e8d8b0"))
	var rot := Vector3(0, -90 * side, 0)
	# Kasa (ceviz)
	Props.box(self, Vector3(0.06, 2.3, 0.08), Vector3(x, 1.15, z - 0.54), C_WALNUT)
	Props.box(self, Vector3(0.06, 2.3, 0.08), Vector3(x, 1.15, z + 0.54), C_WALNUT)
	Props.box(self, Vector3(0.06, 0.08, 1.16), Vector3(x, 2.3, z), C_WALNUT)
	_door_alcove(side, z, year, col)
	# Kanat: menteşe z+0,5'te, 45° koridora açık (aralıktan içerideki minyatür sahne görünür; 30°'de bir şerit kalıyordu)
	var hinge := Node3D.new()
	hinge.position = Vector3(x - side * 0.03, 0.0, z + 0.5)
	hinge.rotation_degrees.y = side * 45.0
	add_child(hinge)
	Props.box(hinge, Vector3(0.05, 2.2, 1.0), Vector3(0, 1.1, -0.5), Color("5f4630"))
	Props.box(hinge, Vector3(0.055, 0.5, 0.6), Vector3(0, 1.7, -0.5), col.lerp(Color("dfe8e0"), 0.55), Vector3.ZERO, 0.45)
	Props.ball(hinge, 0.04, Vector3(-side * 0.04, 1.05, -0.85), C_BRASS, Vector3.ONE, 6)
	Props.label(hinge, year, Vector3(-side * 0.035, 1.7, -0.5), 48, Color("2a2a2a"), rot, 0.5)
	# Aralıktan sızan ışık: zeminde yelpaze
	_glow(self, Vector3(x - side * 0.45, 0.02, z - 0.3), Vector2(1.3, 1.1), col, Vector3(-90, 0, 0), 0.55)
	Props.interactable(self, "door:" + year, Vector3(0.4, 2.0, 1.0), Vector3(x - side * 0.2, 1.1, z))
	_handlers["door:" + year] = _door_talk.bind(year)
	_prompts["door:" + year] = "UI_BUR_LOOK"
	_nihat_only["door:" + year] = true


## Kapının ardındaki girinti: 0,8 m derin; dipte o çağa odaklı zaman penceresi, çağın zemini, ışığı ve bir iki eşyası
func _door_alcove(side: int, z: float, year: String, col: Color) -> void:
	var x0 := side * (COR_W / 2 + 0.2)          # koridor duvarının dış yüzü
	var x1 := side * (COR_W / 2 + 1.0)          # girintinin dibi
	var xm := (x0 + x1) / 2.0
	var floor_col := col.darkened(0.55)
	Props.box(self, Vector3(1.0, 0.02, 1.04), Vector3(xm, 0.01, z), floor_col)
	Props.box(self, Vector3(1.0, 0.04, 1.04), Vector3(xm, 2.36, z), col.darkened(0.7))
	for sz: float in [-1.0, 1.0]:
		Props.box(self, Vector3(1.0, 2.36, 0.04), Vector3(xm, 1.18, z + sz * 0.54), col.darkened(0.6))
	var m := _rc_window_quad(self, Vector2(1.04, 2.34), Vector3(x1 - side * 0.01, 1.17, z), Vector3(0, -90 * side, 0), 0.9)
	if m:
		m.set_shader_parameter("focus_era", int(DOOR_ERA.get(year, 2)))
		m.set_shader_parameter("era_focus", 1.0)
		m.set_shader_parameter("sky_horizon", col)
	_glow(self, Vector3(xm, 0.03, z), Vector2(1.0, 1.0), col, Vector3(-90, 0, 0), 0.6)
	# Kapı aralığından görünen minyatür sahne: ceviz kaide üstünde o yılın olayı, döngüyle oynar (v0.99.101)
	var kx := x0 + side * 0.42
	Props.box(self, Vector3(0.56, 0.72, 0.92), Vector3(kx, 0.36, z), C_WALNUT)
	Props.box(self, Vector3(0.58, 0.03, 0.94), Vector3(kx, 0.725, z), C_BRASS)
	var stage := Node3D.new()
	stage.position = Vector3(kx, 0.74, z)
	stage.rotation_degrees.y = -90.0 * side
	add_child(stage)
	DoorScenes.build(year, stage)
	_glow(self, Vector3(x1 - side * 0.04, 1.35, z), Vector2(0.9, 0.7), col.lerp(Color.WHITE, 0.5), Vector3(0, -90 * side, 0), 0.35)


## Nihat kapıyı inceler: her yılın kendi lafları, sırayla (aynı laf art arda gelmez)
func _door_talk(year: String) -> void:
	var yk := year.replace("MÖ ", "MO")
	var keys: Array = []
	var old := "D3_N_DOOR_" + yk
	if tr(old) != old:
		keys.append(old)
	for i in range(1, 5):
		var k := "BUR_DOOR_%s_%d" % [yk, i]
		if tr(k) != k:
			keys.append(k)
	if keys.is_empty():
		keys.append("D3_N_DOOR")
	Audio.sfx("wood_creak", -12.0)
	_say(_next("door:" + year, keys), 4.5)


# ---------------------------------------------------------------- kostüm deposu

func _build_depot() -> void:
	var x0 := COR_W / 2
	var x1 := x0 + 4.4
	var zc := (DEPOT_Z0 + DEPOT_Z1) / 2.0
	var dz := DEPOT_Z0 - DEPOT_Z1
	_floor(Vector2(x1 - x0, dz), Vector3((x0 + x1) / 2, 0, zc), Color("8a7a5a"), Color("7a6a4a"), 1.2)
	Props.solid(self, Vector3(x1 - x0, 0.2, dz), Vector3((x0 + x1) / 2, COR_H + 0.1, zc), Color("b8b6a4"))
	_wall(Vector3(x1 - x0, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, DEPOT_Z0 + 0.1))
	_wall(Vector3(x1 - x0, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, DEPOT_Z1 - 0.1))
	_wall(Vector3(0.2, COR_H, dz), Vector3(x1 + 0.1, COR_H / 2, zc))
	Props.box(self, Vector3(0.04, 0.48, 3.2), Vector3(x0 - 0.03, 3.12, zc), C_TEAL)
	Props.box(self, Vector3(0.03, 0.52, 3.26), Vector3(x0 - 0.015, 3.12, zc), C_BRASS)
	Props.label(self, "KOSTÜM DEPOSU", Vector3(x0 - 0.06, 3.19, zc), 34, Color("f2e6c9"), Vector3(0, -90, 0), 3.0)
	Props.label(self, "Her dönem · Her beden · İade yok", Vector3(x0 - 0.06, 2.99, zc), 16, Color("e8d8a8"), Vector3(0, -90, 0), 3.0)
	_tube(Vector3((x0 + x1) / 2, COR_H - 0.05, zc))
	var l := OmniLight3D.new()
	l.position = Vector3((x0 + x1) / 2, COR_H - 0.5, zc)
	l.light_color = Color("fff0d0")
	l.light_energy = 1.3
	l.omni_range = 6.0
	add_child(l)
	# Tezgâh
	Props.set_pattern(Props.solid(self, Vector3(0.6, 1.05, dz - 1.2), Vector3(x0 + 1.4, 0.525, zc), C_WOOD), C_WOOD, "wood")
	Props.box(self, Vector3(0.7, 0.05, dz - 1.1), Vector3(x0 + 1.4, 1.07, zc), C_WOOD_DARK)
	# Zil ve damga
	Props.cyl(self, 0.06, 0.05, Vector3(x0 + 1.3, 1.12, zc + 1.5), C_BRASS, Vector3.ZERO, 10, 0.02)
	Props.box(self, Vector3(0.08, 0.08, 0.08), Vector3(x0 + 1.4, 1.14, zc - 1.2), Color("3a2a20"))
	# Fötr şapka (Nihat'a verilecek)
	fedora_node = Node3D.new()
	fedora_node.position = Vector3(x0 + 1.3, 1.1, zc)
	add_child(fedora_node)
	Props.cyl(fedora_node, 0.2, 0.02, Vector3(0, 0.01, 0), Color("4a4038"), Vector3.ZERO, 10)
	Props.cyl(fedora_node, 0.12, 0.12, Vector3(0, 0.08, 0), Color("4a4038"), Vector3.ZERO, 8, 0.1)
	Props.cyl(fedora_node, 0.125, 0.03, Vector3(0, 0.035, 0), Color("1f1b18"), Vector3.ZERO, 8)
	fedora_node.visible = false
	# Askılı kostüm rafları: her dönemden
	var coats := [Color("b3262d"), Color("2f5fa8"), Color("e8d9a8"), Color("3a6b3a"), Color("6a3a7a"),
		Color("d8d8d0"), Color("1f2a44"), Color("c98a3a"), Color("8a2b22"), Color("4a4038")]
	for r in 2:
		var rx := x1 - 0.5 - r * 1.3
		Props.cyl(self, 0.025, dz - 1.0, Vector3(rx, 1.9, zc), C_METAL, Vector3(90, 0, 0), 6)
		for k in 9:
			var cz := DEPOT_Z1 + 0.9 + k * (dz - 1.8) / 8.0
			var c: Color = coats[(k + r * 3) % coats.size()]
			Props.box(self, Vector3(0.12, 0.95, 0.42), Vector3(rx, 1.4, cz), c, Vector3(0, 0, 3 - k % 3 * 3))
	# Rafta tarihî başlıklar: Roma miğferi, pudralı peruk, astronot kaskı, bir de fes
	var shelf_x := x1 - 0.25
	Props.box(self, Vector3(0.45, 0.04, dz - 1.0), Vector3(shelf_x, 2.45, zc), C_WOOD_DARK)
	var hz := DEPOT_Z1 + 1.0
	Props.ball(self, 0.15, Vector3(shelf_x, 2.6, hz), Color("c9a24a"), Vector3(1, 0.9, 1.1), 8)
	Props.box(self, Vector3(0.04, 0.12, 0.3), Vector3(shelf_x, 2.78, hz), Color("b3262d"))
	for k in 5:
		Props.ball(self, 0.07, Vector3(shelf_x, 2.55 + (k % 2) * 0.1, hz + 1.2 + (k - 2) * 0.09), Color("f4f1ea"), Vector3.ONE, 6)
	Props.ball(self, 0.17, Vector3(shelf_x, 2.64, hz + 2.4), Color("f0f0f0"), Vector3.ONE, 10)
	Props.box(self, Vector3(0.02, 0.12, 0.2), Vector3(shelf_x - 0.16, 2.64, hz + 2.4), Color("d4a020"), Vector3.ZERO, 0.6)
	Props.cyl(self, 0.1, 0.14, Vector3(shelf_x, 2.54, hz + 3.6), Color("b3262d"), Vector3.ZERO, 8, 0.08)
	# Alan tezgâha doğru uzanır: raf tezgâhın ardında, E ışını (2,4 m) tezgâhın önünden fese yetişmiyordu
	Props.interactable(self, "fezshelf", Vector3(1.4, 0.6, 0.7), Vector3(shelf_x - 0.6, 2.55, hz + 3.6))
	# Depo memuru Asır
	riza = Person.new({"coat": Color("7a6a4a"), "pants": Color("3a3228"), "hair": Color("2a2a2a"), "mustache": true, "glasses": true})
	riza.set_meta("spk", "SPK_RIZA")
	riza.position = RIZA_POS
	riza.rotation_degrees.y = -90
	add_child(riza)
	Props.interactable(self, "riza", Vector3(1.4, 1.8, 2.0), Vector3(x0 + 1.0, 1.0, zc))


# ---------------------------------------------------------------- Başdenetçi'nin masası

var _desk_root: Node3D


## Başdenetçilik: koridorun doğusunda kendi odası (masası koridorun tam ortasındaydı)
func _build_desk_room() -> void:
	var wc := Color("d8caa0")
	_floor(Vector2(4.4, 3.9), Vector3(4.2, 0, -26.75), Color("7a5a3a"), Color("6a4c30"), 1.2)
	Props.solid(self, Vector3(4.6, 0.2, 4.3), Vector3(4.3, COR_H + 0.1, -26.75), C_CEIL)
	_wall(Vector3(4.6, COR_H, 0.2), Vector3(4.3, COR_H / 2, -28.9), wc)
	_wall(Vector3(0.2, COR_H, 4.4), Vector3(6.5, COR_H / 2, -26.75), wc)
	_of_wain(Vector3(4.3, 0.5, -28.78), Vector3(4.36, 1.0, 0.04))
	_of_wain(Vector3(6.38, 0.5, -26.75), Vector3(0.04, 1.0, 4.1))
	_of_wain(Vector3(4.3, 0.5, -24.62), Vector3(4.36, 1.0, 0.04))
	# Teşkilat şeması: bütün oklar tek bir soru işaretine çıkar
	Props.box(self, Vector3(0.04, 1.1, 1.6), Vector3(6.37, 1.9, -25.6), C_WALNUT)
	Props.box(self, Vector3(0.03, 1.0, 1.5), Vector3(6.35, 1.9, -25.6), C_PAPER)
	_lbl(self, "TEŞKİLAT ŞEMASI", "ORGANISATION CHART", Vector3(6.33, 2.32, -25.6), 18, Color("2a2a2a"), Vector3(0, -90, 0), 1.4)
	for k in 6:
		var bx := Vector3(6.33, 1.5 + (k / 3) * 0.32, -26.1 + (k % 3) * 0.5)
		Props.box(self, Vector3(0.01, 0.16, 0.3), bx, Color("c9d8e8"))
		Props.box(self, Vector3(0.01, 0.6 - (k / 3) * 0.3, 0.012), bx + Vector3(0, 0.25, 0), Color("3a3a3a"))
	_lbl(self, "?", "?", Vector3(6.32, 2.12, -25.6), 40, Color("a8242a"), Vector3(0, -90, 0))
	# Dosya dolabı ve ficus
	Props.set_pattern(Props.solid(self, Vector3(0.6, 1.4, 0.6), Vector3(6.05, 0.7, -28.35), Color("6f7a70")), Color("6f7a70"), "wall")
	Props.cyl(self, 0.18, 0.35, Vector3(2.6, 0.17, -28.4), Color("8a5a3a"), Vector3.ZERO, 8, 0.22)
	Props.ball(self, 0.3, Vector3(2.6, 0.75, -28.4), Color("3a6a34"), Vector3(1, 1.3, 1), 8)


func _build_desk() -> void:
	_build_desk_room()
	# Masa düzeni yerel çerçevede kurulur: +z koridora (ziyaretçiye) bakar, Başdenetçi -z'de oturur
	_desk_root = Node3D.new()
	_desk_root.position = Vector3(DESK_X, 0.0, DESK_Z)
	_desk_root.rotation_degrees.y = -90.0
	add_child(_desk_root)
	var dr := _desk_root
	var z := 0.0
	Props.set_pattern(Props.solid(dr, Vector3(2.4, 0.08, 1.1), Vector3(0, 0.8, z), C_WOOD), C_WOOD, "wood")
	Props.set_pattern(Props.solid(dr, Vector3(2.3, 0.76, 0.1), Vector3(0, 0.38, z + 0.5), C_WOOD_DARK), C_WOOD_DARK, "wood")
	# Kâğıt dağları: tavana kadar
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for k in 10:
		var px := -1.0 + (k % 5) * 0.5
		var pz := z - 0.25 + (k / 5) * 0.4
		# Ortada alçak (Başdenetçi görünsün), kenarlarda tavana kadar
		var hgt := rng.randf_range(0.15, 0.3) if absf(px) < 0.3 else rng.randf_range(1.1, 1.9)     # tepe 2.74: 'SIRA' tabelasının altında kalır
		var layer_cols := [C_PAPER, Color("c9a45a"), Color("e8e0c8"), Color("b89a5a"), Color("efe4c4")]
		var yy := 0.84
		var li := k
		while yy < 0.84 + hgt - 0.05:
			var lh := minf(rng.randf_range(0.18, 0.42), 0.84 + hgt - yy)
			Props.box(dr, Vector3(0.34 + rng.randf_range(-0.03, 0.03), lh, 0.26 + rng.randf_range(-0.02, 0.02)), Vector3(px + rng.randf_range(-0.025, 0.025), yy + lh / 2, pz), layer_cols[li % layer_cols.size()], Vector3(0, rng.randf_range(-9, 9), 0))
			yy += lh
			li += 1
		if hgt > 1.0:
			Props.box(dr, Vector3(0.05, 0.012, 0.28), Vector3(px, 0.84 + hgt * 0.62, pz), Color("b8323a"))     # kırmızı bant
	Props.box(dr, Vector3(0.3, 0.02, 0.22), Vector3(0.9, 0.85, z + 0.25), Color("b8323a"))
	# İsim levhası masanın önünde, koyu zeminde (masa üstü kenarına ve kâğıt yığınlarına biniyordu, okunmuyordu)
	Props.box(dr, Vector3(1.1, 0.3, 0.02), Vector3(0, 0.6, z + 0.565), Color("2a3a2e"))
	Props.box(dr, Vector3(1.16, 0.02, 0.025), Vector3(0, 0.76, z + 0.565), C_BRASS)
	Props.label(dr, "BAŞDENETÇİ", Vector3(0, 0.66, z + 0.58), 26, Color("f2e6c9"), Vector3.ZERO, 1.0)
	Props.label(dr, "M. ZAMANOVA", Vector3(0, 0.54, z + 0.58), 20, Color("d8c890"), Vector3.ZERO, 0.8)
	# Tepede 'SIRA NUMARANIZ' tabelası
	Props.box(dr, Vector3(1.0, 0.35, 0.05), Vector3(0, 3.0, z + 0.2), Color("1a1f1a"))
	for cx: float in [-0.4, 0.4]:
		Props.cyl(dr, 0.008, 0.25, Vector3(cx, 3.29, z + 0.2), C_METAL, Vector3.ZERO, 4)
	Props.label(dr, "SIRA: 1453", Vector3(0, 3.0, z + 0.23), 40, Color("ff5a4a"), Vector3.ZERO, 0.9)
	var l := OmniLight3D.new()
	l.position = Vector3(0, 2.5, z + 1.2)
	l.light_color = Color("fff4d8")
	l.light_energy = 1.2
	l.omni_range = 5.0
	dr.add_child(l)
	mufide = Person.new({"coat": Color("6b3a4a"), "pants": Color("3a2a30"), "hair": Color("9a9a9a"), "hat": "bun", "glasses": true, "skirt": true, "skin": Color("e8b894")})
	mufide.set_meta("spk", "SPK_MUFIDE")
	mufide.position = MUFIDE_POS
	mufide.rotation_degrees.y = -90.0
	add_child(mufide)
	Props.interactable(dr, "mufide", Vector3(2.4, 2.0, 1.6), Vector3(0, 1.0, z + 0.2))


# ---------------------------------------------------------------- saha asansörü

func _build_lift() -> void:
	var z := LIFT_Z
	var x0 := -COR_W / 2
	var x1 := x0 - 1.6
	Props.solid(self, Vector3(1.6, 0.2, 2.0), Vector3((x0 + x1) / 2, -0.1, z), C_METAL)
	Props.solid(self, Vector3(1.6, 0.2, 2.0), Vector3((x0 + x1) / 2, COR_H + 0.1, z), C_METAL)
	_wall(Vector3(1.6, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, z + 1.1), Color("6f7a70"))
	_wall(Vector3(1.6, COR_H, 0.2), Vector3((x0 + x1) / 2, COR_H / 2, z - 1.1), Color("6f7a70"))
	_wall(Vector3(0.2, COR_H, 2.0), Vector3(x1 - 0.1, COR_H / 2, z), Color("6f7a70"))
	Props.box(self, Vector3(0.1, 0.5, 2.2), Vector3(x0, COR_H - 0.25, z), C_BRASS)
	Props.label(self, "SAHA ÇIKIŞI", Vector3(x0 + 0.06, COR_H - 0.25, z), 40, Color("1a1a1a"), Vector3(0, 90, 0), 1.9)
	# Kayan kapı (açılır)
	lift_door = Node3D.new()
	lift_door.position = Vector3(x0 - 0.05, 0, z)
	add_child(lift_door)
	Props.box(lift_door, Vector3(0.06, 2.6, 0.95), Vector3(0, 1.3, -0.48), C_BRASS)
	Props.box(lift_door, Vector3(0.06, 2.6, 0.95), Vector3(0, 1.3, 0.48), C_BRASS)
	# Kat göstergesi: yıllar dönüyor (Nihat'ın kadranı); kabinin içinde de bir tane, kapının üstünde
	lift_dial = Props.label(self, "◀ 1453 ▶", Vector3(x0 + 0.06, COR_H - 0.7, z), 28, Color("ffb020"), Vector3(0, 90, 0), 0.8)
	lift_dial_in = Props.label(self, "◀ 1453 ▶", Vector3(x0 - 0.12, 2.76, z), 22, Color("ffb020"), Vector3(0, -90, 0), 0.8)
	var l := OmniLight3D.new()
	l.position = Vector3((x0 + x1) / 2, 2.6, z)
	l.light_color = Color("ffd89a")
	l.light_energy = 1.0
	l.omni_range = 4.0
	add_child(l)
	lift_light = l
	Props.interactable(self, "lift", Vector3(0.6, 2.4, 2.0), Vector3(x0 + 0.2, 1.2, z))
	# Tarih paneli: asansörün sağında pirinç kutu; çark yılı kurar, kırmızı topuzlu kol gönderir
	var pz := PANEL_POS.z
	Props.box(self, Vector3(0.08, 0.66, 0.48), Vector3(x0 + 0.04, 1.35, pz), C_BRASS)
	Props.box(self, Vector3(0.02, 0.13, 0.38), Vector3(x0 + 0.09, 1.58, pz), Color("15181a"))
	Props.label(self, "TARİH", Vector3(x0 + 0.105, 1.58, pz), 16, Color("ffb020"), Vector3(0, 90, 0), 0.34)
	panel_wheel = Node3D.new()
	panel_wheel.position = Vector3(x0 + 0.11, 1.3, pz - 0.06)
	add_child(panel_wheel)
	Props.cyl(panel_wheel, 0.12, 0.03, Vector3.ZERO, C_BRASS.darkened(0.25), Vector3(0, 0, 90), 12)
	Props.box(panel_wheel, Vector3(0.012, 0.22, 0.03), Vector3(0.018, 0, 0), Color("3a2a1a"))
	Props.box(panel_wheel, Vector3(0.012, 0.03, 0.22), Vector3(0.018, 0, 0), Color("3a2a1a"))
	Props.ball(panel_wheel, 0.024, Vector3(0.035, 0.1, 0.0), Color("e8d8b0"), Vector3.ONE, 6)
	Props.box(self, Vector3(0.035, 0.2, 0.035), Vector3(x0 + 0.11, 1.12, pz + 0.16), Color("5a4630"), Vector3(0, 0, -18))
	Props.ball(self, 0.035, Vector3(x0 + 0.14, 1.21, pz + 0.16), Color("a8262f"), Vector3.ONE, 6)


func open_lift() -> void:
	Audio.sfx("door_metal", -8.0)
	lift_open = true
	var tw := create_tween().set_parallel()
	tw.tween_property(lift_door.get_child(0), "position:z", -1.3, 0.8)
	tw.tween_property(lift_door.get_child(1), "position:z", 1.3, 0.8)
	await tw.finished


# ---------------------------------------------------------------- asansörle gönderiş (v0.99.6)
## Nihat Tolga'yı (Bölüm 3'te kendini) geçmişe gönderirken sahne: asansörün önü, Nihat panelde, kapı açılır, yolcu
## kabine yürür, kadran yılları çevirip durur, kapı kapanır, kabin camgöbeği yanar ve sarsılır, girdap. Bitince ekran
## beyazdır. Parçalar ayrı da çağrılır (Bölüm 17'nin kalibrasyon atlaması arada arızalanır: EdirneInterlude).

## Biniş: cut ise kesmeyle asansörün önü (Nihat panelin yanında); line_key Nihat'ın sözü; yolcu kabine yürür
## (hedef işaretli; otomatik testte ve çekimde konur), donar ve kapıya döner.
func lift_board(pl: Player, h: Hud, nihat: Person = null, line_key := "", cut := true) -> void:
	if cut:
		await h.fade_to(1.0, 0.4)
		pl.frozen = true
		pl.global_position = to_global(LIFT_FRONT) + Vector3(0, 0.05, 0)
		pl.face(to_global(Vector3(-2.0, 1.5, LIFT_Z)))
		if nihat:
			nihat.position = NIHAT_PANEL_POS
			nihat.face_toward(pl.global_position)
			nihat.look_target = pl
		await h.fade_to(0.0, 0.5)
	if not lift_open:
		Audio.sfx("door_open", -6.0)
		await open_lift()
	lift_light.light_color = Color("ffd89a")
	lift_light.light_energy = 1.0
	if line_key != "":
		await h.say("SPK_NIHAT", line_key)
	if not (GameState.autotest or GameState.shots_dir != ""):
		pl.frozen = false
		h.set_objective(tr("UI_OBJ_LIFT"), to_global(LIFT_IN) + Vector3(0, 1.0, 0))
		var t := 0.0
		while not in_cabin(pl) and t < 30.0:
			await get_tree().process_frame
			if get_tree().paused:      # duraklatmada sayaç akmaz
				continue
			t += get_process_delta_time()
		h.set_objective("")
	pl.frozen = true
	pl.global_position = to_global(LIFT_IN) + Vector3(0, 0.05, 0)
	pl.face(to_global(Vector3(COR_W / 2, 1.45, LIFT_Z)))


## Yolcu kabinde mi (kapının iç tarafında).
func in_cabin(pl: Player) -> bool:
	var lp := to_local(pl.global_position)
	return lp.x < -COR_W / 2 - 0.3 and absf(lp.z - LIFT_Z) < 0.95


## Göstergeler (koridordaki ve kabindeki) aynı yazıyı gösterir.
func set_dial(text: String) -> void:
	lift_dial.text = "◀ %s ▶" % text
	lift_dial_in.text = lift_dial.text


## Kadran: yıllar akar, to'da durur. Nihat verilirse panele döner, çarkı o çevirir.
func lift_spin(to: String, secs := 1.4, nihat: Person = null) -> void:
	if nihat:
		nihat.look_target = null
		nihat.face_toward(to_global(PANEL_POS))
	var n := maxi(6, int(secs / 0.09))
	for k in n:
		set_dial(String(YEARS[(k * 5 + 3) % YEARS.size()]))
		panel_wheel.rotation.x += 0.55
		if k % 2 == 0:
			Audio.sfx("timer_tick", -9.0, 0.9 + 0.02 * k)
		await get_tree().create_timer(secs / n, false).timeout
	set_dial(to)
	Audio.sfx("ui_confirm", -6.0)


## Kapı kapanır; kabin camgöbeği yanar, sarsılır, makine döner.
func lift_close(pl: Player) -> void:
	lift_open = false
	var tw := create_tween().set_parallel()
	tw.tween_property(lift_door.get_child(0), "position:z", -0.48, 0.7)
	tw.tween_property(lift_door.get_child(1), "position:z", 0.48, 0.7)
	Audio.sfx("door_metal", -6.0)
	await tw.finished
	lift_light.light_color = Color("7ff2ff")
	create_tween().tween_property(lift_light, "light_energy", 3.2, 0.6)
	Audio.sfx("machine_spin", -5.0, 1.2)
	pl.shake(0.35)
	await get_tree().create_timer(0.7, false).timeout


## Girdap (from → to); bitince ekran bembeyaz (Hud beyazda tutar), kabin ışığı eski haline döner.
func lift_go(h: Hud, from: String, to: String, glitch := false, caption := "", secs := 2.6) -> void:
	var v := TimeVortex.new()
	get_parent().add_child(v)
	await v.play_text(from, to, 0.5 if GameState.autotest else secs, glitch, caption)
	Audio.sfx("machine_jump", -4.0)
	h.set_fade(1.0, Color.WHITE)
	v.queue_free()
	lift_light.light_color = Color("ffd89a")
	lift_light.light_energy = 1.0


## Tam gönderiş: Büro'dan to tarihine (Bölüm 3: 2026'daki garaj; Bölüm 17: kuşatmanın ilk sayfası). Kadranda yıl.
func ride_lift(pl: Player, h: Hud, nihat: Person, to: String, line_key := "", caption := "", cut := true) -> void:
	await lift_board(pl, h, nihat, line_key, cut)
	var year := to.split(" ")[-1]
	await lift_spin(year, 1.4, nihat)
	await lift_close(pl)
	await lift_go(h, tr("UI_JUMP_BUREAU"), to, false, caption)


# ================================================================ koridor süsü ve canlılık (v0.99.96)

## ---- ld: koridor süsü + canlılık (boru postası, asma saatler, ilan panoları, mobilya, memurlar, sesler) ----

const LD_PASTEL := [Color("f4e8c8"), Color("d8ecd8"), Color("f0d0d8"), Color("d0e0f4"), Color("efe9d8"), Color("f6dca0")]
const LD_ERA_SFX := {"MÖ 2560": "heave_shout", "MÖ 776": "crowd_camp", "MÖ 44": "sword_clash", "1215": "stamp",
	"1347": "cough", "1453": "drum_boom", "1455": "typewriter", "1492": "cloth", "1517": "pick_tap", "1687": "land_thud",
	"1769": "rumble", "1789": "crowd_gasp", "1815": "cannon", "1903": "drone_hum", "1914": "horn", "1945": "church_bell",
	"1969": "radio_static", "1989": "pick_tap", "2026": "radio_beep", "2150": "veil_hum"}

var _ld_counter: Label3D          # pano C: "KAYIP SANİYE: n/5"
var _ld_cemal: Person
var _ld_zeki: Person
var _ld_cart: Node3D              # Zeki'nin servis arabası (etkileşim kutusu bunun çocuğu)
var _ld_timer: Timer
var _ld_last_amb := 0.0           # son ortam sesi (en çok 3 sn'de bir)
var _ld_era_next := 0.0
var _ld_type_next := 0.0


func _ld_build() -> void:
	_ld_tubes()
	_ld_capsules()
	_ld_clocks()
	_ld_boards()
	_ld_furniture()
	_ld_clerks()
	_ld_desk_extras()
	_ld_loudspeaker()
	_ld_sounds()


# ---------------------------------------------------------------- boru postası

func _ld_tubes() -> void:
	var xs := [-1.35, 1.35]
	var ys := [3.15, 3.05]
	for t in 2:
		var x: float = xs[t]
		var y: float = ys[t]
		Props.cyl(self, 0.07, 84.0, Vector3(x, y, -42.0), C_BRASS, Vector3(90, 0, 0), 8)
		# Tek tek boyunduruk halkaları
		for k in 6:
			Props.cyl(self, 0.085, 0.14, Vector3(x, y, -7.0 - k * 14.0), C_BRASS.darkened(0.3), Vector3(90, 0, 0), 8)
	# Dirsekler: ofis kapısı çevresi ve birkaç oda açıklığı (boru aşağı sarkar)
	for e in [[-1.35, 3.15, -0.3], [-1.35, 3.15, -6.4], [1.35, 3.05, -0.3], [1.35, 3.05, -20.7]]:
		var ex: float = e[0]
		var ey: float = e[1]
		var ez: float = e[2]
		Props.cyl(self, 0.07, 0.75, Vector3(ex, ey - 0.375, ez), C_BRASS, Vector3.ZERO, 8)
		Props.ball(self, 0.09, Vector3(ex, ey, ez), C_BRASS.darkened(0.15), Vector3.ONE, 8)


func _ld_capsules() -> void:
	# [boru x, boru y, geçiş süresi, uç bekleme, başlangıç yönü]
	var defs := [[-1.35, 3.15, 9.0, 0.5, 0], [1.35, 3.05, 14.0, 2.5, 1], [-1.35, 3.15, 18.0, 4.0, 1],
		[1.35, 3.05, 11.0, 1.2, 0], [-1.35, 3.15, 13.0, 6.0, 0], [1.35, 3.05, 19.0, 3.0, 1]]
	for i in defs.size():
		var d: Array = defs[i]
		_ld_capsule(float(d[0]), float(d[1]), float(d[2]), float(d[3]), int(d[4]))


# Kapsül borunun üstünde bir kılıf gibi gezer (borudan biraz kalın: görünsün)
func _ld_capsule(x: float, y: float, dur: float, pause: float, dir: int) -> void:
	var c := Node3D.new()
	add_child(c)
	var za := -1.0
	var zb := -83.0
	if dir == 1:
		za = -83.0
		zb = -1.0
	c.position = Vector3(x, y, za)
	Props.cyl(c, 0.1, 0.42, Vector3.ZERO, Color("6f8a96"), Vector3(90, 0, 0), 8)
	Props.cyl(c, 0.108, 0.06, Vector3(0, 0, 0.18), C_BRASS, Vector3(90, 0, 0), 8)
	var tw := c.create_tween().set_loops()
	tw.tween_interval(pause)
	tw.tween_callback(_ld_whoosh.bind(c))
	tw.tween_property(c, "position:z", zb, dur).from(za).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_interval(pause)
	tw.tween_property(c, "position:z", za, dur).from(zb).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _ld_whoosh(c: Node3D) -> void:
	if GameState.autotest or not is_instance_valid(c) or randf() > 0.2:
		return
	Audio.sfx_at("whoosh_fly", c, -26.0)


# ---------------------------------------------------------------- asma saatler

func _ld_hand(parent: Node3D, length: float, width: float, color: Color, speed: float) -> Node3D:
	var pivot := Node3D.new()
	parent.add_child(pivot)
	Props.box(pivot, Vector3(width, length, 0.09), Vector3(0, length * 0.45, 0), color)
	_spinners.append([pivot, Vector3(0, 0, 1), speed])
	return pivot


func _ld_clocks() -> void:
	var zs := [-12.0, -19.5, -36.0, -46.0, -58.0]
	for i in 5:
		var root := Node3D.new()
		root.position = Vector3(0.9, 2.75, zs[i])
		add_child(root)
		Props.cyl(root, 0.012, 0.55, Vector3(0, 0.375, 0), C_METAL.darkened(0.3), Vector3.ZERO, 6)
		match i:
			0:  # güneş saati: kum rengi disk, sabit gnomon, yavaş dönen gölge
				Props.cyl(root, 0.28, 0.05, Vector3.ZERO, Color("e0c890"), Vector3(90, 0, 0), 20)
				Props.box(root, Vector3(0.03, 0.2, 0.09), Vector3(0, 0.1, 0), Color("5a4630"))
				_ld_hand(root, 0.24, 0.02, Color("7a5a38"), 0.08)
			1:  # su saati: mavi disk, ters dönen ibre, damla
				Props.cyl(root, 0.28, 0.05, Vector3.ZERO, Color("7fb0c8"), Vector3(90, 0, 0), 20)
				_ld_hand(root, 0.24, 0.02, Color("1f3a4a"), -0.45)
				Props.ball(root, 0.035, Vector3(0, 0, 0), Color("c8ecff"), Vector3.ONE, 8)
			2:  # kum saati: 10 sn'de bir döner
				var fl := Node3D.new()
				root.add_child(fl)
				Props.cyl(fl, 0.015, 0.2, Vector3(0, 0.1, 0), Color("b8d4dc"), Vector3.ZERO, 10, 0.1)
				Props.cyl(fl, 0.1, 0.2, Vector3(0, -0.1, 0), Color("b8d4dc"), Vector3.ZERO, 10, 0.015)
				Props.cyl(fl, 0.12, 0.025, Vector3(0, 0.215, 0), C_BRASS, Vector3.ZERO, 10)
				Props.cyl(fl, 0.12, 0.025, Vector3(0, -0.215, 0), C_BRASS, Vector3.ZERO, 10)
				Props.ball(fl, 0.05, Vector3(0, -0.15, 0), Color("e8c878"), Vector3(1, 0.6, 1), 8)
				var tw := fl.create_tween().set_loops()
				tw.tween_interval(10.0)
				tw.tween_property(fl, "rotation:z", PI, 0.8).as_relative().set_trans(Tween.TRANS_SINE)
			3:  # dijital: iki yüzde 88:88 (arka yüzde kırmızı şerit)
				Props.box(root, Vector3(0.52, 0.22, 0.07), Vector3.ZERO, Color("15181a"))
				Props.box(root, Vector3(0.4, 0.12, 0.008), Vector3(0, 0, -0.038), Color("ff2a1a"), Vector3.ZERO, 2.0)
				var lab := Props.label(root, "88:88", Vector3(0, 0, 0.037), 34, Color("ff2a1a"), Vector3.ZERO, 0.48)
				var tb := lab.create_tween().set_loops()
				tb.tween_callback(func(): lab.text = "88 88")
				tb.tween_interval(0.5)
				tb.tween_callback(func(): lab.text = "88:88")
				tb.tween_interval(0.5)
			4:  # atom saati: mavi disk, çekirdek, iki elektron
				Props.cyl(root, 0.28, 0.05, Vector3.ZERO, Color("2a4a9a"), Vector3(90, 0, 0), 20, -1.0, 0.4)
				Props.ball(root, 0.055, Vector3.ZERO, Color("6ad0ff"), Vector3.ONE, 8, 1.5)
				var pa := Node3D.new()
				root.add_child(pa)
				Props.ball(pa, 0.03, Vector3(0.2, 0, 0), Color("ffffff"), Vector3.ONE, 6, 1.5)
				_spinners.append([pa, Vector3(0, 0, 1), 1.6])
				var pb := Node3D.new()
				root.add_child(pb)
				Props.ball(pb, 0.03, Vector3(0, 0.14, 0), Color("c8e8ff"), Vector3.ONE, 6, 1.5)
				_spinners.append([pb, Vector3(0, 0, 1), -2.4])
		_reg("bur_cclock%d" % i, Vector3(0.7, 0.7, 0.5), Vector3.ZERO, "UI_BUR_LOOK", _ld_cclock.bind(i), root)


func _ld_cclock(i: int) -> void:
	_say("BUR_CCLOCK%d" % i)


# ---------------------------------------------------------------- ilan panoları

func _ld_counter_text(n: int) -> String:
	var en := TranslationServer.get_locale().begins_with("en")
	return ("LOST SECONDS: %d/5" if en else "KAYIP SANİYE: %d/5") % n


func _ld_on_seconds(n: int) -> void:
	if is_instance_valid(_ld_counter):
		_ld_counter.text = _ld_counter_text(n)


func _ld_boards() -> void:
	# [dz, dy, genişlik, yükseklik, pastel indeksi, eğim]
	var pa := [[-0.27, 0.0, 0.26, 0.32, 0, 3.0], [0.0, 0.02, 0.22, 0.3, 1, -4.0], [0.28, -0.02, 0.24, 0.34, 2, 5.0], [-0.1, -0.22, 0.5, 0.14, 3, -1.0]]
	var pb := [[-0.28, 0.02, 0.24, 0.3, 5, -3.0], [0.0, 0.0, 0.26, 0.34, 4, 2.0], [0.3, 0.03, 0.22, 0.28, 1, 4.0], [0.02, -0.22, 0.6, 0.12, 2, 1.0], [-0.3, -0.2, 0.2, 0.14, 0, -5.0]]
	var pc := [[-0.33, 0.05, 0.19, 0.24, 3, 4.0], [-0.11, 0.06, 0.19, 0.26, 5, -3.0], [0.11, 0.05, 0.19, 0.22, 0, 2.0], [0.33, 0.05, 0.19, 0.24, 2, -4.0]]
	var pd := [[-0.3, 0.0, 0.25, 0.34, 1, -2.0], [-0.02, 0.03, 0.28, 0.3, 4, 3.0], [0.3, -0.01, 0.24, 0.32, 3, -5.0], [0.0, -0.23, 0.7, 0.1, 5, 0.0]]
	_ld_board("bur_noticeA", 1, -1.1, 1.6, "DUYURU", "NOTICE", pa, ["BUR_NOTICE_A", "BUR_NOTICE_A_2"])
	_ld_board("bur_noticeB", -1, -23.0, 1.6, "KAYIP İLANI", "LOST NOTICE", pb, ["BUR_NOTICE_B"])
	_ld_board("bur_noticeC", 1, -24.2, 1.6, "SANİYE AVI", "SECOND HUNT", pc, ["BUR_NOTICE_C"])
	_ld_board("bur_noticeD", -1, -40.0, 1.6, "İHALE", "TENDER", pd, ["BUR_NOTICE_D"])
	# Pano C'deki sayaç: n/5 (bölme işareti var, düz tamsayı değil)
	_ld_counter = Props.label(self, _ld_counter_text(seconds_found()), Vector3(1.932, 1.6 - 0.23, -24.2), 17, Color("6a1a1a"), Vector3(0, -90, 0), 0.8)
	if not seconds_changed.is_connected(_ld_on_seconds):
		seconds_changed.connect(_ld_on_seconds)


func _ld_board(id: String, e: int, z: float, y: float, tr_head: String, en_head: String, papers: Array, keys: Array) -> void:
	Props.box(self, Vector3(0.05, 0.72, 0.96), Vector3(e * 1.975, y, z), C_WALNUT)
	Props.box(self, Vector3(0.03, 0.62, 0.86), Vector3(e * 1.955, y, z), Color("9a7a4a"))
	var pins := 0
	for p in papers:
		var w: float = p[2]
		var h: float = p[3]
		Props.box(self, Vector3(0.006, h, w), Vector3(e * 1.938, y + float(p[1]), z + float(p[0])), LD_PASTEL[int(p[4])], Vector3(float(p[5]), 0, 0))
		if pins < 2:
			pins += 1
			Props.ball(self, 0.014, Vector3(e * 1.932, y + float(p[1]) + h * 0.5 - 0.03, z + float(p[0])), Color("b8323a"), Vector3.ONE, 6)
	_lbl(self, tr_head, en_head, Vector3(e * 1.932, y + 0.24, z), 18, Color("2a1a10"), Vector3(0, -90 * e, 0), 0.8)
	_reg(id, Vector3(0.3, 0.8, 1.0), Vector3(e * 1.9, y, z), "UI_BUR_LOOK", _ld_notice.bind(id, keys))


func _ld_notice(id: String, keys: Array) -> void:
	_say(_next(id, keys))


# ---------------------------------------------------------------- koridor mobilyası

func _ld_furniture() -> void:
	# Su soğutucusu (doğu duvarı)
	Props.box(self, Vector3(0.36, 0.95, 0.36), Vector3(1.6, 0.475, -24.5), Color("d8e0e0"))
	Props.cyl(self, 0.15, 0.42, Vector3(1.6, 1.16, -24.5), Color("7ec0e8"), Vector3.ZERO, 12)
	Props.box(self, Vector3(0.08, 0.05, 0.07), Vector3(1.4, 0.82, -24.5), Color("b8323a"))
	var bub := Props.ball(self, 0.035, Vector3(1.47, 1.0, -24.5), Color("ffffff"), Vector3.ONE, 6, 1.0)
	_bobbers.append([bub, 1.0, 0.14, 2.2, 0.0])
	_reg("bur_cooler", Vector3(0.5, 1.4, 0.5), Vector3(1.6, 0.7, -24.5), "UI_BUR_USE", _ld_cooler)
	# Areka palmiyesi
	Props.cyl(self, 0.2, 0.36, Vector3(1.55, 0.18, -0.9), C_ORANGE.darkened(0.2), Vector3.ZERO, 10, 0.16)
	Props.cyl(self, 0.035, 0.8, Vector3(1.55, 0.7, -0.9), Color("6a5a30"), Vector3.ZERO, 6)
	for k in 5:
		var th := deg_to_rad(k * 72.0 + 20.0)
		var off := Vector3(cos(th), -0.05, -sin(th)) * 0.3
		Props.box(self, Vector3(0.7, 0.02, 0.14), Vector3(1.55, 1.1, -0.9) + off, Color("3f7a3a"), Vector3(0, rad_to_deg(th), -28))
	_reg("bur_palm", Vector3(0.7, 1.3, 0.7), Vector3(1.55, 0.65, -0.9), "UI_BUR_LOOK", _ld_palm)
	# Banklar: duvara yaslı, kapı ve açıklık dışında
	_ld_bench(-1, -10.2)
	_ld_bench(-1, -14.0)
	_ld_bench(1, -27.4)
	# İki sandalye, birinin sırtında ceket
	for j in 2:
		var cz := -20.5 - j * 1.2
		Props.box(self, Vector3(0.42, 0.05, 0.42), Vector3(-1.65, 0.45, cz), C_WOOD)
		Props.box(self, Vector3(0.05, 0.45, 0.42), Vector3(-1.85, 0.7, cz), C_WOOD_DARK)
		Props.box(self, Vector3(0.1, 0.43, 0.1), Vector3(-1.65, 0.215, cz), C_WOOD_DARK)
	Props.box(self, Vector3(0.07, 0.4, 0.36), Vector3(-1.8, 0.68, -20.5), Color("4a5a78"), Vector3(0, 0, 5))
	# Boş altın çerçeveler (portre sırası)
	var eras := ["wig", "laurel", "helmet", "tophat"]
	var bgs := [Color("6a2a2a"), Color("2f4a3a"), Color("3a3f5a"), Color("5a4a2a")]
	var pzs := [-1.0, -2.2, -3.4, -20.8]
	for i in pzs.size():
		_ld_portrait(float(pzs[i]), eras[i], bgs[i])
	# Duvar lambaları (kehribar parlak kutular; gerçek ışık yok)
	for s in [[-1, -9.9], [-1, -14.0], [-1, -20.3], [1, -36.2], [-1, -44.75]]:
		var se: int = s[0]
		Props.box(self, Vector3(0.08, 0.16, 0.1), Vector3(se * 1.96, 2.05, float(s[1])), Color("ffb040"), Vector3.ZERO, 1.5)


## Eski müdürlerin portresi: pirinç çerçeve, renkli zemin, büst ve çağın başlığı (peruk, defne, miğfer, silindir)
func _ld_portrait(pz: float, era: String, bg: Color) -> void:
	var x := -1.965
	Props.box(self, Vector3(0.04, 0.55, 0.42), Vector3(-1.98, 2.35, pz), C_BRASS)
	Props.box(self, Vector3(0.03, 0.45, 0.33), Vector3(x, 2.35, pz), bg)
	Props.box(self, Vector3(0.02, 0.14, 0.24), Vector3(x + 0.012, 2.19, pz), Color("2a2a30"))          # omuzlar
	Props.ball(self, 0.075, Vector3(x + 0.015, 2.34, pz), Color("d9b08a"), Vector3(0.4, 1.1, 1.0), 8)   # baş
	Props.box(self, Vector3(0.02, 0.012, 0.07), Vector3(x + 0.03, 2.31, pz), Color("3a2a20"))        # bıyık
	match era:
		"wig":     # pudralı kıvırcık peruk (fes Tolga'ya özel)
			Props.ball(self, 0.07, Vector3(x + 0.012, 2.4, pz), Color("ece8e0"), Vector3(0.4, 0.8, 1.25), 8)
			for wz: float in [-0.075, 0.075]:
				for wy in 3:
					Props.ball(self, 0.032, Vector3(x + 0.014, 2.36 - wy * 0.045, pz + wz), Color("e2ddd2"), Vector3(0.5, 1, 1), 6)
		"laurel":
			Props.ring(self, 0.06, 0.08, Vector3(x + 0.015, 2.4, pz), Color("6a9a3a"), Vector3(0, 0, 90))
		"helmet":
			Props.ball(self, 0.08, Vector3(x + 0.015, 2.39, pz), Color("9aa0a8"), Vector3(0.45, 0.7, 1.05), 8)
		"tophat":
			Props.cyl(self, 0.05, 0.1, Vector3(x + 0.015, 2.45, pz), Color("1a1a1e"), Vector3.ZERO, 8)
			Props.cyl(self, 0.07, 0.01, Vector3(x + 0.015, 2.4, pz), Color("1a1a1e"), Vector3.ZERO, 8)
	Props.box(self, Vector3(0.02, 0.04, 0.16), Vector3(-1.97, 2.06, pz), C_BRASS)


func _ld_bench(e: int, z: float) -> void:
	var bl := 1.3
	Props.box(self, Vector3(0.42, 0.05, bl), Vector3(e * 1.77, 0.46, z), C_WOOD)
	Props.box(self, Vector3(0.05, 0.42, bl), Vector3(e * 1.96, 0.72, z), C_WOOD_DARK)
	for sg in 2:
		var sf := -1.0 + sg * 2.0
		Props.box(self, Vector3(0.36, 0.44, 0.06), Vector3(e * 1.78, 0.22, z + sf * (bl * 0.5 - 0.06)), C_WOOD_DARK)


func _ld_cooler() -> void:
	var k := _next("bur_cooler", ["BUR_COOLER", "BUR_COOLER_2"])
	if not GameState.autotest:
		Audio.sfx("splash", -22.0, 1.4)
	_say(k)


func _ld_palm() -> void:
	_say(_next("bur_palm", ["BUR_PALM", "BUR_PALM_2"]))


# ---------------------------------------------------------------- memurlar

func _ld_talk(p: Person, secs: float) -> void:
	if not is_instance_valid(p):
		return
	p.talking = true
	get_tree().create_timer(secs).timeout.connect(func():
		if is_instance_valid(p):
			p.talking = false)


func _ld_clerks() -> void:
	# Katip Cemal: sırtı duvarda, masası ve daktilosu koridora dönük kayıt masası (yüzü duvara dönüktü)
	Props.box(self, Vector3(0.5, 0.04, 1.0), Vector3(-1.15, 0.78, -2.3), C_WOOD)
	Props.box(self, Vector3(0.04, 0.76, 0.96), Vector3(-0.92, 0.38, -2.3), C_WOOD_DARK)
	for mz: float in [-2.75, -1.85]:
		Props.box(self, Vector3(0.46, 0.76, 0.04), Vector3(-1.15, 0.38, mz), C_WOOD_DARK)
	Props.box(self, Vector3(0.3, 0.1, 0.26), Vector3(-1.2, 0.85, -2.25), Color("1f2426"))
	Props.box(self, Vector3(0.22, 0.2, 0.01), Vector3(-1.2, 0.98, -2.12), C_PAPER, Vector3(-12, 90, 0))
	Props.box(self, Vector3(0.22, 0.12, 0.2), Vector3(-1.1, 0.86, -2.65), C_PAPER)
	_lbl(self, "KAYIT", "REGISTRY", Vector3(-0.895, 0.6, -2.3), 26, Color("e8d8a8"), Vector3(0, 90, 0), 0.8)
	# Cemal'in sandalyesi (sırtı duvara yakın)
	Props.box(self, Vector3(0.42, 0.04, 0.42), Vector3(-1.7, 0.45, -2.3), C_WOOD)
	Props.box(self, Vector3(0.04, 0.42, 0.4), Vector3(-1.9, 0.7, -2.3), C_WOOD_DARK)
	for clx: float in [-1.88, -1.52]:
		for clz: float in [-2.48, -2.12]:
			Props.box(self, Vector3(0.035, 0.43, 0.035), Vector3(clx, 0.215, clz), C_WOOD_DARK)
	_ld_cemal = Person.new({"coat": Color("5a5048"), "pants": Color("2a2a30"), "hair": Color("3a3a3a"), "hat": "none",
		"glasses": true, "mustache": true, "skin": Color("e0b090")})
	_ld_cemal.set_meta("spk", "SPK_CEMAL")
	_ld_cemal.set_meta("no_yield", true)
	_ld_cemal.position = Vector3(-1.68, 0.0, -2.3)
	_ld_cemal.rotation_degrees.y = 90
	add_child(_ld_cemal)
	_ld_cemal.set_activity("write_desk")      # sandalyede, masada yazar ("write" yere bağdaş kurmuş yazandır: yerde oturuyordu)
	_reg("bur_cemal", Vector3(0.9, 1.8, 1.0), Vector3(-1.4, 0.9, -2.3), "UI_BUR_TALK", _ld_cemal_talk, null, false)
	# Kurye Zeki + servis arabası
	_ld_zeki = Person.new({"coat": Color("2f5f8a"), "pants": Color("4a4038"), "hair": Color("2a1a10"), "hat": "courier",
		"mustache": true, "skin": Color("d9a07a"), "scarf": Color("b8323a")})
	_ld_zeki.set_meta("spk", "SPK_ZEKI")
	_ld_zeki.set_meta("no_yield", true)
	add_child(_ld_zeki)
	# Araba Zeki'nin önünde, ona bağlı: iki eliyle tutamağından iter, dönerken araba da onunla döner
	# (eskiden araba ayrı süzülüyordu, uçta kendi kendine Zeki'nin yanından dolanıyordu)
	_ld_cart = Node3D.new()
	_ld_cart.position = Vector3(0, 0, 0.95)
	_ld_zeki.add_child(_ld_cart)
	_ld_build_cart(_ld_cart)
	_ld_zeki.set_activity("push")
	_reg("bur_trolley", Vector3(0.7, 1.0, 1.0), Vector3(0, 0.55, 0), "UI_BUR_TALK", _ld_zeki_talk, _ld_cart, false)
	var beacon := _ld_zeki._head.find_child("Beacon", true, false) as Node3D
	if beacon:     # kasktaki ikaz lambası döner
		var bt := create_tween().set_loops()
		bt.tween_property(beacon, "rotation:y", TAU, 0.9).from(0.0)
	_ld_zeki.rotation_degrees.y = 180
	if GameState.autotest:
		_ld_zeki.position = Vector3(1.0, 0.0, -40.0)
		return
	_ld_zeki.position = Vector3(1.0, 0.0, -4.0)
	# ~45 sn: -z yönünde iterek yürür; uçta arabayla birlikte koridorun ortasına doğru döner (duvara sürtmesin), geri gelir
	var tw := create_tween().set_loops()
	tw.tween_property(_ld_zeki, "position:z", -44.0, 20.0).from(-4.0)
	tw.tween_property(_ld_zeki, "rotation_degrees:y", 360.0, 1.8).from(180.0).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(0.8)
	tw.tween_property(_ld_zeki, "position:z", -4.0, 20.0)
	tw.tween_property(_ld_zeki, "rotation_degrees:y", 180.0, 1.8).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(0.4)


func _ld_build_cart(c: Node3D) -> void:
	Props.box(c, Vector3(0.5, 0.03, 0.9), Vector3(0, 0.28, 0), C_WOOD)
	Props.box(c, Vector3(0.5, 0.03, 0.9), Vector3(0, 0.78, 0), C_WOOD)
	for sx in [-0.24, 0.24]:
		Props.box(c, Vector3(0.03, 0.62, 0.9), Vector3(sx, 0.56, 0), C_WOOD_DARK)
	for hz in [-0.46, 0.46]:
		Props.cyl(c, 0.015, 0.5, Vector3(0, 0.98, hz), C_METAL, Vector3(0, 0, 90), 6)
		for hx: float in [-0.24, 0.24]:
			Props.cyl(c, 0.012, 0.2, Vector3(hx, 0.88, hz), C_METAL, Vector3.ZERO, 6)
	# Dört küçük teker (eskiden arabanın altında kütük gibi duran iki silindir), ince dingil
	for az in [-0.33, 0.33]:
		Props.cyl(c, 0.008, 0.5, Vector3(0, 0.07, az), C_METAL, Vector3(0, 0, 90), 4)
		for wx: float in [-0.22, 0.22]:
			Props.cyl(c, 0.07, 0.04, Vector3(wx, 0.07, az), Color("2a2a2e"), Vector3(0, 0, 90), 12)
			Props.cyl(c, 0.03, 0.045, Vector3(wx, 0.07, az), C_METAL, Vector3(0, 0, 90), 8)
		for wx: float in [-0.22, 0.22]:
			Props.box(c, Vector3(0.02, 0.2, 0.02), Vector3(wx, 0.18, az), C_METAL)
	# Üst raf: çay bardakları ve semaver; alt raf: simit ve dosya kutuları
	for g in 3:
		Props.cyl(c, 0.03, 0.08, Vector3(-0.12 + g * 0.12, 0.84, -0.28), Color("b3402a"), Vector3.ZERO, 8, 0.036)
	Props.cyl(c, 0.1, 0.26, Vector3(0, 0.93, 0.15), C_BRASS, Vector3.ZERO, 10, 0.07)
	Props.cyl(c, 0.1, 0.09, Vector3(-0.1, 0.345, -0.25), Color("c8802a"), Vector3.ZERO, 10)
	Props.box(c, Vector3(0.2, 0.18, 0.26), Vector3(0.1, 0.39, 0.2), Color("8a6a40"))
	Props.box(c, Vector3(0.2, 0.14, 0.26), Vector3(-0.1, 0.37, 0.25), Color("b8a070"))


func _ld_cemal_talk() -> void:
	_ld_talk(_ld_cemal, 3.5)
	_say(_next("bur_cemal", ["BUR_CEMAL", "BUR_CEMAL_2"]), 3.8, "SPK_CEMAL")


func _ld_zeki_talk() -> void:
	_ld_talk(_ld_zeki, 3.5)
	_say(_next("bur_trolley", ["BUR_TROLLEY", "BUR_TROLLEY_2"]), 3.8, "SPK_ZEKI")


# ---------------------------------------------------------------- Başdenetçi'nin masası: süsler

func _ld_desk_extras() -> void:
	var z := 0.0
	var dr := _desk_root
	# Yeşil bankacı lambası
	Props.cyl(dr, 0.06, 0.025, Vector3(-0.8, 0.8525, z + 0.2), C_BRASS, Vector3.ZERO, 10)
	Props.cyl(dr, 0.01, 0.22, Vector3(-0.8, 0.965, z + 0.2), C_BRASS, Vector3.ZERO, 6)
	Props.cyl(dr, 0.06, 0.2, Vector3(-0.8, 1.09, z + 0.2), Color("2a7a4a"), Vector3(0, 0, 90), 10, -1.0, 0.25)
	_glow(dr, Vector3(-0.8, 0.85, z + 0.3), Vector2(0.8, 0.6), Color("ffc870"), Vector3(-90, 0, 0), 0.35)
	# Pirinç isim plakası: masa ön kenarında, hafif geriye yaslı
	Props.box(dr, Vector3(0.46, 0.1, 0.03), Vector3(-0.35, 0.9, z + 0.5), C_BRASS, Vector3(-20, 0, 0))
	Props.label(dr, "M. ZAMANOVA", Vector3(-0.35, 0.906, z + 0.516), 16, Color("2a1a10"), Vector3(-20, 0, 0), 0.42)
	if GameState.autotest:
		return
	# Kâğıt dağlarından süzülen sayfalar
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var sx := [-1.0, 0.85, -0.7, 1.0, -0.95]
	for i in 5:
		var start := Vector3(sx[i], 2.6, z - 0.1 + rng.randf_range(-0.1, 0.25))
		var end := Vector3(sx[i] + rng.randf_range(-0.5, 0.5), 0.02, z + rng.randf_range(-0.2, 1.0))
		var sheet := Props.box(dr, Vector3(0.2, 0.004, 0.28), start, C_PAPER, Vector3(rng.randf_range(-20, 20), rng.randf_range(0, 90), 0))
		_ld_paper_fall(sheet, start, end, 12.0, float(i) / 5.0)


func _ld_paper_fall(sheet: MeshInstance3D, start: Vector3, end: Vector3, dur: float, phase: float) -> void:
	sheet.position = start.lerp(end, phase)
	var tw := sheet.create_tween()
	tw.tween_property(sheet, "position", end, dur * (1.0 - phase))
	tw.tween_callback(_ld_paper_loop.bind(sheet, start, end, dur))


func _ld_paper_loop(sheet: MeshInstance3D, start: Vector3, end: Vector3, dur: float) -> void:
	if not is_instance_valid(sheet):
		return
	var tw := sheet.create_tween().set_loops()
	tw.tween_property(sheet, "position", end, dur).from(start).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(sheet, "rotation_degrees", Vector3(30, 180, -25), dur).from(Vector3(-10, 0, 15))


# ---------------------------------------------------------------- asansör: kafesli hoparlör

func _ld_loudspeaker() -> void:
	# Tabelanın (SAHA ÇIKIŞI, z -32.9..-35.1) yanında; önünde durup yazıyı örtüyordu
	Props.box(self, Vector3(0.04, 0.34, 0.34), Vector3(-1.94, 2.9, -32.3), C_METAL.darkened(0.3))
	Props.cyl(self, 0.05, 0.36, Vector3(-1.76, 2.9, -32.3), C_BRASS, Vector3(0, 0, -90), 12, 0.17)
	Props.ring(self, 0.15, 0.18, Vector3(-1.58, 2.9, -32.3), Color("3a3a3e"), Vector3(0, 0, 90))
	Props.label(self, "♪", Vector3(-1.56, 3.15, -32.3), 40, Color("ffb020"), Vector3(0, 90, 0), 0.4)
	_reg("bur_mehter", Vector3(0.5, 0.5, 0.6), Vector3(-1.8, 2.9, -32.3), "UI_BUR_LOOK", _ld_mehter)


func _ld_mehter() -> void:
	var k := _next("bur_mehter", ["BUR_MEHTER", "BUR_MEHTER_2"])
	if k == "BUR_MEHTER_2":
		Audio.sfx("drum_boom", -24.0)
	_say(k)


# ---------------------------------------------------------------- çağ sesleri

func _ld_sounds() -> void:
	if GameState.autotest:
		return
	_ld_timer = Timer.new()
	_ld_timer.wait_time = 0.7
	_ld_timer.autostart = true
	add_child(_ld_timer)
	_ld_timer.timeout.connect(_ld_tick)


func _ld_tick() -> void:
	if GameState.autotest or not is_instance_valid(player) or not is_visible_in_tree():
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now - _ld_last_amb < 3.0:
		return
	var lp := to_local(player.global_position)
	var pp := Vector2(lp.x, lp.z)
	# Kapıya 4 m yakınken çağın sesi, uzaktan boğuk
	if now >= _ld_era_next:
		for d in DOORS:
			var dp := Vector2(float(d[0]) * 2.0, float(d[1]))
			if dp.distance_to(pp) < 4.0:
				var nm: String = LD_ERA_SFX.get(String(d[2]), "")
				if nm != "":
					Audio.sfx(nm, randf_range(-30.0, -26.0))
					_ld_last_amb = now
					_ld_era_next = now + randf_range(6.0, 10.0)
					return
				break
	# Cemal'in daktilosu
	if now >= _ld_type_next and is_instance_valid(_ld_cemal) and Vector2(_ld_cemal.position.x, _ld_cemal.position.z).distance_to(pp) < 6.0:
		Audio.sfx_at("typewriter_bell" if randf() < 0.12 else "typewriter", _ld_cemal, -24.0)
		_ld_last_amb = now
		_ld_type_next = now + randf_range(4.0, 7.0)


# ================================================================ çay ocağı, bekleme salonu, kayıp zaman bürosu (v0.99.96)

## ---- rb: Çay Ocağı + Bekleme Salonu + Kayıp Zaman Bürosu (Bureau içine yapıştırılacak yöntemler) ----

var _rb_mats := {}                  # saydam malzeme önbelleği
var _rb_necmi_p: Person
var _rb_sabri_p: Person
var _rb_paper: MeshInstance3D       # Sabri'nin gazetesi
var _rb_paper_busy := false
var _rb_teapot_pos := Vector3(3.6, 1.06, -3.9)


func _rb_build() -> void:
	_rb_tea()
	_rb_wait()
	_rb_lost()


# ---------------------------------------------------------------- ortak yardımcılar

## Saydam malzeme (hayalet, cam, buhar); aynı parametre aynı malzemeyi paylaşır.
func _rb_mat(col: Color, alpha: float, emis: float, unshaded := false) -> StandardMaterial3D:
	var key := "%s|%.2f|%.2f|%s" % [col.to_html(), alpha, emis, unshaded]
	if _rb_mats.has(key):
		return _rb_mats[key]
	var m := StandardMaterial3D.new()
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(col.r, col.g, col.b, alpha)
	if emis > 0.0:
		m.emission_enabled = true
		m.emission = col
		m.emission_energy_multiplier = emis
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_rb_mats[key] = m
	return m


func _rb_t(mi: MeshInstance3D, m: Material) -> MeshInstance3D:
	mi.material_override = m
	return mi


## 4582119 -> "4.582.119"
func _rb_fmt(n: int) -> String:
	var s := str(n)
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "." + out
	return out


## Konuşurken ağız oynasın
func _rb_talk(p: Person, secs: float) -> void:
	if p == null:
		return
	p.talking = true
	await get_tree().create_timer(secs).timeout
	if is_instance_valid(p):
		p.talking = false


# ---------------------------------------------------------------- 1. ÇAY OCAĞI (x 2..7, z -2.2..-7.0)

func _rb_tea() -> void:
	var cw := Color("e8e2d0")
	var tq := Color("3aa6a0")
	_floor(Vector2(5.0, 4.8), Vector3(4.5, 0, -4.6), Color("b5a58a"), Color("a69677"), 2.0)
	Props.solid(self, Vector3(5.2, 0.2, 5.0), Vector3(4.6, 3.1, -4.6), C_CEIL)
	_wall(Vector3(0.2, 0.4, 4.8), Vector3(2.1, 3.2, -4.6), Color("2f7f7a"))     # söve (3.0-3.4)
	_wall(Vector3(5.2, 3.4, 0.2), Vector3(4.6, 1.7, -2.2), cw)
	_wall(Vector3(5.2, 3.4, 0.2), Vector3(4.6, 1.7, -7.0), cw)
	_wall(Vector3(0.2, 3.4, 5.0), Vector3(7.1, 1.7, -4.6), cw)
	# turkuaz fayans lambri
	Props.box(self, Vector3(5.0, 1.1, 0.04), Vector3(4.6, 0.55, -2.32), tq)
	Props.box(self, Vector3(5.0, 1.1, 0.04), Vector3(4.6, 0.55, -6.88), tq)
	Props.box(self, Vector3(0.04, 1.1, 4.6), Vector3(6.98, 0.55, -4.6), tq)
	_lbl(self, "ÇAY OCAĞI", "TEA NOOK", Vector3(1.98, 3.2, -4.6), 56, Color("f4ecd4"), Vector3(0, -90, 0))
	# tezgâh
	Props.solid(self, Vector3(0.8, 1.0, 3.0), Vector3(3.6, 0.5, -4.9), tq)
	Props.box(self, Vector3(0.95, 0.06, 3.15), Vector3(3.6, 1.03, -4.9), Color("8a6a48"))
	# ocak + çaydanlık + demlik
	var tp := _rb_teapot_pos
	var copper := Color("b87333")
	Props.cyl(self, 0.14, 0.05, tp + Vector3(0, 0.025, 0), Color("2a2a2a"))
	Props.ball(self, 0.045, tp + Vector3(0, 0.08, 0), Color("2a7bff"), Vector3(1, 1.3, 1), 6, 3.0)
	Props.cyl(self, 0.15, 0.2, tp + Vector3(0, 0.2, 0), copper, Vector3.ZERO, 10, 0.11, 0.1)
	Props.cyl(self, 0.09, 0.16, tp + Vector3(0, 0.38, 0), copper, Vector3.ZERO, 10, 0.07, 0.1)
	Props.ball(self, 0.05, tp + Vector3(0, 0.49, 0), copper, Vector3(1, 0.7, 1), 8)
	Props.box(self, Vector3(0.04, 0.04, 0.14), tp + Vector3(0, 0.24, 0.17), copper, Vector3(30, 0, 0))
	# buhar: üç saydam top
	var steam := Node3D.new()
	steam.position = tp + Vector3(0, 0.56, 0)
	add_child(steam)
	var sm := _rb_mat(Color.WHITE, 0.3, 0.0, true)
	for i in 3:
		var b := Props.ball(steam, 0.04 + 0.01 * i, Vector3(0.02 * (i - 1), 0.1 * i, 0), Color.WHITE, Vector3.ONE, 6)
		_rb_t(b, sm)
		_bobbers.append([b, 0.1 * i, 0.05, 1.6 + 0.4 * i, float(i) * 1.7])
	Props.strip_outlines(steam)
	# ince belli bardaklar (tabak + cam + çay)
	var glass := _rb_mat(Color("e8f4f4"), 0.3, 0.0)
	for i in 4:
		var z := -5.3 - 0.14 * i
		Props.cyl(self, 0.06, 0.01, Vector3(3.6, 1.09, z), Color("f0ece0"), Vector3.ZERO, 10)
		Props.cyl(self, 0.027, 0.06, Vector3(3.6, 1.125, z), Color("a8501a"), Vector3.ZERO, 8, -1.0, 0.4)
		_rb_t(Props.cyl(self, 0.03, 0.09, Vector3(3.6, 1.145, z), Color.WHITE, Vector3.ZERO, 8, 0.04), glass)
	# şekerlik
	Props.cyl(self, 0.07, 0.08, Vector3(3.6, 1.1, -6.15), Color("f0ece0"))
	Props.ball(self, 0.04, Vector3(3.6, 1.16, -6.15), Color("f0ece0"), Vector3(1, 0.6, 1), 6)
	# arka duvar: çay kutuları rafı, takvim, tabela
	Props.box(self, Vector3(0.3, 0.04, 2.4), Vector3(6.85, 1.25, -3.9), C_WOOD)
	var tins := [Color("c0392b"), Color("2e86c1"), Color("d4ac0d"), Color("27ae60")]
	for i in 4:
		Props.cyl(self, 0.07, 0.2, Vector3(6.85, 1.37, -3.2 - 0.5 * i), tins[i], Vector3.ZERO, 8)
	Props.box(self, Vector3(0.02, 0.38, 0.28), Vector3(6.96, 1.7, -6.1), C_PAPER)
	Props.box(self, Vector3(0.025, 0.08, 0.28), Vector3(6.955, 1.92, -6.1), Color("b83a2a"))
	_lbl(self, "29 MAYIS", "29 MAY", Vector3(6.93, 1.66, -6.1), 30, Color("222222"), Vector3(0, -90, 0), 0.26)
	Props.box(self, Vector3(0.04, 0.8, 1.9), Vector3(6.96, 2.1, -4.6), Color("2b4a3a"))
	_lbl(self, "ÇAY 1 LİRA", "TEA 1 LIRA", Vector3(6.93, 2.3, -4.6), 52, Color("f0e8d0"), Vector3(0, -90, 0))
	Props.box(self, Vector3(0.02, 0.05, 1.5), Vector3(6.94, 2.3, -4.6), Color("d8281c"), Vector3(6, 0, 0))
	_lbl(self, "ÜCRETSİZ (SONSUZA DEK)", "FREE (FOREVER)", Vector3(6.93, 1.93, -4.6), 30, Color("ffd24a"), Vector3(0, -90, 0), 1.6)
	# sıcak ışık
	_bulb(Vector3(4.5, 2.6, -4.6), Color("ffb866"), 1.3, 6.5)
	Props.ball(self, 0.07, Vector3(4.5, 2.72, -4.6), Color("ffd89a"), Vector3.ONE, 6, 3.0)
	Props.cyl(self, 0.028, 0.06, Vector3(4.5, 2.81, -4.6), Color("3a3430"), Vector3.ZERO, 8)   # duy
	Props.cyl(self, 0.006, 0.2, Vector3(4.5, 2.93, -4.6), Color("222222"), Vector3.ZERO, 4)    # kordon (tavana)
	# Çaycı Necmi
	_rb_necmi_p = Person.new({"coat": Color("cfd4d0"), "pants": Color("3a3a42"), "hair": Color("8a8a8a"),
		"mustache": true, "apron": Color("f0eee4"), "hat": "none"})
	_rb_necmi_p.set_meta("spk", "SPK_NECMI")
	_rb_necmi_p.set_meta("no_talk", true)
	_rb_necmi_p.position = Vector3(4.8, 0, -5.2)
	_rb_necmi_p.rotation_degrees.y = -90
	add_child(_rb_necmi_p)
	_rb_necmi_p.set_activity("stir")
	# etkileşimler
	_reg("bur_teapot", Vector3(0.5, 0.7, 0.5), tp + Vector3(0, 0.3, 0), "UI_BUR_LOOK", _rb_teapot)
	_reg("bur_necmi", Vector3(1.0, 1.8, 0.9), Vector3(4.8, 0.9, -5.2), "UI_BUR_TALK", _rb_necmi, self, false)


func _rb_teapot() -> void:
	_say(_next("bur_teapot", ["BUR_TEAPOT", "BUR_TEAPOT_2"]))
	Audio.sfx("tea_stir", -10.0)
	if _count("bur_teapot") == 2:
		_second(1, _rb_teapot_pos + Vector3(0, 0.3, 0))


func _rb_necmi() -> void:
	_say(_next("bur_necmi", ["BUR_NECMI", "BUR_NECMI_2", "BUR_NECMI_3"]), 4.0, "SPK_NECMI")
	Audio.sfx("tea_stir", -8.0)
	if is_instance_valid(_rb_necmi_p):
		_rb_necmi_p.emote("nod")
	_rb_talk(_rb_necmi_p, 3.5)


# ---------------------------------------------------------------- 2. BEKLEME SALONU (x -8.5..-2, z -3.5..-11.5)

func _rb_wait() -> void:
	var wall := Color("cfc08e")
	var blue := Color("2d5f8a")
	_floor(Vector2(6.5, 8.0), Vector3(-5.25, 0, -7.5), Color("6a5a46"), Color("5f5040"), 2.0)
	Props.solid(self, Vector3(6.7, 0.2, 8.2), Vector3(-5.35, 3.5, -7.5), C_CEIL)
	_wall(Vector3(6.7, 3.4, 0.2), Vector3(-5.35, 1.7, -3.5), wall)
	_wall(Vector3(6.7, 3.4, 0.2), Vector3(-5.35, 1.7, -11.5), wall)
	_wall(Vector3(0.2, 3.4, 8.2), Vector3(-8.6, 1.7, -7.5), wall)
	Props.box(self, Vector3(6.4, 1.1, 0.04), Vector3(-5.3, 0.55, -3.62), blue)
	Props.box(self, Vector3(6.4, 1.1, 0.04), Vector3(-5.3, 0.55, -11.38), blue)
	Props.box(self, Vector3(0.04, 1.1, 7.8), Vector3(-8.48, 0.55, -7.5), blue)
	# loş sodyum ışığı + armatür
	_bulb(Vector3(-5.3, 3.0, -7.5), Color("ffc477"), 0.9, 8.0)
	Props.box(self, Vector3(0.2, 0.05, 2.0), Vector3(-5.3, 3.35, -7.5), Color("ffd9a0"), Vector3.ZERO, 1.5)
	# asma tabela
	Props.box(self, Vector3(0.05, 0.5, 2.4), Vector3(-2.6, 2.8, -6.4), Color("1d3f5a"))
	for cz: float in [-7.3, -5.5]:   # askı zincirleri (tabela havada durmasın)
		Props.cyl(self, 0.008, 0.38, Vector3(-2.6, 3.23, cz), C_METAL, Vector3.ZERO, 4)
	_lbl(self, "BEKLEME SALONU", "WAITING ROOM", Vector3(-2.57, 2.8, -6.4), 40, Color("f4ecd4"), Vector3(0, 90, 0), 2.2)
	# turuncu kova koltuk sıraları (arka duvara bakar)
	var orange := Color("e08a2c")
	var steel := Color("55606a")
	for r in 3:
		var x := -4.6 - 1.3 * r
		Props.box(self, Vector3(0.08, 0.08, 3.0), Vector3(x, 0.32, -7.9), steel)
		Props.box(self, Vector3(0.06, 0.32, 0.06), Vector3(x, 0.16, -6.6), steel)
		Props.box(self, Vector3(0.06, 0.32, 0.06), Vector3(x, 0.16, -9.2), steel)
		if r == 2:
			# Son sıranın ilk koltuğunda Nasreddin Hoca ters oturur (ata biner gibi, kolları sırtlıkta): onun sırtlığı
			# ayrı ve dar, bacakları iki yanından geçsin; sıranın sürekli sırtlığı bacaklarını içine alıyordu
			Props.box(self, Vector3(0.05, 0.34, 2.12), Vector3(x - 0.22, 0.68, -8.24), orange)
			# Hoca'nın sırtlığı: kaftan (yarıçap 0,32) sırtlığı kesiyordu; plaka kaftanın dışına, kendi ayağıyla durur
			Props.box(self, Vector3(0.05, 0.34, 0.3), Vector3(x - 0.4, 0.74, -6.8), orange)
			Props.box(self, Vector3(0.05, 0.57, 0.05), Vector3(x - 0.4, 0.285, -6.8), steel)
		else:
			Props.box(self, Vector3(0.05, 0.34, 2.8), Vector3(x - 0.22, 0.68, -7.9), orange)
		for i in 5:
			Props.box(self, Vector3(0.4, 0.06, 0.46), Vector3(x, 0.45, -6.8 - 0.55 * i), orange)
	# sıra numarası makinesi
	Props.box(self, Vector3(0.4, 1.3, 0.4), Vector3(-2.7, 0.65, -4.6), Color("8a949a"))
	Props.box(self, Vector3(0.46, 0.3, 0.46), Vector3(-2.7, 1.45, -4.6), Color("c42a22"))
	_lbl(self, "SIRA NO", "TICKET", Vector3(-2.46, 1.45, -4.6), 36, Color.WHITE, Vector3(0, 90, 0), 0.4)
	Props.box(self, Vector3(0.02, 0.22, 0.1), Vector3(-2.49, 1.0, -4.6), C_PAPER, Vector3(0, 0, -8))
	_reg("bur_ticket", Vector3(0.6, 1.2, 0.7), Vector3(-2.7, 0.9, -4.6), "UI_BUR_PULL", _rb_ticket)
	# kırmızı LED ekran (arka duvar), yanıp söner
	# LED ekran girişin üstünde asılı, salona bakar: koltuklar ona (girişe) döner, oturanların yüzü görünür
	Props.box(self, Vector3(0.06, 0.62, 2.6), Vector3(-3.05, 2.6, -6.4), Color("1a1a1a"))
	for hz: float in [-7.4, -5.4]:
		Props.cyl(self, 0.01, 0.8, Vector3(-3.05, 3.1, hz), C_METAL, Vector3.ZERO, 4)
	_glow(self, Vector3(-3.12, 2.6, -6.4), Vector2(3.0, 1.1), Color("ff2a1a"), Vector3(0, -90, 0), 0.4)
	var led := _lbl(self, "SIRADAKİ: 1453", "NOW SERVING: 1453", Vector3(-3.09, 2.6, -6.4), 52, Color("ff4a3a"), Vector3(0, -90, 0), 2.4)
	var tw := led.create_tween().set_loops()
	tw.tween_property(led, "modulate:a", 0.3, 0.6)
	tw.tween_property(led, "modulate:a", 1.0, 0.6)
	_reg("bur_display", Vector3(0.4, 0.8, 2.6), Vector3(-3.15, 2.6, -6.4), "UI_BUR_LOOK", _rb_display)
	# kauçuk bitkisi
	Props.cyl(self, 0.18, 0.3, Vector3(-3.0, 0.15, -10.8), Color("8a4a2a"), Vector3.ZERO, 8, 0.22)
	Props.ball(self, 0.18, Vector3(-3.0, 0.52, -10.8), Color("2f6a34"), Vector3(1, 1.4, 0.4))
	Props.ball(self, 0.17, Vector3(-2.9, 0.85, -10.8), Color("3a7a3a"), Vector3(0.5, 1.4, 1))
	Props.ball(self, 0.16, Vector3(-3.1, 0.78, -10.7), Color("2a5a2e"), Vector3(1, 1.3, 0.5))
	# İtiraz kutusu (v0.99.104; uyuyan memurun yerine): ağzına kadar dolmuş, dilekçeler yarığından taşıp yere dökülmüş.
	# Salonun neden ilerlemediğini anlatır; Nihat rastgele bir dilekçe okur.
	var bx := Vector3(-8.15, 0.0, -10.3)
	var box_c := Color("5a6a62")
	Props.solid(self, Vector3(0.55, 1.15, 0.7), bx + Vector3(0, 0.575, 0), box_c)
	Props.box(self, Vector3(0.6, 0.05, 0.75), bx + Vector3(0, 1.175, 0), box_c.darkened(0.25))
	Props.box(self, Vector3(0.6, 0.06, 0.75), bx + Vector3(0, 0.03, 0), box_c.darkened(0.35))
	Props.box(self, Vector3(0.02, 0.05, 0.42), bx + Vector3(0.276, 1.0, 0), Color("1a1c1e"))      # yarık
	for k in 5:     # yarıktan taşan dilekçeler
		Props.box(self, Vector3(0.2, 0.005, 0.15), bx + Vector3(0.36, 1.0 + k * 0.012, -0.16 + k * 0.08), [C_PAPER, Color("e8d8a8"), C_PAPER, Color("dfe6ee"), C_PAPER][k], Vector3(0, k * 11.0 - 20.0, -18.0 - k * 4.0))
	for k in 6:     # kapakta yığılmış olanlar
		Props.box(self, Vector3(0.21, 0.006, 0.29), bx + Vector3(-0.05 + (k % 2) * 0.06, 1.205 + k * 0.007, -0.12 + (k % 3) * 0.1), [C_PAPER, Color("e8d8a8")][k % 2], Vector3(0, k * 23.0, 0))
	Props.box(self, Vector3(0.012, 0.24, 0.52), bx + Vector3(0.281, 0.72, 0), Color("efe6cc"))
	_lbl(self, "İTİRAZ KUTUSU", "APPEALS BOX", bx + Vector3(0.289, 0.77, 0), 22, Color("2a2622"), Vector3(0, 90, 0), 0.48)
	_lbl(self, "Boşaltma: yüzyılda bir", "Emptied: once a century", bx + Vector3(0.289, 0.67, 0), 14, Color("6a3a2a"), Vector3(0, 90, 0), 0.46)
	Props.box(self, Vector3(0.03, 0.08, 0.06), bx + Vector3(0.29, 0.4, 0), C_BRASS)               # asma kilit
	Props.ring(self, 0.018, 0.026, bx + Vector3(0.29, 0.46, 0), C_BRASS, Vector3(0, 0, 90))
	var rng_p := RandomNumberGenerator.new()
	rng_p.seed = 1923
	for k in 14:    # yere dökülenler
		var pp := bx + Vector3(rng_p.randf_range(0.38, 0.95), 0.003 + k * 0.0015, rng_p.randf_range(-0.6, 0.6))
		Props.box(self, Vector3(0.21, 0.003, 0.29), pp, [C_PAPER, Color("e8d8a8"), Color("dfe6ee")][k % 3], Vector3(0, rng_p.randf() * 360.0, 0))
	for k in 4:     # buruşturulmuş olanlar
		Props.ball(self, 0.045, bx + Vector3(rng_p.randf_range(0.45, 1.0), 0.04, rng_p.randf_range(-0.7, 0.7)), C_PAPER, Vector3(1, 0.85, 1), 6)
	_reg("bur_appeals", Vector3(0.9, 1.4, 1.0), bx + Vector3(0.35, 0.8, 0), "UI_BUR_LOOK", _rb_appeals)
	# hayaletler: oturanlar
	var blue_t := Color("a8d4ff")
	var green_t := Color("b4ffe0")
	var warm_t := Color("ffe4b8")
	# ayakta bekleyenler


## Başka çağlardan bekleyenler (yarı saydam hayaletlerdi; yer tutucu gibi duruyordu): Romalı senatör, lejyoner,
## yeniçeri, 1920'lerden bir memur, Bizanslı soylu, astronot. Koltuktakiler LED ekrana bakar.
const _RB_ERA := {
	"toga": {"coat": Color("efe9dc"), "pants": Color("efe9dc"), "robe": Color("efe9dc"), "hair": Color("9a9a90"), "hair_style": "receding", "skin": Color("e0a882")},
	"legion": {"coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hat": "helm", "armor": "mail", "skin": Color("d9a07a")},
	"bork": {"coat": Color("2f5f8a"), "pants": Color("e8e0c8"), "hat": "bork", "mustache": true, "skin": Color("d9a07a")},
	"fedora": {"coat": Color("5a5a62"), "pants": Color("3a3a42"), "hat": "fedora", "mustache": true, "skin": Color("ecc0a0")},
	"byz": {"coat": Color("5a2a6a"), "pants": Color("3a2a30"), "robe": Color("5a2a6a"), "hat": "skiadion", "beard": true, "skin": Color("e0b08a")},
	"astro": {"coat": Color("eceae4"), "pants": Color("eceae4"), "hat": "astro", "skin": Color("e8b894")},
}


func _rb_ghost(kind: String, pos: Vector3, sit: bool, yaw: float, _tint: Color, _phase: float) -> void:
	var p := Person.new(_RB_ERA[kind])
	p.set_meta("no_unclip", true)
	add_child(p)
	p.position = Vector3(pos.x, 0.0, pos.z)
	p.rotation_degrees.y = yaw
	if sit:
		p.set_activity("sit")
	var st: Array = [p]
	while st.size() > 0:
		var n: Node = st.pop_back()
		st.append_array(n.get_children())
		if n is GeometryInstance3D:
			(n as GeometryInstance3D).visibility_range_end = 24.0


func _rb_ticket() -> void:
	_say(_next("bur_ticket", ["BUR_TICKET", "BUR_TICKET_2", "BUR_TICKET_3"]))
	Audio.sfx("paper_tear", -10.0, 1.4)
	var n := 4582118 + _count("bur_ticket")
	var t := Node3D.new()
	t.position = Vector3(-2.5, 0.92, -4.6)
	t.rotation_degrees = Vector3(0, 0, 75)
	add_child(t)
	Props.box(t, Vector3(0.12, 0.004, 0.2), Vector3.ZERO, C_PAPER)
	Props.label(t, _rb_fmt(n), Vector3(0, 0.004, 0), 16, Color("222222"), Vector3(-90, 0, 0))
	var tw := t.create_tween().set_parallel(true)
	tw.tween_property(t, "position", Vector3(-2.15, 0.03, -4.85), 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(t, "rotation_degrees:z", 0.0, 1.0)
	tw.tween_property(t, "rotation_degrees:y", 40.0, 1.0)
	tw.chain().tween_interval(4.0)
	tw.chain().tween_callback(t.queue_free)
	var tw2 := t.create_tween()
	tw2.tween_property(t, "rotation_degrees:x", 20.0, 0.4)
	tw2.tween_property(t, "rotation_degrees:x", -15.0, 0.3)
	tw2.tween_property(t, "rotation_degrees:x", 0.0, 0.3)


func _rb_appeals() -> void:
	_say(_next("bur_appeals", ["BUR_APPEALS_1", "BUR_APPEALS_2", "BUR_APPEALS_3", "BUR_APPEALS_4"]), 5.5)
	Audio.sfx("newspaper", -14.0, 1.1)


func _rb_display() -> void:
	_say(_next("bur_display", ["BUR_DISPLAY", "BUR_DISPLAY_2"]))
	Audio.sfx("radio_beep", -12.0)


func _rb_ghost_talk() -> void:
	_say(_next("bur_ghost", ["BUR_GHOST", "BUR_GHOST_2", "BUR_GHOST_3"]))
	Audio.sfx("veil_hum", -14.0)


# ---------------------------------------------------------------- 3. KAYIP ZAMAN BÜROSU (x 2..9, z -17.9..-24.4)

func _rb_lost() -> void:
	var wall := Color("9a8f70")
	var cardboard := [Color("a9825a"), Color("b58d63"), Color("9a7650")]
	_floor(Vector2(7.0, 6.5), Vector3(5.5, 0, -21.15), Color("7a6e5a"), Color("6a5e4a"), 2.0)
	Props.solid(self, Vector3(7.2, 0.2, 6.9), Vector3(5.6, 3.5, -21.15), C_CEIL)
	_wall(Vector3(7.3, 3.4, 0.3), Vector3(5.65, 1.7, -17.75), wall)     # depo duvarıyla arasındaki boşluğu kapatır
	_wall(Vector3(7.3, 3.4, 0.2), Vector3(5.65, 1.7, -24.5), wall)
	_wall(Vector3(0.2, 3.4, 6.9), Vector3(9.1, 1.7, -21.15), wall)
	# iki çıplak ampul
	for p in [Vector3(4.6, 2.7, -19.6), Vector3(6.8, 2.7, -22.8)]:
		Props.box(self, Vector3(0.012, 0.7, 0.012), p + Vector3(0, 0.35, 0), Color("222222"))
		Props.ball(self, 0.06, p, Color("ffe0a8"), Vector3.ONE, 6, 3.0)
	_bulb(Vector3(5.7, 2.6, -21.2), Color("ffe0a8"), 1.4, 7.0)      # iki ampulün tek ışığı
	# asma tabela
	Props.box(self, Vector3(0.05, 0.45, 2.6), Vector3(2.55, 2.75, -21.5), Color("3a2a1a"))
	for cz: float in [-22.5, -20.5]:
		Props.cyl(self, 0.008, 0.45, Vector3(2.55, 3.19, cz), C_METAL, Vector3.ZERO, 4)
	_lbl(self, "KAYIP ZAMAN BÜROSU", "LOST TIME OFFICE", Vector3(2.52, 2.75, -21.5), 34, Color("f4e8c0"), Vector3(0, -90, 0), 2.4)
	# tezgâh (kuzey ucunda 1 m geçit) + zil
	Props.solid(self, Vector3(0.6, 1.0, 3.4), Vector3(2.6, 0.5, -21.7), C_WOOD)
	Props.box(self, Vector3(0.75, 0.05, 3.55), Vector3(2.6, 1.025, -21.7), C_WOOD_DARK)
	Props.cyl(self, 0.07, 0.02, Vector3(2.6, 1.07, -21.0), C_BRASS, Vector3.ZERO, 10)
	Props.ball(self, 0.06, Vector3(2.6, 1.1, -21.0), C_BRASS, Vector3(1, 0.8, 1), 8)
	_reg("bur_bell", Vector3(0.4, 0.4, 0.4), Vector3(2.6, 1.15, -21.0), "UI_BUR_RING", _rb_bell, self, false)
	# memur Sabri + gazete
	_rb_sabri_p = Person.new({"coat": Color("6a5a3a"), "pants": Color("3a3a40"), "hair": Color("3a3a3a"),
		"glasses": true, "hat": "none"})
	_rb_sabri_p.set_meta("spk", "SPK_SABRI")
	_rb_sabri_p.set_meta("no_talk", true)
	_rb_sabri_p.set_meta("no_chat", true)       # yandaki Kolomb'la sessiz sohbete dönüp gazeteyi arkada bırakıyordu
	_rb_sabri_p.position = Vector3(3.8, 0, -21.2)
	_rb_sabri_p.rotation_degrees.y = -90
	add_child(_rb_sabri_p)
	_rb_sabri_p.set_activity("hold_paper")
	# Gazete Sabri'nin elinde (ona bağlı): yüzünün önünde, ön yüzü tezgâha (oyuncuya) bakar
	_rb_paper = Props.box(_rb_sabri_p, Vector3(0.03, 0.5, 0.4), Vector3(0, 1.42, 0.36), Color("d8d0b8"), Vector3(0, 90, 0))
	# Gazetenin tezgâha bakan yüzü: başlık, manşet, sütunlar (yakından boş kâğıt kutusu gibi duruyordu)
	Props.box(_rb_paper, Vector3(0.004, 0.07, 0.37), Vector3(-0.017, 0.19, 0.0), Color("2a2622"))
	_lbl(_rb_paper, "ZAMAN POSTASI", "THE TIME POST", Vector3(-0.021, 0.19, 0.0), 9, Color("f0e8d0"), Vector3(0, -90, 0))
	_lbl(_rb_paper, "YARIN ERTELENDİ", "TOMORROW POSTPONED", Vector3(-0.019, 0.105, 0.0), 8, Color("1a1a1a"), Vector3(0, -90, 0))
	Props.box(_rb_paper, Vector3(0.003, 0.12, 0.15), Vector3(-0.0165, -0.02, 0.09), Color("8a8478"))
	for cz: float in [-0.13, -0.03]:
		for ry: float in [0.02, -0.04, -0.1, -0.16]:
			Props.box(_rb_paper, Vector3(0.003, 0.012, 0.08), Vector3(-0.0165, ry, cz), Color("6a665e"))
	for ry2: float in [-0.12, -0.18]:
		Props.box(_rb_paper, Vector3(0.003, 0.012, 0.15), Vector3(-0.0165, ry2, 0.09), Color("6a665e"))
	# çelik raflar + etiketli koliler (arka duvar)
	var steel := Color("7f8a8c")
	var tags := {"0_1_0": "Yıl: 1071", "1_0_1": "Yıl: 1299", "1_2_0": "Yıl: 1920", "2_1_0": "Yıl: 2031"}
	var zcs := [-19.1, -21.2, -23.3]
	for u in 3:
		var zc: float = zcs[u]
		Props.box(self, Vector3(0.45, 2.0, 0.04), Vector3(8.775, 1.0, zc - 0.98), steel)
		Props.box(self, Vector3(0.45, 2.0, 0.04), Vector3(8.775, 1.0, zc + 0.98), steel)
		for l in 3:
			var by := 0.4 + 0.6 * l
			Props.box(self, Vector3(0.45, 0.04, 2.0), Vector3(8.775, by, zc), steel)
			var cnt := 1 if l == 2 else 2
			for j in cnt:
				var h := 0.26 + 0.03 * ((u * 7 + l * 3 + j * 5) % 4)
				var bz := zc - 0.5 + 0.9 * j
				Props.box(self, Vector3(0.38, h, 0.5), Vector3(8.77, by + 0.02 + h * 0.5, bz), cardboard[(u + l + j) % 3])
				var key := "%d_%d_%d" % [u, l, j]
				if tags.has(key):
					Props.label(self, tags[key], Vector3(8.575, by + 0.02 + h * 0.5, bz), 18, Color("2a1a0a"), Vector3(0, -90, 0), 0.45)
	_reg("bur_lostshelf", Vector3(0.8, 2.2, 6.0), Vector3(8.6, 1.1, -21.15), "UI_BUR_LOOK", _rb_lostshelf)
	# Nokia 3310 cam fanus altında
	var np := Vector3(6.2, 1.0, -21.8)
	Props.box(self, Vector3(0.6, 1.0, 0.6), Vector3(6.2, 0.5, -21.8), Color("c8c4b8"))
	Props.box(self, Vector3(0.05, 0.16, 0.08), np + Vector3(0, 0.1, 0), Color("5a6870"))
	Props.box(self, Vector3(0.012, 0.05, 0.06), np + Vector3(-0.03, 0.14, 0), Color("8fd05a"), Vector3.ZERO, 1.5)
	Props.box(self, Vector3(0.012, 0.06, 0.06), np + Vector3(-0.03, 0.06, 0), Color("3a4650"))
	var dome := Props.ball(self, 0.22, np + Vector3(0, 0.12, 0), Color.WHITE, Vector3(1, 1.1, 1), 12)
	_rb_t(dome, _rb_mat(Color("dff4ff"), 0.22, 0.0))
	Props.strip_outlines(dome)
	Props.label(self, "1453 · Topkapı önü", Vector3(5.88, 0.72, -21.8), 24, Color("222222"), Vector3(0, -90, 0), 0.55)
	_reg("bur_nokia", Vector3(0.6, 0.6, 0.6), np + Vector3(0, 0.1, 0), "UI_BUR_LOOK", _rb_nokia)
	# Roma sandaleti + beyaz spor çorabı
	Props.box(self, Vector3(0.7, 0.5, 0.5), Vector3(3.3, 0.25, -23.8), C_WOOD)
	Props.box(self, Vector3(0.32, 0.03, 0.12), Vector3(3.3, 0.515, -23.8), Color("8a6a40"), Vector3(0, 90, 0))
	Props.box(self, Vector3(0.03, 0.05, 0.14), Vector3(3.26, 0.55, -23.8), Color("6a4a2a"))
	Props.box(self, Vector3(0.03, 0.05, 0.14), Vector3(3.34, 0.55, -23.8), Color("6a4a2a"))
	Props.box(self, Vector3(0.1, 0.1, 0.12), Vector3(3.37, 0.58, -23.8), Color("f4f4f0"))
	Props.label(self, "MS 79", Vector3(2.94, 0.3, -23.8), 28, Color("f0e8d0"), Vector3(0, -90, 0), 0.5)
	_reg("bur_sandal", Vector3(0.6, 0.6, 0.6), Vector3(3.3, 0.7, -23.8), "UI_BUR_LOOK", _rb_sandal)
	# tavuk kafesi (tel = ince kutular), masa üstünde
	var wire := Color("5a5f62")
	Props.box(self, Vector3(0.9, 0.5, 0.6), Vector3(7.6, 0.25, -18.5), C_WOOD_DARK)
	Props.box(self, Vector3(0.7, 0.04, 0.5), Vector3(7.6, 0.52, -18.5), C_WOOD)
	for cx in [-0.34, 0.34]:
		for cz in [-0.24, 0.24]:
			Props.box(self, Vector3(0.02, 0.45, 0.02), Vector3(7.6 + cx, 0.77, -18.5 + cz), wire)
	Props.box(self, Vector3(0.7, 0.02, 0.5), Vector3(7.6, 1.0, -18.5), wire)
	Props.box(self, Vector3(0.7, 0.015, 0.015), Vector3(7.6, 0.75, -18.26), wire)
	Props.box(self, Vector3(0.7, 0.015, 0.015), Vector3(7.6, 0.75, -18.74), wire)
	Props.ball(self, 0.1, Vector3(7.6, 0.66, -18.5), Color("f0d040"), Vector3(1, 0.9, 1.2), 8)
	Props.ball(self, 0.05, Vector3(7.5, 0.78, -18.5), Color("f4f0e0"), Vector3.ONE, 6)
	Props.label(self, "No. 1204", Vector3(7.14, 0.3, -18.5), 26, Color("f0e8d0"), Vector3(0, -90, 0), 0.6)
	# selfie çubuğu (duvara yaslı)
	Props.cyl(self, 0.012, 1.1, Vector3(8.3, 0.58, -18.25), Color("222222"), Vector3(15, 0, 0), 6)
	Props.box(self, Vector3(0.05, 0.1, 0.012), Vector3(8.3, 1.16, -18.1), Color("3a3a40"), Vector3(15, 0, 0))
	Props.label(self, "Otağ-ı Hümayun", Vector3(8.3, 1.55, -18.0), 22, Color("f0e8d0"), Vector3(0, 180, 0), 0.8)
	# şemsiye
	Props.cyl(self, 0.12, 0.4, Vector3(5.0, 0.2, -18.3), Color("4a4a4a"), Vector3.ZERO, 8)
	Props.cyl(self, 0.012, 1.0, Vector3(5.0, 0.7, -18.3), Color("1a1a1a"), Vector3.ZERO, 6)
	Props.cyl(self, 0.045, 0.45, Vector3(5.0, 1.25, -18.3), Color("2a2a3a"), Vector3.ZERO, 8, 0.008)
	Props.label(self, "Hiçbir yıl", Vector3(5.0, 1.75, -18.0), 24, Color("f0e8d0"), Vector3(0, 180, 0), 0.7)


func _rb_bell() -> void:
	Audio.sfx("typewriter_bell", -4.0)
	_say(_next("bur_bell", ["BUR_BELL", "BUR_BELL_2"]), 4.0, "SPK_SABRI")
	_rb_talk(_rb_sabri_p, 3.5)
	if is_instance_valid(_rb_paper) and not _rb_paper_busy:
		_rb_paper_busy = true
		_rb_paper_busy = false      # gazete Sabri konuşurken kendiliğinden iner (_process)


func _rb_nokia() -> void:
	_say(_next("bur_nokia", ["BUR_NOKIA", "BUR_NOKIA_2"]))
	Audio.sfx("radio_beep", -10.0, 0.8)
	if _count("bur_nokia") == 2:
		_second(2, Vector3(6.2, 1.3, -21.8))


func _rb_sandal() -> void:
	_say(_next("bur_sandal", ["BUR_SANDAL", "BUR_SANDAL_2"]))
	Audio.sfx("cloth", -10.0)


func _rb_lostshelf() -> void:
	_say(_next("bur_lostshelf", ["BUR_LOSTSHELF", "BUR_LOSTSHELF_2", "BUR_LOSTSHELF_3", "BUR_LOSTSHELF_4"]))
	Audio.sfx("paper_tear", -14.0, 0.8)


## ---- bur_rooms_c: Arşiv, Paradoks Şikâyet Masası, Müdür Kapısı, Yönetmelik Duvarı, Atrium, koridor sonu penceresi ----
## Giriş noktası: _rc_build()  (bureau.gd içinde _build_rooms() çağırır)

var _rc_hatice: Person
var _rc_hatice_rig: Node3D            # merdiven + Hatice birlikte raydan kayar
var _rc_nuran: Person
var _rc_paper: MeshInstance3D          # tezgâhtan kayan kâğıt
var _rc_paper_tw: Tween
var _rc_arch_drawer: Node3D
var _rc_arch_open := false
var _rc_drawer_mat: StandardMaterial3D
var _rc_dir_glow: MeshInstance3D       # müdür kapısının altından sızan ışık
var _rc_dir_tw: Tween
var _rc_dir_bright := false
var _rc_win_mat: ShaderMaterial        # atrium büyük penceresi
var _rc_win_tw: Tween
var _rc_pend: Node3D


func _rc_build() -> void:
	_rc_archive()
	_rc_complaint()
	_rc_director()
	_rc_regwall()
	_rc_atrium()
	_rc_end_window()
	if not seconds_changed.is_connected(_rc_on_seconds):
		seconds_changed.connect(_rc_on_seconds)
	if seconds_found() >= 5:
		_rc_on_seconds(5, true)


# ---------------------------------------------------------------- ortak yardımcılar

## Pencere shader'ı kaplı dörtgen. +Z yüzü odaya bakacak şekilde rot verilir.
func _rc_window_quad(parent: Node3D, size: Vector2, pos: Vector3, rot: Vector3, view_ref: float) -> ShaderMaterial:
	var sh = load("res://assets/shaders/time_window.gdshader")
	if sh == null:
		return null
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("quad_size", size)
	m.set_shader_parameter("view_ref", view_ref)
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return m


## Çekmece dokulu malzeme: tek kutu üzerinde dolap çekmeceleri (üçgen-düzlemsel, 0,9 x 0,8 m'lik tekrar)
func _rc_dmat() -> StandardMaterial3D:
	if _rc_drawer_mat:
		return _rc_drawer_mat
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color("2b3633"))
	for r in 2:
		var y0 := r * 32
		img.fill_rect(Rect2i(2, y0 + 2, 60, 28), Color("55655f"))
		img.fill_rect(Rect2i(22, y0 + 6, 20, 8), Color("e4dcc4"))
		img.fill_rect(Rect2i(25, y0 + 9, 14, 1), Color("6a6a60"))
		img.fill_rect(Rect2i(20, y0 + 21, 24, 3), Color("c49a45"))
	img.generate_mipmaps()
	var m := StandardMaterial3D.new()
	m.albedo_texture = ImageTexture.create_from_image(img)
	m.uv1_triplanar = true
	m.uv1_scale = Vector3(1.0 / 0.9, 1.0 / 0.8, 1.0 / 0.9)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	m.roughness = 0.8
	_rc_drawer_mat = m
	return m


func _rc_cab(size: Vector3, pos: Vector3) -> void:
	var b := Props.solid(self, size, pos, Color("4a5854"))
	(b.get_child(0) as MeshInstance3D).material_override = _rc_dmat()


## id için "KEY", "KEY_2", ... n varyantı sırayla söyler (nesne replikleri: Nihat)
func _rc_look(id: String, key: String, n: int) -> void:
	var keys: Array = [key]
	for i in range(2, n + 1):
		keys.append("%s_%d" % [key, i])
	_say(_next(id, keys))


func _rc_talk_pulse(p: Person) -> void:
	if not is_instance_valid(p):
		return
	p.talking = true
	get_tree().create_timer(3.0).timeout.connect(_rc_untalk.bind(p))


func _rc_untalk(p: Person) -> void:
	if is_instance_valid(p):
		p.talking = false


# ---------------------------------------------------------------- ARŞİV (batı, x -11..-2, z -13..-24)

func _rc_archive() -> void:
	var wc := Color("6d7d78")
	var low := Color("4e5c58")
	_floor(Vector2(9.0, 11.0), Vector3(-6.5, 0, -18.5), Color("2c3338"), Color("262c31"), 0.8)
	Props.solid(self, Vector3(9.2, 0.2, 11.2), Vector3(-6.6, COR_H + 0.1, -18.5), Color("3b4743"))
	_wall(Vector3(9.0, COR_H, 0.2), Vector3(-6.7, COR_H / 2, -12.9), wc)
	_wall(Vector3(9.0, COR_H, 0.2), Vector3(-6.7, COR_H / 2, -24.1), wc)
	_wall(Vector3(0.2, COR_H, 11.2), Vector3(-11.1, COR_H / 2, -18.5), wc)
	Props.box(self, Vector3(8.8, 0.9, 0.04), Vector3(-6.6, 0.45, -13.02), low)
	Props.box(self, Vector3(8.8, 0.9, 0.04), Vector3(-6.6, 0.45, -23.98), low)
	Props.box(self, Vector3(0.04, 0.9, 10.8), Vector3(-10.98, 0.45, -18.5), low)
	# soğuk, loş ışık
	_bulb(Vector3(-6.5, 3.0, -18.0), Color("cfe7ff"), 1.1, 9.5)
	Props.box(self, Vector3(0.12, 0.05, 1.6), Vector3(-6.5, 3.35, -18.0), Color("dff0ff"), Vector3.ZERO, 1.6)
	# çıkış kapısı + kırmızı tabela (arka duvar)
	Props.box(self, Vector3(0.06, 2.2, 1.1), Vector3(-10.96, 1.1, -18.5), Color("1b2220"))
	Props.box(self, Vector3(0.05, 0.3, 1.1), Vector3(-10.94, 2.6, -18.5), Color("8a1410"), Vector3.ZERO, 1.4)
	_lbl(self, "ÇIKIŞ / EXIT", "ÇIKIŞ / EXIT", Vector3(-10.9, 2.6, -18.5), 26, Color("ffd8d0"), Vector3(0, 90, 0), 1.0)
	_glow(self, Vector3(-10.85, 2.6, -18.5), Vector2(2.4, 1.2), Color("ff2a1a"), Vector3(0, 90, 0), 0.5)
	# çekmece duvarları
	_rc_cab(Vector3(0.6, 2.9, 9.2), Vector3(-7.1, 1.45, -18.8))       # merdiven duvarı (doğuya bakar)
	_rc_cab(Vector3(0.6, 2.9, 3.2), Vector3(-8.5, 1.45, -15.6))
	_rc_cab(Vector3(0.6, 2.9, 4.3), Vector3(-10.7, 1.45, -15.75))     # arka duvar boyunca (kapının iki yanı)
	_rc_cab(Vector3(0.6, 2.9, 4.3), Vector3(-10.7, 1.45, -21.25))
	_rc_cab(Vector3(2.8, 2.9, 0.6), Vector3(-9.0, 1.45, -23.7))
	_rc_cab(Vector3(2.8, 2.9, 0.6), Vector3(-9.0, 1.45, -13.3))
	# yarı açık iki çekmece (yakın sıra)
	Props.box(self, Vector3(0.4, 0.32, 0.68), Vector3(-6.6, 0.5, -20.2), Color("62736d"))
	Props.box(self, Vector3(0.04, 0.05, 0.2), Vector3(-6.38, 0.55, -20.2), C_BRASS)
	Props.box(self, Vector3(0.3, 0.32, 0.68), Vector3(-6.65, 0.9, -17.4), Color("62736d"))
	Props.box(self, Vector3(0.04, 0.05, 0.2), Vector3(-6.48, 0.95, -17.4), C_BRASS)
	# raylar
	Props.box(self, Vector3(0.05, 0.05, 9.2), Vector3(-6.78, 2.75, -18.8), C_BRASS)
	Props.box(self, Vector3(0.05, 0.03, 9.0), Vector3(-6.1, 0.015, -18.8), C_METAL)
	# kayar merdiven + Hatice
	var rig := Node3D.new()
	rig.position = Vector3(-6.1, 0, -16.0)
	add_child(rig)
	_rc_hatice_rig = rig
	for s: float in [-0.33, 0.33]:
		Props.box(rig, Vector3(0.05, 2.7, 0.05), Vector3(-0.14, 1.35, s), C_WOOD_DARK, Vector3(0, 0, 6))
	for k in 5:
		var ry := 0.4 + k * 0.5
		Props.box(rig, Vector3(0.04, 0.04, 0.7), Vector3(-ry * 0.105, ry, 0), C_WOOD)
	Props.box(rig, Vector3(0.5, 0.05, 0.7), Vector3(-0.134, 1.275, 0), C_WOOD)
	Props.box(rig, Vector3(0.4, 0.04, 0.06), Vector3(-0.45, 2.72, 0), C_BRASS)
	_rc_hatice = Person.new({"coat": Color("7a5a6a"), "pants": Color("3a2a30"), "hair": Color("6a5a50"), "hat": "bun", "glasses": true, "skirt": true, "skin": Color("e8b894")})
	_rc_hatice.set_meta("spk", "SPK_HATICE")
	_rc_hatice.set_meta("no_talk", true)
	rig.add_child(_rc_hatice)
	_rc_hatice.position = Vector3(-0.13, 1.3, 0)
	_rc_hatice.rotation_degrees.y = -90
	_reg("bur_hatice", Vector3(0.9, 2.0, 0.9), Vector3(-0.13, 2.2, 0), "UI_BUR_TALK", _rc_hatice_talk, rig, false)
	if not GameState.autotest:
		var tw := rig.create_tween().set_loops()
		tw.tween_interval(6.0)
		tw.tween_property(rig, "position:z", -22.0, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_interval(6.0)
		tw.tween_property(rig, "position:z", -16.0, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# kırmızı bantlı dosya, kürsüde
	var lp := Vector3(-9.3, 0.0, -19.8)
	Props.box(self, Vector3(0.32, 1.2, 0.32), Vector3(lp.x, 0.6, lp.z), C_WOOD_DARK)
	Props.box(self, Vector3(0.62, 0.06, 0.52), Vector3(lp.x, 1.23, lp.z), C_WOOD)
	Props.box(self, Vector3(0.3, 0.04, 0.22), Vector3(lp.x, 1.28, lp.z), Color("d9c9a0"))
	Props.box(self, Vector3(0.05, 0.045, 0.23), Vector3(lp.x - 0.05, 1.28, lp.z), Color("c0262d"))
	Props.label(self, "1453-T", Vector3(lp.x + 0.06, 1.312, lp.z), 14, Color("3a2a20"), Vector3(-90, 0, 0), 0.12)
	_reg("bur_tolga_file", Vector3(0.8, 0.5, 0.7), Vector3(lp.x, 1.3, lp.z), "UI_BUR_LOOK", _rc_tolga)
	# arşivin arşivi: çekmecenin içinde çekmece
	var d := Node3D.new()
	d.position = Vector3(-10.38, 1.1, -21.3)
	add_child(d)
	_rc_arch_drawer = d
	Props.box(d, Vector3(0.04, 0.34, 0.74), Vector3(0.02, 0, 0), Color("62736d"))
	Props.box(d, Vector3(0.04, 0.05, 0.22), Vector3(0.06, 0.04, 0), C_BRASS)
	Props.box(d, Vector3(0.5, 0.03, 0.68), Vector3(-0.27, -0.155, 0), Color("3c4a46"))
	Props.box(d, Vector3(0.5, 0.14, 0.02), Vector3(-0.27, -0.08, 0.34), Color("3c4a46"))
	Props.box(d, Vector3(0.5, 0.14, 0.02), Vector3(-0.27, -0.08, -0.34), Color("3c4a46"))
	Props.box(d, Vector3(0.02, 0.1, 0.26), Vector3(-0.12, -0.09, 0), Color("7a8a84"))
	Props.box(d, Vector3(0.18, 0.08, 0.24), Vector3(-0.22, -0.1, 0), Color("5a6a64"))
	Props.box(d, Vector3(0.02, 0.03, 0.08), Vector3(-0.1, -0.07, 0), C_BRASS)
	_reg("bur_archdrawer", Vector3(0.8, 0.6, 0.9), Vector3(-10.2, 1.1, -21.3), "UI_BUR_PULL", _rc_archdrawer)


func _rc_hatice_talk() -> void:
	_say(_next("bur_hatice", ["BUR_HATICE", "BUR_HATICE_2"]), 4.2, "SPK_HATICE")
	_rc_talk_pulse(_rc_hatice)


func _rc_tolga() -> void:
	_say(_next("bur_tolga_file", ["BUR_TOLGA_FILE", "BUR_TOLGA_FILE_2"]))
	Audio.sfx("newspaper", -14.0, 1.2)
	if _count("bur_tolga_file") >= 2:
		_second(3, Vector3(-9.3, 1.5, -19.8))


func _rc_archdrawer() -> void:
	_say(_next("bur_archdrawer", ["BUR_ARCHDRAWER", "BUR_ARCHDRAWER_2"]))
	_rc_arch_open = not _rc_arch_open
	Audio.sfx("wood_creak", -16.0, 1.3)
	if not is_instance_valid(_rc_arch_drawer):
		return
	var tw := create_tween()
	tw.tween_property(_rc_arch_drawer, "position:x", -10.38 + (0.42 if _rc_arch_open else 0.0), 0.05 if GameState.autotest else 0.7).set_trans(Tween.TRANS_SINE)


# ---------------------------------------------------------------- PARADOKS ŞİKÂYET MASASI (batı niş, x -4.2..-2, z -27.3..-31.2)

func _rc_complaint() -> void:
	var wc := Color("c9b98a")
	_floor(Vector2(2.2, 3.9), Vector3(-3.1, 0, -29.25), Color("7a6a4a"), Color("6c5d40"), 0.8)
	Props.solid(self, Vector3(2.4, 0.2, 4.1), Vector3(-3.1, COR_H + 0.1, -29.25), Color("b8b6a4"))
	_wall(Vector3(0.2, COR_H, 4.1), Vector3(-4.3, COR_H / 2, -29.25), wc)
	_wall(Vector3(2.2, COR_H, 0.2), Vector3(-3.1, COR_H / 2, -27.2), wc)
	_wall(Vector3(2.2, COR_H, 0.2), Vector3(-3.1, COR_H / 2, -31.3), wc)
	Props.box(self, Vector3(0.04, 1.0, 3.9), Vector3(-4.18, 0.5, -29.25), C_COR_LOW)
	_bulb(Vector3(-3.2, 3.0, -29.25), Color("ffe2b0"), 0.9, 4.5)
	# tabela
	Props.box(self, Vector3(0.05, 0.55, 2.6), Vector3(-4.16, 2.35, -29.25), C_WALNUT)
	_lbl(self, "PARADOKS ŞİKAYET MASASI", "PARADOX COMPLAINTS DESK", Vector3(-4.12, 2.35, -29.25), 26, Color("e8d8a8"), Vector3(0, 90, 0), 2.4)
	# tezgâh
	Props.set_pattern(Props.solid(self, Vector3(0.55, 1.05, 3.1), Vector3(-2.75, 0.525, -29.25), C_WOOD), C_WOOD, "wood")
	Props.box(self, Vector3(0.7, 0.06, 3.3), Vector3(-2.72, 1.08, -29.25), C_WOOD_DARK)
	Props.box(self, Vector3(0.3, 0.2, 0.22), Vector3(-2.75, 1.24, -28.15), C_PAPER, Vector3(0, 6, 0))
	Props.box(self, Vector3(0.28, 0.12, 0.2), Vector3(-2.7, 1.2, -28.6), Color("e2dcc8"), Vector3(0, -9, 0))
	# büyük kırmızı düğme
	Props.cyl(self, 0.2, 0.05, Vector3(-2.72, 1.135, -29.3), Color("2a2a2e"), Vector3.ZERO, 14)
	Props.cyl(self, 0.15, 0.07, Vector3(-2.72, 1.195, -29.3), Color("d02a22"), Vector3.ZERO, 14, 0.14, 1.0)
	Props.box(self, Vector3(0.02, 0.22, 1.1), Vector3(-2.465, 0.75, -29.3), C_BRASS)
	_lbl(self, "ŞİKAYET ET", "COMPLAIN", Vector3(-2.45, 0.75, -29.3), 22, Color("2a1c0c"), Vector3(0, 90, 0), 1.0)
	# kâğıt şişi
	Props.cyl(self, 0.008, 0.32, Vector3(-2.7, 1.27, -30.5), C_METAL, Vector3.ZERO, 6)
	Props.box(self, Vector3(0.18, 0.006, 0.24), Vector3(-2.7, 1.18, -30.5), C_PAPER, Vector3(0, 20, 0))
	Props.box(self, Vector3(0.18, 0.006, 0.24), Vector3(-2.7, 1.22, -30.5), Color("e2dcc8"), Vector3(0, -15, 0))
	# tezgâhın içinde bekleyen kâğıt (basınca dışarı kayar)
	_rc_paper = Props.box(self, Vector3(0.38, 0.008, 0.28), Vector3(-2.85, 0.8, -29.7), Color("f4efe0"))
	# Nuran
	_rc_nuran = Person.new({"coat": Color("8a3a4a"), "pants": Color("3a2a30"), "hair": Color("1f1a1a"), "skirt": true, "skin": Color("d8a888")})
	_rc_nuran.set_meta("spk", "SPK_NURAN")
	_rc_nuran.set_meta("no_talk", true)
	add_child(_rc_nuran)
	_rc_nuran.position = Vector3(-3.3, 0, -29.3)
	_rc_nuran.rotation_degrees.y = 90
	_reg("bur_paradoks", Vector3(1.4, 1.9, 3.0), Vector3(-3.0, 0.95, -29.25), "UI_BUR_PRESS", _rc_paradoks, null, false)
	if not GameState.autotest:
		var t := Timer.new()
		t.wait_time = 6.0
		t.autostart = true
		t.timeout.connect(_rc_nuran_stamp)
		add_child(t)


func _rc_nuran_stamp() -> void:
	if is_instance_valid(_rc_nuran) and is_visible_in_tree():
		_rc_nuran.stamp()
		Audio.sfx_at("stamp", _rc_nuran, -22.0)


func _rc_paradoks() -> void:
	_say(_next("bur_paradoks", ["BUR_PARADOKS", "BUR_PARADOKS_2", "BUR_PARADOKS_3"]), 4.4, "SPK_NURAN")
	if is_instance_valid(_rc_nuran):
		_rc_nuran.stamp()
		_rc_talk_pulse(_rc_nuran)
	Audio.sfx("stamp", -8.0)
	if is_instance_valid(_rc_paper):
		if _rc_paper_tw and _rc_paper_tw.is_valid():
			_rc_paper_tw.kill()
		_rc_paper.position.x = -2.85
		var fast := GameState.autotest
		_rc_paper_tw = create_tween()
		_rc_paper_tw.tween_property(_rc_paper, "position:x", -2.3, 0.05 if fast else 0.45).set_trans(Tween.TRANS_SINE)
		_rc_paper_tw.tween_interval(0.05 if fast else 3.0)
		_rc_paper_tw.tween_property(_rc_paper, "position:x", -2.85, 0.05 if fast else 0.5)


# ---------------------------------------------------------------- MÜDÜR KAPISI (doğu niş, x 2..2.4, z -29.2..-31.2)

func _rc_director() -> void:
	_wall(Vector3(0.2, COR_H, 2.6), Vector3(2.5, COR_H / 2, -30.2), C_COR_WALL)
	_wall(Vector3(0.2, COR_H, 0.2), Vector3(2.3, COR_H / 2, -29.1), C_COR_WALL)
	_wall(Vector3(0.2, COR_H, 0.2), Vector3(2.3, COR_H / 2, -31.3), C_COR_WALL)
	Props.solid(self, Vector3(0.6, 0.2, 2.6), Vector3(2.3, COR_H + 0.1, -30.2), Color("b8b6a4"))
	_floor(Vector2(0.5, 2.2), Vector3(2.25, 0, -30.2), Color("2a1e18"), Color("22170f"), 1.0)
	# çift kanatlı ceviz kapı (-x'e bakar)
	for s: float in [-0.46, 0.46]:
		Props.box(self, Vector3(0.06, 2.6, 0.88), Vector3(2.37, 1.3, -30.2 + s), C_WALNUT)
		Props.box(self, Vector3(0.02, 0.95, 0.6), Vector3(2.33, 0.75, -30.2 + s), Color("4a2d1e"))
		Props.box(self, Vector3(0.02, 0.95, 0.6), Vector3(2.33, 1.95, -30.2 + s), Color("4a2d1e"))
		Props.box(self, Vector3(0.03, 0.3, 0.03), Vector3(2.315, 1.1, -30.2 + s * 0.15), C_BRASS)
	Props.box(self, Vector3(0.08, 2.7, 0.1), Vector3(2.36, 1.35, -29.25), Color("231409"))
	Props.box(self, Vector3(0.08, 2.7, 0.1), Vector3(2.36, 1.35, -31.15), Color("231409"))
	Props.box(self, Vector3(0.1, 0.12, 2.0), Vector3(2.36, 2.66, -30.2), Color("231409"))
	Props.box(self, Vector3(0.015, 0.16, 0.7), Vector3(2.31, 1.65, -30.2), C_BRASS)
	_lbl(self, "MÜDÜR", "DIRECTOR", Vector3(2.3, 1.65, -30.2), 24, Color("2a1c0c"), Vector3(0, -90, 0), 0.6)
	# kırmızı halı şeridi (koridor ortası x -0.6..0.6 boş kalır)
	Props.box(self, Vector3(1.45, 0.012, 3.7), Vector3(1.34, 0.006, -30.2), C_RUG_EDGE)
	Props.box(self, Vector3(1.35, 0.016, 3.55), Vector3(1.34, 0.008, -30.2), Color("8a1c24"))
	# pirinç direkler + kadife kordon
	for pz: float in [-28.6, -31.8]:
		Props.cyl(self, 0.12, 0.03, Vector3(1.1, 0.015, pz), C_BRASS, Vector3.ZERO, 10)
		Props.cyl(self, 0.03, 0.95, Vector3(1.1, 0.5, pz), C_BRASS, Vector3.ZERO, 8)
		Props.ball(self, 0.05, Vector3(1.1, 1.0, pz), C_BRASS, Vector3.ONE, 8)
	Props.cyl(self, 0.02, 3.2, Vector3(1.1, 0.85, -30.2), Color("a01c28"), Vector3(90, 0, 0), 6)
	# kapının altından sızan ışık
	Props.box(self, Vector3(0.04, 0.02, 1.8), Vector3(2.31, 0.012, -30.2), Color("bff8ff"), Vector3.ZERO, 3.0)
	_rc_dir_glow = _glow(self, Vector3(1.4, 0.03, -30.2), Vector2(2.6, 3.4), Color("8ff0ff"), Vector3(-90, 0, 0), 0.45)
	_rc_dir_pulse()
	_reg("bur_director", Vector3(0.8, 2.6, 2.0), Vector3(2.2, 1.3, -30.2), "UI_BUR_KNOCK", _rc_director_knock)


func _rc_dir_pulse() -> void:
	if not is_instance_valid(_rc_dir_glow):
		return
	if _rc_dir_tw and _rc_dir_tw.is_valid():
		_rc_dir_tw.kill()
	var m := _rc_dir_glow.material_override as StandardMaterial3D
	var base := Color(0.56, 0.94, 1.0)
	var lo := 0.55 if _rc_dir_bright else 0.18
	var hi := 1.0 if _rc_dir_bright else 0.5
	var c_lo := Color(base.r * lo, base.g * lo, base.b * lo, 1.0)
	var c_hi := Color(base.r * hi, base.g * hi, base.b * hi, 1.0)
	m.albedo_color = c_lo
	_rc_dir_tw = _rc_dir_glow.create_tween().set_loops()
	_rc_dir_tw.tween_property(m, "albedo_color", c_hi, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_rc_dir_tw.tween_property(m, "albedo_color", c_lo, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Beşinci kayıp saniye bulununca kapının altındaki ışık kalıcı olarak parlar
func _rc_on_seconds(n: int, silent := false) -> void:
	if n >= 5 and not _rc_dir_bright:
		_rc_dir_bright = true
		_rc_dir_pulse()
		if not silent:
			Audio.sfx("veil_hum", -8.0)


func _rc_director_knock() -> void:
	Audio.sfx("kick_metal", -18.0, 0.8)
	if seconds_found() >= 5:
		_say("BUR_DIRECTOR_3")
	else:
		_say(_next("bur_director", ["BUR_DIRECTOR", "BUR_DIRECTOR_2"]))


# ---------------------------------------------------------------- YÖNETMELİK DUVARI (doğu koridor duvarı, z -32..-36)

func _rc_regwall() -> void:
	Props.box(self, Vector3(0.03, 1.8, 4.1), Vector3(1.985, 1.6, -34.0), C_WALNUT)
	var titles := [["Madde 1", "Art. 1"], ["Madde 14/b", "Art. 14/b"], ["Madde 27", "Art. 27"], ["Ek Madde 3", "Add. Art. 3"],
		["Madde 61/c", "Art. 61/c"], ["Geçici Madde 2", "Prov. Art. 2"], ["Madde 8", "Art. 8"], ["Madde 112", "Art. 112"],
		["Madde 5/a", "Art. 5/a"], ["Madde 77", "Art. 77"], ["Madde 0", "Art. 0"], ["Madde 31 Şubat", "Art. 31 Feb"]]
	for i in 12:
		var row := floori(i / 4.0)
		var col := i % 4
		var z := -32.5 - col * 1.0
		var y := 2.1 - row * 0.5
		Props.box(self, Vector3(0.02, 0.36, 0.7), Vector3(1.96, y, z), C_BRASS if (i + row) % 2 == 0 else Color("a88438"))
		_lbl(self, titles[i][0], titles[i][1], Vector3(1.945, y, z), 14, Color("2a1c0c"), Vector3(0, -90, 0), 0.6)
	_lbl(self, "YÖNETMELİK", "REGULATIONS", Vector3(1.94, 2.75, -34.0), 40, Color("e8d8a8"), Vector3(0, -90, 0), 2.4)
	_reg("bur_regwall", Vector3(0.5, 2.0, 4.2), Vector3(1.75, 1.7, -34.0), "UI_BUR_LOOK", _rc_look.bind("bur_regwall", "BUR_REGWALL", 2))


# ---------------------------------------------------------------- ATRIUM (doğu, x 2..16, z -36.5..-55.5, tavan 7,5)

func _rc_gear(centre: Vector3, r: float, teeth: int, thick: float, col: Color, speed: float) -> void:
	var g := Node3D.new()
	g.position = centre
	add_child(g)
	Props.cyl(g, r, thick, Vector3.ZERO, col, Vector3.ZERO, 14)
	for i in teeth:
		var a := TAU * float(i) / float(teeth)
		Props.box(g, Vector3(r * 0.22, thick, r * 0.16), Vector3(cos(a) * r * 1.05, 0, sin(a) * r * 1.05), col, Vector3(0, -rad_to_deg(a), 0))
	_spinners.append([g, Vector3.UP, speed])


## Dünya tarihinin sarmal maketi (v0.99.101; eski "zaman nehri" masası yerine. Kullanıcı: "Einstein'ın odasındaki tarih
## masası çok kötü, oraya daha iyi bir şey düşün"). Yuvarlak ceviz masada iki tur yükselen pirinç sarmal ray; üstünde
## kapılardaki yirmi olayın minyatürü (DoorScenes, küçültülmüş, döngüyle oynar), her birinin önünde yılı; tepede dönen
## dünya. Minik bir tren rayı piramitlerden bugüne gezer, 1453'teki kırmızı bantta takılıp bekler (hikâyenin anomalisi).
const SPIRAL_C := Vector3(7.0, 0.0, -46.0)
const SPIRAL_TURNS := 2.0
var _train: Node3D


## Atriumun eğlencesi (v0.99.105; kullanıcı: "bu odayı daha da doldur, eğlenceli bir oda olacak"): tavanda Leonardo'nun
## kanat çırpan uçan makinesi, Tesla'nın çatırdayan bobini ile Edison'un gramofonu (AC/DC), Newton'un elma düşüren ağacı,
## dolunca ters dönen dev kum saati, çağların duvar saatleri, sarmal maketin çevresinde müze ipi.
var _coil_arcs: Array = []
var _coil_t := 0.0


func _rc_atrium_fun() -> void:
	var brass := C_BRASS
	# --- Uçan makine (ornitopter): tavandan zincirle asılı, kanatları ağır ağır çırpar
	var orn := Node3D.new()
	orn.position = Vector3(9.5, 4.6, -41.5)
	orn.rotation_degrees.y = 25.0
	orn.scale = Vector3.ONE * 1.5
	add_child(orn)
	Props.box(orn, Vector3(0.22, 0.18, 1.6), Vector3.ZERO, C_WOOD)
	Props.box(orn, Vector3(0.9, 0.04, 0.5), Vector3(0, 0.0, -0.9), Color("e8dcc0"))            # kuyruk
	for sx: float in [-1.0, 1.0]:
		var hinge := Node3D.new()
		hinge.position = Vector3(sx * 0.1, 0.05, 0.1)
		orn.add_child(hinge)
		for k in 4:     # kaburgalı yarasa kanadı: ahşap çıta ve keten
			Props.box(hinge, Vector3(1.9 - k * 0.3, 0.03, 0.04), Vector3(sx * (0.95 - k * 0.15), 0.0, 0.3 - k * 0.22), C_WOOD.darkened(0.2), Vector3(0, sx * (8.0 + k * 6.0), 0))
		Props.box(hinge, Vector3(1.8, 0.012, 0.85), Vector3(sx * 0.92, -0.01, -0.05), Color("efe6cc"))
		var tw := hinge.create_tween().set_loops()
		tw.tween_property(hinge, "rotation_degrees:z", sx * 22.0, 1.1).from(sx * -14.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(hinge, "rotation_degrees:z", sx * -14.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for cz: float in [-0.6, 0.6]:
		Props.cyl(orn, 0.008, 2.4, Vector3(0, 1.2, cz), C_METAL, Vector3.ZERO, 4)
	_reg("bur_ornithopter", Vector3(4.0, 2.0, 3.0), Vector3(9.5, 3.4, -41.5), "UI_BUR_LOOK", _rc_look.bind("bur_ornithopter", "BUR_ORNITHOPTER", 2))
	# --- Tesla bobini: bakır sargılı direk, tepede küre, ondan çatırdayan mor şimşek kolları
	var cp := Vector3(12.2, 0.0, -53.0)
	Props.cyl(self, 0.32, 0.25, cp + Vector3(0, 0.125, 0), Color("2a2a30"), Vector3.ZERO, 12)
	Props.cyl(self, 0.12, 1.4, cp + Vector3(0, 0.95, 0), Color("b8743a"), Vector3.ZERO, 12)
	for k in 7:
		Props.cyl(self, 0.125, 0.02, cp + Vector3(0, 0.4 + k * 0.18, 0), Color("8a4a1a"), Vector3.ZERO, 12)
	Props.ring(self, 0.14, 0.34, cp + Vector3(0, 1.72, 0), C_METAL, Vector3.ZERO, 0.2)
	Props.ball(self, 0.2, cp + Vector3(0, 1.85, 0), Color("c8ccd4"), Vector3.ONE, 12, 0.3)
	for k in 6:
		var arc := Props.box(self, Vector3(0.025, 0.025, 0.6 + (k % 3) * 0.15), cp + Vector3(0, 1.85, 0), Color("c8a8ff"), Vector3(randf_range(-40, 40), k * 60.0, 0), 3.0)
		arc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_coil_arcs.append(arc)
	Props.box(self, Vector3(0.42, 0.3, 0.04), cp + Vector3(0.0, 1.0, 0.55), Color("2a2a30"))      # levha odaya (+z) bakar
	_lbl(self, "AC", "AC", cp + Vector3(0.0, 1.0, 0.575), 40, Color("c8a8ff"))
	Props.cyl(self, 0.02, 0.85, cp + Vector3(0.0, 0.42, 0.55), C_METAL, Vector3.ZERO, 6)
	_reg("bur_coil", Vector3(0.9, 2.2, 0.9), cp + Vector3(0, 1.1, 0), "UI_BUR_LOOK", _rc_look.bind("bur_coil", "BUR_COIL", 2))
	# --- Edison'un gramofonu (küçük masada, borusu parlak) ve DC tabelası
	var gp := Vector3(14.8, 0.0, -54.4)
	Props.box(self, Vector3(0.6, 0.04, 0.5), gp + Vector3(0, 0.74, 0), C_WOOD)
	for gx: float in [-0.26, 0.26]:
		for gz: float in [-0.21, 0.21]:
			Props.box(self, Vector3(0.04, 0.72, 0.04), gp + Vector3(gx, 0.36, gz), C_WOOD_DARK)
	Props.box(self, Vector3(0.36, 0.14, 0.36), gp + Vector3(0, 0.83, 0), C_WALNUT)
	var disc := Props.cyl(self, 0.15, 0.012, gp + Vector3(0, 0.91, 0), Color("1a1a1a"), Vector3.ZERO, 16)
	_spinners.append([disc, Vector3.UP, 3.5])
	Props.cyl(self, 0.012, 0.3, gp + Vector3(0.1, 1.05, 0.05), brass, Vector3(0, 0, -30), 6)
	Props.cyl(self, 0.04, 0.4, gp + Vector3(0.18, 1.3, 0.12), brass, Vector3(-30, 0, -40), 12, 0.26)
	Props.box(self, Vector3(0.04, 0.3, 0.42), gp + Vector3(-0.45, 1.0, 0.3), Color("2a2a30"))     # levha odaya (-x) bakar
	_lbl(self, "DC", "DC", gp + Vector3(-0.475, 1.0, 0.3), 40, Color("ffd27a"), Vector3(0, -90, 0))
	Props.cyl(self, 0.02, 0.85, gp + Vector3(-0.45, 0.42, 0.3), C_METAL, Vector3.ZERO, 6)
	_reg("bur_phono", Vector3(0.8, 1.2, 0.8), gp + Vector3(0, 1.0, 0), "UI_BUR_LOOK", _rc_look.bind("bur_phono", "BUR_PHONO", 2))
	# --- Newton'un elma ağacı: büyük saksı, gövde, yapraklı taç; ara ara bir elma düşüp yerde yuvarlanır
	var tp := Vector3(15.05, 0.0, -37.45)
	Props.cyl(self, 0.42, 0.55, tp + Vector3(0, 0.275, 0), Color("a8583a"), Vector3.ZERO, 14, 0.5)
	Props.cyl(self, 0.47, 0.06, tp + Vector3(0, 0.55, 0), Color("8a4a2a"), Vector3.ZERO, 14)
	Props.cyl(self, 0.09, 1.7, tp + Vector3(0, 1.4, 0), Color("6a4a2a"), Vector3(0, 0, 4), 8, 0.06)
	for k in 5:
		var a := k * 1.26
		Props.ball(self, 0.5 - (k % 2) * 0.1, tp + Vector3(cos(a) * 0.35, 2.4 + (k % 3) * 0.18, sin(a) * 0.35), Color("3f7a3a").lerp(Color("5a9a3a"), (k % 3) * 0.3), Vector3(1, 0.8, 1), 10)
	for k in 6:
		var a2 := k * 1.05 + 0.4
		Props.ball(self, 0.055, tp + Vector3(cos(a2) * 0.55, 2.15 + (k % 2) * 0.35, sin(a2) * 0.55), Color("c42a22"), Vector3.ONE, 8)
	var apple := Props.ball(self, 0.055, tp + Vector3(-0.5, 2.1, 0.2), Color("c42a22"), Vector3.ONE, 8)
	if not GameState.autotest:
		var at := apple.create_tween().set_loops()
		at.tween_interval(6.0)
		at.tween_property(apple, "position:y", 0.055, 0.62).from(2.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		at.tween_callback(Audio.sfx.bind("land_thud", -26.0, 2.2))
		at.tween_property(apple, "position:x", tp.x - 1.1, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		at.tween_interval(2.5)
		at.tween_property(apple, "scale", Vector3.ZERO, 0.3)
		at.tween_callback(func():
			apple.position = tp + Vector3(-0.5, 2.1, 0.2)
			apple.scale = Vector3.ONE)
	_reg("bur_appletree", Vector3(1.4, 2.6, 1.4), tp + Vector3(0, 1.3, 0), "UI_BUR_LOOK", _rc_look.bind("bur_appletree", "BUR_APPLETREE", 2))
	# --- Dev kum saati: üst hazne boşalır, alt dolar; dolunca ters döner
	var hp := Vector3(4.0, 0.0, -53.6)
	var hg := Node3D.new()
	hg.position = hp + Vector3(0, 1.15, 0)
	add_child(hg)
	Props.cyl(self, 0.5, 0.1, hp + Vector3(0, 0.05, 0), C_WALNUT, Vector3.ZERO, 12)
	for k in 3:
		var a3 := TAU * k / 3.0
		Props.cyl(self, 0.03, 2.2, hp + Vector3(cos(a3) * 0.42, 1.15, sin(a3) * 0.42), C_WALNUT, Vector3.ZERO, 6)
	Props.cyl(self, 0.5, 0.1, hp + Vector3(0, 2.25, 0), C_WALNUT, Vector3.ZERO, 12)
	var glass := Color(0.8, 0.92, 1.0, 0.25)
	Props.cyl(hg, 0.34, 0.95, Vector3(0, 0.5, 0), glass, Vector3.ZERO, 14, 0.04)
	Props.cyl(hg, 0.04, 0.95, Vector3(0, -0.5, 0), glass, Vector3.ZERO, 14, 0.34)
	var sand_top := Node3D.new()
	sand_top.position = Vector3(0, 0.08, 0)
	hg.add_child(sand_top)
	Props.cyl(sand_top, 0.28, 0.7, Vector3(0, 0.35, 0), Color("e8c070"), Vector3.ZERO, 12, 0.02)
	var sand_bot := Node3D.new()
	sand_bot.position = Vector3(0, -0.96, 0)
	hg.add_child(sand_bot)
	Props.cyl(sand_bot, 0.3, 0.6, Vector3(0, 0.3, 0), Color("e8c070"), Vector3.ZERO, 12, 0.02)
	Props.cyl(hg, 0.008, 0.9, Vector3(0, -0.45, 0), Color("e8c070"), Vector3.ZERO, 4)
	if not GameState.autotest:
		var ht := hg.create_tween().set_loops()
		ht.tween_method(func(v: float):
			sand_top.scale = Vector3(1, maxf(1.0 - v, 0.02), 1)
			sand_bot.scale = Vector3(1, maxf(v, 0.02), 1), 0.0, 1.0, 24.0)
		ht.tween_property(hg, "rotation:z", PI, 1.2).from(0.0).set_trans(Tween.TRANS_BACK)
		ht.tween_callback(func():
			hg.rotation.z = 0.0
			sand_top.scale = Vector3.ONE
			sand_bot.scale = Vector3(1, 0.02, 1))
	_reg("bur_hourglass", Vector3(1.2, 2.4, 1.2), hp + Vector3(0, 1.2, 0), "UI_BUR_LOOK", _rc_look.bind("bur_hourglass", "BUR_HOURGLASS", 2))
	# --- Çağların saatleri (güney duvarı): her biri başka çağın saatini gösterir, Büro'nunki geriye koşar
	var cities := [["Roma · MÖ 44", "Rome · 44 BC"], ["Kostantiniyye · 1453", "Constantinople · 1453"], ["Paris · 1789", "Paris · 1789"],
		["Ay · 1969", "Moon · 1969"], ["Büro · ?", "Bureau · ?"]]
	for k in cities.size():
		var cxk := 4.8 + k * 2.2
		var cpos := Vector3(cxk, 4.25, -55.42)     # aplikler (y 3.0-3.24) altta kalsın, saat yüzü onlara değmesin
		Props.cyl(self, 0.5, 0.06, cpos, Color("f4efe2"), Vector3(90, 0, 0), 24)
		Props.ring(self, 0.5, 0.57, cpos + Vector3(0, 0, 0.01), brass, Vector3(90, 0, 0))
		var hand := Node3D.new()
		hand.position = cpos + Vector3(0, 0, 0.05)
		hand.rotation.z = randf() * TAU
		add_child(hand)
		Props.box(hand, Vector3(0.03, 0.38, 0.01), Vector3(0, 0.16, 0), Color("1a1a1a"))
		Props.box(hand, Vector3(0.045, 0.24, 0.01), Vector3(0, 0.1, 0.008), Color("1a1a1a"), Vector3(0, 0, 120))
		_spinners.append([hand, Vector3.BACK, (2.5 if k == cities.size() - 1 else -0.06 - k * 0.02)])
		_lbl(self, cities[k][0], cities[k][1], cpos + Vector3(0, -0.78, 0.02), 24, Color("e8d8a8"), Vector3.ZERO, 2.0)
	_reg("bur_clocks", Vector3(11.0, 2.6, 0.8), Vector3(9.2, 3.6, -55.0), "UI_BUR_LOOK", _rc_look.bind("bur_clocks", "BUR_CLOCKS", 2))
	# --- Sarmal maketin çevresinde müze ipi ve levha
	var c := SPIRAL_C
	var posts: Array = []
	for deg: float in [45.0, 105.0, 165.0, 225.0, 285.0, 345.0]:
		var a4 := deg_to_rad(deg)
		var pp := c + Vector3(cos(a4) * 2.35, 0, sin(a4) * 2.35)
		posts.append(pp)
		Props.cyl(self, 0.16, 0.04, pp + Vector3(0, 0.02, 0), brass, Vector3.ZERO, 10)
		Props.cyl(self, 0.025, 0.95, pp + Vector3(0, 0.5, 0), brass, Vector3.ZERO, 8)
		Props.ball(self, 0.045, pp + Vector3(0, 0.98, 0), brass, Vector3.ONE, 8)
	for k in posts.size():
		if k == 0:
			continue          # Leonardo'nun durduğu yer (doğu): ip yok, maketi anlatır
		var p0: Vector3 = posts[k - 1]
		var p1: Vector3 = posts[k]
		var mid := (p0 + p1) * 0.5 + Vector3(0, 0.82, 0)
		var d := p1 - p0
		Props.cyl(self, 0.02, d.length(), mid, Color("9a1a2a"), Vector3(90, rad_to_deg(atan2(d.x, d.z)), 0), 6)
	var sp := c + Vector3(cos(deg_to_rad(135.0)) * 2.6, 0, sin(deg_to_rad(135.0)) * 2.6)
	Props.cyl(self, 0.02, 1.0, sp + Vector3(0, 0.5, 0), brass, Vector3.ZERO, 6)
	Props.box(self, Vector3(0.5, 0.32, 0.03), sp + Vector3(0, 1.1, 0), Color("1d3f5a"), Vector3(-15, 135.0 - 90.0, 0))
	_lbl(self, "DÜNYA TARİHİ\nÖlçek 1:∞ · Dokunmayın", "WORLD HISTORY\nScale 1:∞ · Do not touch", sp + Vector3(0.012, 1.1, 0.012), 14, Color("f4ecd4"), Vector3(-15, 45.0, 0), 0.46)


func _coil_tick(delta: float) -> void:
	_coil_t -= delta
	if _coil_t > 0.0 or _coil_arcs.is_empty():
		return
	_coil_t = randf_range(0.06, 0.2)
	for arc: Node3D in _coil_arcs:
		if is_instance_valid(arc):
			arc.visible = randf() < 0.55
			arc.rotation_degrees = Vector3(randf_range(-55, 35), randf() * 360.0, randf_range(-20, 20))


func _sp_point(u: float) -> Vector3:
	var ang := 0.6 - u * SPIRAL_TURNS * TAU
	var r := lerpf(1.36, 0.42, u)
	return SPIRAL_C + Vector3(sin(ang) * r, lerpf(1.02, 1.92, u), cos(ang) * r)


func _sp_out(u: float) -> Vector3:
	var ang := 0.6 - u * SPIRAL_TURNS * TAU
	return Vector3(sin(ang), 0, cos(ang))


func _rc_spiral() -> void:
	var c := SPIRAL_C
	# Yuvarlak ayak (çarpışma: içinde kalan kare), ceviz tabla, lacivert çuha, pirinç kenar halkası
	Props.solid(self, Vector3(1.6, 0.9, 1.6), c + Vector3(0, 0.45, 0), C_WOOD_DARK)
	Props.cyl(self, 1.2, 0.9, c + Vector3(0, 0.45, 0), C_WOOD_DARK, Vector3.ZERO, 32)
	Props.cyl(self, 1.62, 0.07, c + Vector3(0, 0.935, 0), C_WALNUT, Vector3.ZERO, 32)
	Props.cyl(self, 1.5, 0.006, c + Vector3(0, 0.973, 0), Color("26304e"), Vector3.ZERO, 32)
	Props.ring(self, 1.5, 1.625, c + Vector3(0, 0.974, 0), C_BRASS)
	# Orta sütun ve tepede dönen dünya (bugün)
	Props.cyl(self, 0.06, 1.25, c + Vector3(0, 1.6, 0), C_BRASS, Vector3.ZERO, 10)
	var globe := Node3D.new()
	globe.position = c + Vector3(0, 2.38, 0)
	globe.rotation_degrees.z = 23.0
	add_child(globe)
	Props.ball(globe, 0.2, Vector3.ZERO, Color("2a6ab0"), Vector3.ONE, 16, 0.25)
	for k in 6:
		var a := k * 1.05
		Props.ball(globe, 0.07 + (k % 3) * 0.02, Vector3(sin(a) * 0.17, (k % 3 - 1) * 0.09, cos(a) * 0.17), Color("4a9a4a"), Vector3(1, 0.7, 0.35), 8)
	Props.ring(self, 0.24, 0.27, c + Vector3(0, 2.38, 0), C_BRASS, Vector3(0, 0, 23), 0.3)
	_spinners.append([globe, Vector3.UP, 0.35])
	# Ray: 96 parça, iç kenarda ince pirinç korkuluk; her 12 parçada bir masaya inen ayak
	var n := 96
	for k in n:
		var u0 := float(k) / n
		var u1 := float(k + 1) / n
		var p0 := _sp_point(u0)
		var p1 := _sp_point(u1)
		var d := p1 - p0
		var m := (p0 + p1) * 0.5
		var hl := Vector2(d.x, d.z).length()
		var rot := Vector3(-rad_to_deg(atan2(d.y, hl)), rad_to_deg(atan2(d.x, d.z)), 0)
		Props.box(self, Vector3(0.3, 0.025, d.length() + 0.01), m, Color("6a4a2a"), rot)
		Props.box(self, Vector3(0.012, 0.012, d.length() + 0.01), m - _sp_out((u0 + u1) * 0.5) * 0.15 + Vector3(0, 0.03, 0), C_BRASS, rot)
		if k % 12 == 6:
			var h := m.y - 0.98
			Props.cyl(self, 0.012, h, Vector3(m.x, 0.98 + h / 2.0, m.z) + _sp_out(u0) * 0.1, C_BRASS, Vector3.ZERO, 6)
	# Duraklar: kapılardaki sahneler, küçültülmüş, yüzü dışarıya; önlerinde yıl
	var yrs: Array = YEARS
	for i in yrs.size():
		var u := float(i) / (yrs.size() - 1) * 0.97 + 0.015
		var pt := _sp_point(u) + _sp_out(u) * 0.06
		var yaw := rad_to_deg(atan2(_sp_out(u).x, _sp_out(u).z))
		var st := Node3D.new()
		st.position = pt + Vector3(0, 0.014, 0)
		st.rotation_degrees.y = yaw
		st.scale = Vector3.ONE * 0.3
		add_child(st)
		DoorScenes.build(String(yrs[i]), st)
		var col: Color = ERA_COLORS.get(yrs[i], Color("e8d8b0"))
		Props.label(self, String(yrs[i]), pt + _sp_out(u) * 0.11 + Vector3(0, 0.03, 0), 12, col.lightened(0.3), Vector3(-25, yaw, 0), 0.2)
		if yrs[i] == "1453":     # rayın üstünde kırmızı bant: tren burada takılır
			Props.box(self, Vector3(0.34, 0.03, 0.035), _sp_point(u - 0.012) + Vector3(0, 0.03, 0), Color("c0262d"), Vector3(0, yaw, 0), 0.4)
	# Tren: lokomotif ve iki vagon; rayın iç yarısında gider
	_train = Node3D.new()
	add_child(_train)
	Props.box(_train, Vector3(0.06, 0.06, 0.13), Vector3(0, 0.05, 0), Color("b8322a"))
	Props.cyl(_train, 0.018, 0.05, Vector3(0, 0.1, 0.04), Color("2a2a2e"), Vector3.ZERO, 8)
	Props.box(_train, Vector3(0.065, 0.03, 0.05), Vector3(0, 0.095, -0.035), Color("2a2a2e"))
	Props.ball(_train, 0.012, Vector3(0, 0.05, 0.068), Color("ffe8a0"), Vector3.ONE, 6, 2.0)
	for v in 2:
		Props.box(_train, Vector3(0.055, 0.05, 0.1), Vector3(0, 0.045, -0.15 - v * 0.12), [Color("2a5a8a"), Color("c9a24a")][v])
	_train_at(0.0)
	_reg("bur_timeline", Vector3(3.4, 1.6, 3.4), SPIRAL_C + Vector3(0, 1.5, 0), "UI_BUR_LOOK", _rc_look.bind("bur_timeline", "BUR_TIMELINE", 2))
	if GameState.autotest:
		return
	var u53 := float(yrs.find("1453")) / (yrs.size() - 1) * 0.97 + 0.015 - 0.03
	var tw := create_tween().set_loops()
	tw.tween_method(_train_at, 0.0, u53, 14.0)
	tw.tween_interval(2.5)
	tw.tween_callback(Audio.sfx.bind("stamp", -24.0, 1.4))
	tw.tween_method(_train_at, u53, 1.0, 22.0)
	tw.tween_interval(2.0)
	tw.tween_method(_train_at, 1.0, 0.0, 20.0)
	tw.tween_interval(1.5)


func _train_at(u: float) -> void:
	if not is_instance_valid(_train):
		return
	var p := _sp_point(u) - _sp_out(u) * 0.09
	var q := _sp_point(minf(u + 0.004, 1.0)) - _sp_out(minf(u + 0.004, 1.0)) * 0.09
	if u >= 0.996:
		q = p + (p - (_sp_point(u - 0.004) - _sp_out(u - 0.004) * 0.09))
	_train.position = p + Vector3(0, 0.012, 0)
	var d := q - p
	_train.rotation = Vector3(-atan2(d.y, Vector2(d.x, d.z).length()), atan2(d.x, d.z), 0)


func _rc_atrium() -> void:
	var ind := Color("3c4a78")
	var dark := Color("26304e")
	var h := 7.5
	_floor(Vector2(14.0, 19.0), Vector3(9.0, 0, -46.0), Color("e6dcc2"), Color("33406a"), 0.5)
	Props.solid(self, Vector3(14.2, 0.3, 19.4), Vector3(9.1, h + 0.15, -46.0), Color("15162a"))
	_wall(Vector3(14.0, h, 0.2), Vector3(9.2, h / 2, -36.4), ind)
	_wall(Vector3(14.0, h, 0.2), Vector3(9.2, h / 2, -55.6), ind)
	# doğu duvarı: pencere açıklığının (z -40.5..-51.5, y 1..5,8) çevresi
	_wall(Vector3(0.2, h, 4.0), Vector3(16.1, h / 2, -38.5), ind)
	_wall(Vector3(0.2, h, 4.0), Vector3(16.1, h / 2, -53.5), ind)
	_wall(Vector3(0.2, 1.0, 11.0), Vector3(16.1, 0.5, -46.0), dark)
	_wall(Vector3(0.2, 1.7, 11.0), Vector3(16.1, 6.65, -46.0), ind)
	# koridor açıklığının üstü (y 3,4 üzeri) kapalı
	_wall(Vector3(0.2, h - COR_H, 19.0), Vector3(2.1, COR_H + (h - COR_H) / 2, -46.0), ind)
	# koyu alt bant
	Props.box(self, Vector3(13.8, 1.6, 0.04), Vector3(9.1, 0.8, -36.52), dark)
	Props.box(self, Vector3(13.8, 1.6, 0.04), Vector3(9.1, 0.8, -55.48), dark)
	Props.box(self, Vector3(0.04, 1.6, 4.0), Vector3(15.98, 0.8, -38.5), dark)
	Props.box(self, Vector3(0.04, 1.6, 4.0), Vector3(15.98, 0.8, -53.5), dark)
	# sütunlu sıra x=2,0 + lento
	for cz: float in [-38.5, -42.5, -46.5, -50.5, -54.5]:
		var col := Props.cyl(self, 0.3, 3.4, Vector3(2.0, 1.7, cz), Color("c8c0d8"), Vector3.ZERO, 12)
		Props.make_solid(col, 0.9)
		Props.cyl(self, 0.38, 0.12, Vector3(2.0, 3.34, cz), C_BRASS, Vector3.ZERO, 12)
	Props.box(self, Vector3(0.7, 0.3, 19.0), Vector3(2.0, 3.55, -46.0), Color("4a3a24"))
	# kaset tavan kirişleri
	for bx: float in [5.5, 9.0, 12.5]:
		Props.box(self, Vector3(0.35, 0.3, 19.0), Vector3(bx, 7.2, -46.0), Color("1c1e38"))
	for bz: float in [-39.5, -44.0, -48.5, -53.0]:
		Props.box(self, Vector3(14.0, 0.3, 0.35), Vector3(9.0, 7.2, bz), Color("1c1e38"))
	# BÜYÜK PENCERE
	_rc_win_mat = _rc_window_quad(self, Vector2(11.0, 4.8), Vector3(15.95, 3.4, -46.0), Vector3(0, -90, 0), 1.2)
	Props.box(self, Vector3(0.14, 0.14, 11.2), Vector3(15.9, 1.07, -46.0), C_WALNUT)
	Props.box(self, Vector3(0.14, 0.14, 11.2), Vector3(15.9, 5.73, -46.0), C_WALNUT)
	Props.box(self, Vector3(0.14, 4.8, 0.14), Vector3(15.9, 3.4, -40.57), C_WALNUT)
	Props.box(self, Vector3(0.14, 4.8, 0.14), Vector3(15.9, 3.4, -51.43), C_WALNUT)
	for mz: float in [-48.75, -46.0, -43.25]:
		Props.box(self, Vector3(0.08, 4.7, 0.1), Vector3(15.9, 3.4, mz), C_BRASS)
	Props.box(self, Vector3(0.08, 0.1, 11.0), Vector3(15.9, 3.4, -46.0), C_BRASS)
	Props.solid(self, Vector3(0.55, 0.45, 10.8), Vector3(15.7, 0.225, -46.0), C_WOOD_DARK)
	Props.box(self, Vector3(0.5, 0.1, 10.6), Vector3(15.7, 0.5, -46.0), C_RUG)
	_glow(self, Vector3(13.5, 0.03, -46.0), Vector2(6.0, 9.0), Color("9a8cff"), Vector3(-90, 0, 0), 0.25)
	_reg("bur_atriumwin", Vector3(0.5, 4.8, 11.0), Vector3(15.5, 3.4, -46.0), "UI_BUR_LOOK", _rc_atriumwin)
	# Görünmez cam: sedirin önünden yukarı (oyuncu sedire çıkıp pencereden dışarı yürüyordu)
	var gb := StaticBody3D.new()
	gb.position = Vector3(15.35, 3.0, -46.0)
	var gcs := CollisionShape3D.new()
	var gbs := BoxShape3D.new()
	gbs.size = Vector3(0.3, 6.0, 11.2)
	gcs.shape = gbs
	gb.add_child(gcs)
	add_child(gb)
	# Camın önünde ince parlak yansıma çizgileri (cam olduğunu söyler; yaklaşınca da yüzey gibi durur)
	for k in 3:
		_glow(self, Vector3(15.85, 3.6 - k * 0.7, -43.0 - k * 2.6), Vector2(0.12, 2.2), Color("cfe0ff"), Vector3(0, -90, 25), 0.12)
	# pencereye bakan bankolar
	for bz: float in [-43.2, -48.8]:
		Props.solid(self, Vector3(0.4, 0.42, 2.8), Vector3(11.8, 0.21, bz), C_WOOD_DARK)
		Props.box(self, Vector3(0.5, 0.07, 3.0), Vector3(11.8, 0.45, bz), C_WOOD)
		Props.box(self, Vector3(0.07, 0.5, 3.0), Vector3(11.55, 0.75, bz), C_WOOD)
	# ışıklar
	_bulb(Vector3(14.2, 3.8, -46.0), Color("9a8cff"), 2.2, 16.0)
	_bulb(Vector3(7.0, 2.8, -46.0), Color("ffb830"), 1.4, 8.0)
	_bulb(Vector3(9.0, 6.8, -46.0), Color("ffd890"), 1.3, 13.0)
	# Duvar aplikleri: pirinç kol + kehribar küre + duvara vuran sıcak hale (gerçek ışık yok)
	for ap in [[9.2, -36.55, 0.0], [5.0, -36.55, 0.0], [13.0, -36.55, 0.0], [9.2, -55.45, 180.0], [5.0, -55.45, 180.0], [13.0, -55.45, 180.0]]:
		var az: float = ap[1]
		var sg := 1.0 if az > -46.0 else -1.0
		Props.box(self, Vector3(0.06, 0.06, 0.27), Vector3(float(ap[0]), 3.0, az - sg * 0.075), C_BRASS)
		Props.ball(self, 0.12, Vector3(float(ap[0]), 3.12, az - sg * 0.24), Color("ffc860"), Vector3.ONE, 8, 1.6)
		_glow(self, Vector3(float(ap[0]), 3.1, az - sg * 0.03), Vector2(2.2, 2.2), Color("ffb040"), Vector3(0, float(ap[2]), 0), 0.35)
	# tavandan sarkan orrery / dişli düzeneği
	var gold := C_BRASS
	var gdark := Color("a07830")
	Props.cyl(self, 0.07, 2.5, Vector3(8.5, 6.25, -46.0), gold, Vector3.ZERO, 8)
	Props.cyl(self, 0.04, 1.9, Vector3(11.4, 6.55, -46.0), gold, Vector3.ZERO, 6)
	Props.cyl(self, 0.04, 2.3, Vector3(6.0, 6.35, -44.0), gold, Vector3.ZERO, 6)
	_rc_gear(Vector3(8.5, 5.0, -46.0), 1.9, 8, 0.12, gold, 0.12)
	_rc_gear(Vector3(11.4, 5.6, -46.0), 1.2, 6, 0.1, gdark, -0.2)
	_rc_gear(Vector3(6.0, 5.2, -44.0), 0.8, 5, 0.1, gold, 0.3)
	var rr1 := Node3D.new()
	rr1.position = Vector3(8.5, 5.0, -46.0)
	add_child(rr1)
	Props.ring(rr1, 2.25, 2.32, Vector3.ZERO, gold, Vector3(35, 0, 10))
	_spinners.append([rr1, Vector3(0.1, 1.0, 0.05).normalized(), 0.08])
	var rr2 := Node3D.new()
	rr2.position = Vector3(8.5, 5.0, -46.0)
	add_child(rr2)
	Props.ring(rr2, 1.55, 1.61, Vector3.ZERO, gdark, Vector3(-30, 0, -25))
	_spinners.append([rr2, Vector3(-0.1, 1.0, 0.08).normalized(), -0.14])
	Props.ball(self, 0.22, Vector3(8.5, 4.6, -46.0), Color("ffb830"), Vector3.ONE, 10, 1.5)
	# sarkaç: 6,4 m çubuk, 1 m altın top, periyot ~4 sn
	var pivot := Node3D.new()
	pivot.position = Vector3(12.0, 7.45, -38.5)
	add_child(pivot)
	_rc_pend = pivot
	Props.box(pivot, Vector3(0.4, 0.1, 0.4), Vector3(0, 0.02, 0), gold)
	Props.cyl(pivot, 0.025, 6.4, Vector3(0, -3.2, 0), gold, Vector3.ZERO, 6)
	Props.ball(pivot, 0.5, Vector3(0, -6.45, 0), Color("e0b030"), Vector3.ONE, 14, 0.5)
	pivot.rotation.z = -0.3
	var ptw := pivot.create_tween().set_loops()
	ptw.tween_property(pivot, "rotation:z", 0.3, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ptw.tween_property(pivot, "rotation:z", -0.3, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	Props.ring(self, 0.62, 0.68, Vector3(12.0, 0.02, -38.5), gold, Vector3.ZERO, 0.4)
	_lbl(self, "±0 sn", "±0 s", Vector3(12.0, 0.03, -37.6), 26, Color("e8d8a8"), Vector3(-90, 0, 0), 1.0)
	_reg("bur_pendulum", Vector3(3.0, 2.0, 1.4), Vector3(12.0, 1.2, -38.5), "UI_BUR_LOOK", _rc_pendulum)
	_rc_spiral()
	_rc_atrium_fun()


func _rc_atriumwin() -> void:
	_rc_look("bur_atriumwin", "BUR_ATRIUMWIN", 2)
	Audio.sfx("whoosh_fly", -20.0, 0.6)
	if _rc_win_mat == null:
		return
	_rc_win_mat.set_shader_parameter("focus_era", randi_range(0, 7))
	if _rc_win_tw and _rc_win_tw.is_valid():
		_rc_win_tw.kill()
	var t := 0.3 if GameState.autotest else 1.5
	_rc_win_tw = create_tween()
	_rc_win_tw.tween_method(_rc_set_focus, 0.0, 1.0, t)
	_rc_win_tw.tween_method(_rc_set_focus, 1.0, 0.0, t)


func _rc_set_focus(v: float) -> void:
	if _rc_win_mat:
		_rc_win_mat.set_shader_parameter("era_focus", v)


func _rc_pendulum() -> void:
	_rc_look("bur_pendulum", "BUR_PENDULUM", 2)
	Audio.sfx("timer_tick", -16.0, 0.7)
	if _count("bur_pendulum") >= 2:
		_second(4, Vector3(12.0, 1.6, -38.5))


# ---------------------------------------------------------------- koridor sonu: zamana açılan kemerli pencere (z -84)

func _rc_end_window() -> void:
	_rc_window_quad(self, Vector2(3.0, 2.0), Vector3(0, 1.7, -83.88), Vector3.ZERO, 1.4)
	# Pirinç korkuluk + görünmez cam: pencerenin dibine girilmesin
	for kx: float in [-1.4, 0.0, 1.4]:
		Props.cyl(self, 0.03, 0.95, Vector3(kx, 0.475, -83.35), C_BRASS, Vector3.ZERO, 8)
	Props.cyl(self, 0.035, 3.0, Vector3(0, 0.95, -83.35), C_BRASS, Vector3(0, 0, 90), 8)
	var eb := StaticBody3D.new()
	eb.position = Vector3(0, 1.5, -83.55)
	var ecs := CollisionShape3D.new()
	var ebs := BoxShape3D.new()
	ebs.size = Vector3(COR_W, 3.0, 0.4)
	ecs.shape = ebs
	eb.add_child(ecs)
	add_child(eb)
	# pirinç çerçeve
	Props.box(self, Vector3(3.2, 0.1, 0.1), Vector3(0, 0.72, -83.85), C_BRASS)
	Props.box(self, Vector3(0.1, 2.0, 0.1), Vector3(-1.55, 1.7, -83.85), C_BRASS)
	Props.box(self, Vector3(0.1, 2.0, 0.1), Vector3(1.55, 1.7, -83.85), C_BRASS)
	# Üst kenar: düz pirinç kasa ve köşelerde çeyrek daire pirinç kavisler (basamaklı duvar parçaları manzaranın
	# köşelerine yama gibi biniyordu)
	Props.box(self, Vector3(3.2, 0.1, 0.1), Vector3(0, 2.68, -83.85), C_BRASS)
	for sx: float in [-1.0, 1.0]:
		for k in 5:
			var a := deg_to_rad(9.0 + 18.0 * k)
			Props.box(self, Vector3(0.05, 0.12, 0.06), Vector3(sx * (1.5 - 0.35 + 0.35 * cos(a)), 2.63 - 0.35 + 0.35 * sin(a), -83.84),
				C_BRASS, Vector3(0, 0, sx * rad_to_deg(a)))
	_glow(self, Vector3(0, 0.03, -82.6), Vector2(3.2, 3.5), Color("a8c8ff"), Vector3(-90, 0, 0), 0.25)


# ---------------------------------------------------------------- Bekleme salonunda tarihî figürler (v0.99.97)
## Ünlüler Büro'nun odalarına dağılmış, her biri orada bir işte: bekleme salonunda Napolyon sandalyeye çıkmış, Cengiz Han
## numaratörü kolluyor, Hitler köşede yüzü duvara oturtulmuş; Sezar ile Shakespeare çay ocağında, Kolomb Kayıp Zaman
## Bürosu'nda, Kleopatra şikâyet masasında, Einstein sarkacın, Leonardo zaman nehri maketinin başında. Her biri isim
## kartı takar (Büro'nun kuralı); konuşulunca oyuncuya döner; yan yana olanlar laf yetiştirir.

var _fg: Dictionary = {}          # kimlik → Person
var _fg_yaw: Dictionary = {}      # kimlik → asıl bakış (derece)
var _fg_busy := false

## Bekleme salonunun koltuklarında oturanlar; koltuklar girişteki LED'e döner, Nasreddin Hoca ters oturur (yüzü duvara)
const _FG_SIT := ["pol", "gal", "cur", "moz", "sin", "nas"]
const _FG_POSE := {"gen": "arms_folded", "nap": "hand_in_coat", "hit": "hands_behind", "nas": "sit_astride"}
## [kimlik, konuşan, konum, bakış, görünüş, isim TR, isim EN]
const _FG := [
	["nap", "SPK_NAPOLEON", Vector3(-4.6, 0.48, -6.8), 90.0, {"coat": Color("24365e"), "pants": Color("efe9dc"), "hair": Color("2a2018"), "hair_style": "short", "face": {"chin": 0.4, "brow_tilt": 6.0}, "skin": Color("e8c0a0")}, "NAPOLYON", "NAPOLEON"],
	["cle", "SPK_CLEOPATRA", Vector3(-1.72, 0, -28.7), -60.0, {"coat": Color("efe6d0"), "pants": Color("efe6d0"), "skirt": true, "hat": "uraeus", "hair": Color("121010"), "hair_style": "long", "skin": Color("c98e6a")}, "KLEOPATRA", "CLEOPATRA"],
	["cae", "SPK_CAESAR", Vector3(2.55, 0, -3.95), -158.0, {"coat": Color("f2ede0"), "pants": Color("f2ede0"), "robe": Color("f2ede0"), "hat": "laurel", "hair": Color("4a3e34"), "hair_style": "short", "face": {"nose": "hook", "nose_s": 1.15, "chin": 0.55, "head": Vector3(0.93, 1.1, 0.98), "brow_tilt": 4.0}, "skin": Color("d9a07a")}, "SEZAR", "CAESAR"],
	["leo", "SPK_LEONARDO", Vector3(9.1, 0, -45.5), -90.0, {"coat": Color("5a2030"), "pants": Color("3a1a20"), "robe": Color("5a2030"), "hat": "soft_beret", "hair": Color("e6e2da"), "hair_style": "long", "beard": true, "mustache": true, "skin": Color("e8b894")}, "LEONARDO", "LEONARDO"],
	["ein", "SPK_EINSTEIN", Vector3(11.0, 0, -40.0), -45.0, {"coat": Color("7a7468"), "pants": Color("4a4a48"), "hair": Color("f2f0ea"), "hair_style": "curly", "mustache": true, "face": {"mustache": "walrus", "bags": true, "wrinkles": true}, "skin": Color("ecc0a0")}, "EINSTEIN", "EINSTEIN"],
	["hit", "SPK_HITLER", Vector3(-8.0, 0, -7.9), -90.0, {"coat": Color("5a5040"), "pants": Color("3a3630"), "hair": Color("2a2018"), "hair_style": "swept", "mustache": true, "face": {"mustache": "toothbrush", "brow_tilt": 10.0}, "skin": Color("e8c0a0")}, "HITLER", "HITLER"],
	["gen", "SPK_GENGHIS", Vector3(-3.4, 0, -5.45), 41.0, {"coat": Color("223050"), "pants": Color("2a2420"), "hair": Color("1a1410"), "hair_style": "short", "beard": true, "face": {"beard": "goatee", "brow_tilt": 13.0, "chin": 0.45, "lid": 0.35}, "skin": Color("d9a07a")}, "CENGİZ HAN", "GENGHIS KHAN"],
	["col", "SPK_COLUMBUS", Vector3(5.6, 0, -20.1), -105.0, {"coat": Color("2a4a3a"), "pants": Color("3a3a30"), "hat": "soft_beret", "hair": Color("d8d4c8"), "hair_style": "long", "skin": Color("e8b894")}, "KOLOMB", "COLUMBUS"],
	["sul", "SPK_SULEYMAN", Vector3(1.62, 0, -33.0), 60.0, {"coat": Color("c9a24a"), "pants": Color("3a2a1a"), "robe": Color("c9a24a"), "hair_style": "short", "beard": true, "mustache": true, "hair": Color("3a2a1e"), "skin": Color("e0b08a"), "face": {"beard": "full", "nose": "hook"}}, "SÜLEYMAN", "SULEIMAN"],
	["gui", "SPK_GUIDE", Vector3(8.5, 0, -52.3), -30.0, {"coat": Color("c8ccd4"), "pants": Color("2a8a8a"), "skirt": true, "hair": Color("d84a8a"), "hair_style": "short", "skin": Color("e0a882")}, "REHBER", "GUIDE"],
	["rob", "SPK_ROBOT", Vector3(-7.9, 0, -4.4), 135.0, {"coat": Color("9aa4ae"), "pants": Color("7a848e"), "hat": "robot", "hair": Color("8a949e"), "skin": Color("b8c2cc")}, "STAJYER", "INTERN"],
	["arc", "SPK_ARCHAEOLOGIST", Vector3(-5.2, 0, -20.6), -100.0, {"coat": Color("b89a6a"), "pants": Color("5a4a3a"), "hat": "fedora", "glasses": true, "hair": Color("3a2a1e"), "skin": Color("c98e6a")}, "ARKEOLOG", "ARCHAEOLOGIST"],
	["pol", "SPK_MARCOPOLO", Vector3(-4.6, 0, -7.9), 90.0, {"coat": Color("8a2a2a"), "pants": Color("3a2a20"), "hat": "soft_beret", "beard": true, "hair": Color("6a4a30"), "skin": Color("e0b08a")}, "MARCO POLO", "MARCO POLO"],
	["gal", "SPK_GALILEO", Vector3(-4.6, 0, -9.0), 90.0, {"coat": Color("2a2a30"), "pants": Color("2a2a30"), "robe": Color("2a2a30"), "beard": true, "mustache": true, "hair": Color("c8b8a0"), "hair_style": "receding", "skin": Color("e8b894")}, "GALİLEO", "GALILEO"],
	["cur", "SPK_CURIE", Vector3(-5.9, 0, -7.35), 90.0, {"coat": Color("1e1e22"), "pants": Color("1e1e22"), "skirt": true, "hat": "bun", "hair": Color("8a8478"), "skin": Color("ecc0a0")}, "CURIE", "CURIE"],
	["moz", "SPK_MOZART", Vector3(-5.9, 0, -8.45), 90.0, {"coat": Color("b8322a"), "pants": Color("efe9dc"), "hair": Color("f0ece4"), "hair_style": "swept", "skin": Color("ecc0a0")}, "MOZART", "MOZART"],
	["sin", "SPK_SINAN", Vector3(-7.2, 0, -7.9), 90.0, {"coat": Color("3a6a5a"), "pants": Color("3a2a1a"), "robe": Color("3a6a5a"), "hat": "turban", "beard": true, "mustache": true, "hair": Color("d8d4c8"), "skin": Color("d9a07a")}, "SİNAN", "SINAN"],
	["nas", "SPK_NASREDDIN", Vector3(-7.2, 0, -6.8), -90.0, {"coat": Color("4a7a3a"), "pants": Color("6a5a3a"), "robe": Color("4a7a3a"), "hat": "turban", "beard": true, "mustache": true, "hair": Color("efeae0"), "skin": Color("d9a07a")}, "NASREDDİN", "NASREDDIN"],
	["gag", "SPK_GAGARIN", Vector3(-4.1, 0, -10.5), -40.0, {"coat": Color("e06a2a"), "pants": Color("e06a2a"), "hair": Color("5a4030"), "hair_style": "short", "face": {"mouth_w": 1.25, "eye_s": 1.05}, "skin": Color("ecc0a0")}, "GAGARİN", "GAGARIN"],
	["shk", "SPK_SHAKESPEARE", Vector3(2.55, 0, -5.35), -22.0, {"coat": Color("1e1e22"), "pants": Color("1e1e22"), "hair": Color("6a4a30"), "hair_style": "receding", "mustache": true, "beard": true, "face": {"mustache": "pencil", "beard": "goatee"}, "skin": Color("ecc0a0")}, "SHAKESPEARE", "SHAKESPEARE"],
	["tes", "SPK_TESLA", Vector3(13.0, 0, -51.4), 135.0, {"coat": Color("1e1e24"), "pants": Color("1e1e24"), "hair": Color("1a1410"), "hair_style": "swept", "mustache": true, "face": {"mustache": "pencil", "head": Vector3(0.94, 1.12, 0.98)}, "skin": Color("e8c0a0")}, "TESLA", "TESLA"],
	["edi", "SPK_EDISON", Vector3(14.2, 0, -52.6), -45.0, {"coat": Color("6a6a70"), "pants": Color("3a3a40"), "hair": Color("e8e4dc"), "hair_style": "short", "face": {"brow_tilt": -4.0, "chin": 0.5}, "skin": Color("ecc0a0")}, "EDISON", "EDISON"],
	["new", "SPK_NEWTON", Vector3(13.9, 0, -39.6), -98.0, {"coat": Color("5a3a2a"), "pants": Color("3a2a20"), "hair": Color("cfc8bc"), "hair_style": "long", "face": {"nose": "long"}, "skin": Color("ecc8b0")}, "NEWTON", "NEWTON"],
	["sok", "SPK_SOCRATES", Vector3(-5.0, 0, -22.9), 90.0, {"coat": Color("e8e0cc"), "pants": Color("e8e0cc"), "robe": Color("e8e0cc"), "hair": Color("e0dcd4"), "hair_style": "bald", "beard": true, "mustache": true, "face": {"nose": "potato", "beard": "full"}, "skin": Color("d9a07a")}, "SOKRATES", "SOCRATES"],
	["dio", "SPK_DIOGENES", Vector3(-3.6, 0, -23.0), -90.0, {"coat": Color("6a5a40"), "pants": Color("6a5a40"), "hair": Color("c8c0b0"), "hair_style": "long", "beard": true, "mustache": true, "face": {"beard": "full"}, "skin": Color("d9a07a")}, "DİYOJEN", "DIOGENES"],
	["evl", "SPK_EVLIYA", Vector3(6.2, 0, -21.6), -22.0, {"coat": Color("2a5a8a"), "pants": Color("3a2a1a"), "robe": Color("2a5a8a"), "hat": "turban", "beard": true, "mustache": true, "hair": Color("3a2a1e"), "face": {"beard": "full"}, "skin": Color("d9a07a")}, "EVLİYA ÇELEBİ", "EVLIYA CELEBI"],
]


## Ceza köşesi (v0.99.101). Kullanıcı: "arkasını dönmesi iyi espri ama biraz daha ön planda olsa komik olabilir".
## Hitler bekleme salonunun girişinin tam karşısında, arka duvara dönük ayakta durur: yerde sarı-siyah bantlı kare,
## duvarda "CEZA KÖŞESİ" levhası ve üstüne düşen ışık, sırtına yapıştırılmış kâğıt. Girişten ilk bakışta görünür.
func _fg_corner(p: Person) -> void:
	var c: Vector3 = p.position
	var tape := [Color("e8c020"), Color("1a1a1a")]
	for k in 8:
		Props.box(self, Vector3(0.12, 0.006, 0.05), Vector3(c.x - 0.42 + k * 0.12, 0.006, c.z - 0.48), tape[k % 2])
		Props.box(self, Vector3(0.12, 0.006, 0.05), Vector3(c.x - 0.42 + k * 0.12, 0.006, c.z + 0.48), tape[k % 2])
		Props.box(self, Vector3(0.05, 0.006, 0.12), Vector3(c.x - 0.48, 0.006, c.z - 0.42 + k * 0.12), tape[(k + 1) % 2])
		Props.box(self, Vector3(0.05, 0.006, 0.12), Vector3(c.x + 0.48, 0.006, c.z - 0.42 + k * 0.12), tape[(k + 1) % 2])
	# Duvardaki levha (arka duvarın iç yüzü x -8,5; eskiden -8,66'daydı, duvarın içinde kalıp görünmüyordu) ve ışık
	Props.box(self, Vector3(0.04, 0.36, 1.3), Vector3(-8.48, 2.35, c.z), Color("8a1a1a"))
	Props.label(self, tr("BUR_HIT_CORNER"), Vector3(-8.455, 2.35, c.z), 40, Color("f6eedc"), Vector3(0, 90, 0), 1.2)
	_glow(self, Vector3(-8.47, 1.6, c.z), Vector2(1.4, 2.2), Color("fff0c0"), Vector3(0, 90, 0), 0.35)
	_glow(self, Vector3(c.x, 0.012, c.z), Vector2(1.1, 1.1), Color("fff0c0"), Vector3(-90, 0, 0), 0.3)
	# Sırtına yapıştırılmış kâğıt (gövdeye takılı: kıpırdayınca onunla gider). Eller arkada kavuşuk (hands_behind):
	# önkollar belde V çizip kâğıdın yarısını örtüyordu ve tek satıra sıkışan yazı V'nin içinden taşıyordu. Kâğıt
	# omuz hizasına çıktı (kolların üstünde), iki satıra bölünmüş yazı kâğıdın içinde, gövdeden bir parmak dışarıda.
	var bd: Node3D = p._body
	# Kâğıt gövdenin arka yayına SARILI tek kavisli ağ (gövde: r 0,225-0,25 kapsül; düz 0,42 m levha kenarlardan 15 cm
	# kopuk kalıp yandan "havada levha" gibi görünüyordu). Yazı ağın dokusu (SubViewport, tek çizim): kenarlarda
	# da yüzeyde kalır, harfler yay boyunca eğilmez. Hepsi _body'nin çocuğu: gövdeyle birlikte hareket eder.
	var mi := MeshInstance3D.new()
	mi.name = "HitPaper"
	mi.mesh = _hit_paper_mesh()
	_hit_sv = SubViewport.new()
	_hit_sv.size = Vector2i(512, 560)
	_hit_sv.transparent_bg = false
	_hit_sv.disable_3d = true
	bd.add_child(_hit_sv)
	var pm := StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.cull_mode = BaseMaterial3D.CULL_DISABLED
	pm.albedo_color = Color(0.97, 0.96, 0.93)
	pm.albedo_texture = _hit_sv.get_texture()
	pm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	mi.material_override = pm
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bd.add_child(mi)
	_hit_sign_draw()
	# Bantlar: üst iki köşede kâğıt yüzeyine teğet
	for sx in [-1.0, 1.0]:
		var ph: float = sx * 0.125 / _hit_back_r(_HIT_Y1 - 0.01)
		var rr := _hit_back_r(_HIT_Y1 - 0.01) + 0.02
		var nrm := Vector2(-sin(ph), -cos(ph))
		Props.box(bd, Vector3(0.09, 0.022, 0.008), Vector3(-sin(ph) * rr, _HIT_Y1 - 0.01, -cos(ph) * rr), Color("d8d0a0"), Vector3(0, rad_to_deg(atan2(nrm.x, nrm.y)), sx * 20.0))


var _hit_sv: SubViewport
const _HIT_Y0 := 0.98
const _HIT_Y1 := 1.38
const _HIT_W := 0.39      # yay boyunca genişlik
const _HIT_OFF := 0.018   # gövde yüzeyinden dışarıda (dış hat + z-çatışması payı)


## Gövdenin arka yarıçapı y yüksekliğinde: konik gövde (0,225 -> 0,25) ve omuz küresi (r 0,25, merkez 1,19)
func _hit_back_r(y: float) -> float:
	var yc := 1.191
	if y <= yc:
		return lerpf(0.225, 0.25, clampf((y - 0.809) / 0.382, 0.0, 1.0))
	return sqrt(maxf(0.0625 - (y - yc) * (y - yc), 0.0004))


func _hit_paper_mesh() -> ArrayMesh:
	var cols := 12
	var rows := 8
	var vs := PackedVector3Array()
	var uvs := PackedVector2Array()
	var ns := PackedVector3Array()
	var idx := PackedInt32Array()
	for r in rows + 1:
		var v := float(r) / rows
		var y := lerpf(_HIT_Y1, _HIT_Y0, v)
		var rr := _hit_back_r(y) + _HIT_OFF
		for c in cols + 1:
			var u := float(c) / cols
			var ph := minf((u - 0.5) * _HIT_W / rr, 1.3) if u >= 0.5 else maxf((u - 0.5) * _HIT_W / rr, -1.3)
			vs.append(Vector3(-sin(ph) * rr, y, -cos(ph) * rr))
			ns.append(Vector3(-sin(ph), 0, -cos(ph)))
			uvs.append(Vector2(u, v))
	for r in rows:
		for c in cols:
			var i0 := r * (cols + 1) + c
			idx.append_array([i0, i0 + 1, i0 + cols + 1, i0 + 1, i0 + cols + 2, i0 + cols + 1])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vs
	arr[Mesh.ARRAY_NORMAL] = ns
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_INDEX] = idx
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return m


## Kâğıdın yazısı: üç satır (ilk cümle, kalanı ortadan ikiye), kâğıt rengi zemin, koyu kalın yazı. Dil değişince yeniden.
func _hit_sign_draw() -> void:
	if _hit_sv == null or not is_instance_valid(_hit_sv):
		return
	for ch in _hit_sv.get_children():
		_hit_sv.remove_child(ch)
		ch.queue_free()
	var sg: String = tr("BUR_HIT_SIGN")
	var cut := sg.find(". ")
	var l1 := sg.substr(0, cut + 1) if cut >= 0 else sg
	var rest := sg.substr(cut + 2) if cut >= 0 else ""
	var words := rest.split(" ")
	var half := ceili(words.size() / 2.0)
	var sgn := l1
	if rest != "":
		sgn += "\n" + " ".join(words.slice(0, half)) + "\n" + " ".join(words.slice(half))
	var bg := ColorRect.new()
	bg.color = Color("f6f2e6")
	bg.size = Vector2(512, 560)
	_hit_sv.add_child(bg)
	var font := Props.sign_font()
	var fs := 84
	while fs > 20 and font.get_string_size(sgn.split("\n")[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > 440.0:
		fs -= 2
	for ln in sgn.split("\n"):
		while fs > 20 and font.get_string_size(ln, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > 440.0:
			fs -= 2
	var lb := Label.new()
	lb.text = sgn
	lb.add_theme_font_override("font", font)
	lb.add_theme_font_size_override("font_size", fs)
	lb.add_theme_color_override("font_color", Color("120c0c"))
	lb.add_theme_constant_override("line_spacing", 6)
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lb.size = Vector2(512, 560)
	_hit_sv.add_child(lb)
	_hit_sv.render_target_update_mode = SubViewport.UPDATE_ONCE


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_hit_sign_draw()


func _fg_build() -> void:
	var gold := Color("d4a640")
	for f in _FG:
		var id: String = f[0]
		var p := Person.new(f[4])
		p.set_meta("spk", f[1])
		p.set_meta("no_talk", true)
		p.set_meta("no_unclip", true)      # sandalyenin üstündeki Napolyon zemine indirilmesin
		# Sessiz "sohbet" (Person._ambient_chat) yok: konuşuyor gibi görünüp ses vermiyorlardı. Konuşmaları artık
		# oyuncu yaklaşınca sesli atışma (_amb_*); o sırada konuşan karşısındakine döner.
		p.set_meta("no_chat", true)
		add_child(p)
		p.position = f[2]
		p.rotation_degrees.y = f[3]
		_fg[id] = p
		_fg_yaw[id] = f[3]
		if id in _FG_SIT:
			var stw := SeatTwist.new()
			stw.name = "SeatTwist"
			stw.rest_yaw = deg_to_rad(float(f[3]))
			stw.astride = _FG_POSE.get(id, "") == "sit_astride"
			stw.max_torso = 0.6 if stw.astride else 0.75
			stw.max_head = 1.3 if stw.astride else 1.2
			p.add_child(stw)
		match id:
			"hit":     # ceza köşesi: girişin tam karşısında, arka duvara dönük ayakta; yerde bantlı kare, sırtında kâğıt
				_fg_corner(p)
			"cae", "shk":     # çay ocağının tezgâhında ince belli bardak
				var g: Vector3 = f[2] + Vector3(0.62, 1.1, -0.1 if id == "cae" else 0.1)
				Props.cyl(self, 0.03, 0.09, g, Color("a8381c"), Vector3.ZERO, 8, 0.036)
				Props.cyl(self, 0.045, 0.006, g - Vector3(0, 0.048, 0), Color("e8e4dc"), Vector3.ZERO, 10)
			"gui":     # sopanın ucunda tur bayrağı (2187)
				Props.cyl(p, 0.012, 1.5, Vector3(0.3, 1.25, 0.12), C_METAL, Vector3.ZERO, 6)
				Props.box(p, Vector3(0.02, 0.24, 0.36), Vector3(0.3, 1.88, 0.3), Color("ff6a2a"), Vector3.ZERO, 0.6)
			"arc":     # elinde fırça
				Props.cyl(p, 0.012, 0.22, Vector3(0.3, 0.86, 0.16), C_WOOD, Vector3(40, 0, 0), 6)
				Props.box(p, Vector3(0.05, 0.06, 0.03), Vector3(0.3, 0.95, 0.25), Color("e8d8b0"), Vector3(40, 0, 0))
		FigCostume.dress(id, p)      # kostümler (fig_costume.gd): Napolyon'un şapkası, Cengiz Han'ın zırhı, Kanuni'nin kavuğu...
		# İsim kartı (göğüste, sol): Büro herkese takar. Gövdeye takılır: oturan kişinin gövdesi çöker, kişiye
		# takılı kart ayakta göğüs yüksekliğinde kalıp çeneye biniyordu (Marco Polo, Mozart)
		var bz := 0.27 if not f[4].has("robe") else 0.3
		var tb: Node3D = p._body
		Props.box(tb, Vector3(0.15, 0.1, 0.008), Vector3(-0.09, 1.2, bz), Color("f6f2e6"), Vector3(0, -12, 0))
		Props.box(tb, Vector3(0.15, 0.026, 0.009), Vector3(-0.09, 1.243, bz + 0.001), Color("b8323a"), Vector3(0, -12, 0))
		# Yazı kartın içine sığar (0,15 m kart, 0,13 m yazı): "Marco Polo", "Leonardo da Vinci" kartın dışına taşıyordu
		_lbl(tb, f[5], f[6], Vector3(-0.09, 1.19, bz + 0.006), 7, Color("1a1a1a"), Vector3(0, -12, 0), 0.13)
		var sits: bool = id in _FG_SIT
		if sits:
			p.set_activity(_FG_POSE.get(id, "sit"))
		elif _FG_POSE.has(id):
			p.set_activity(_FG_POSE[id])   # imza duruşu: Cengiz Han kollar kavuşuk, Napolyon eli yeleğinde
		_reg("bur_fg_" + id, Vector3(0.5, 1.4, 0.5) if sits else Vector3(0.7, 1.8, 0.7), f[2] + Vector3(0, 0.7 if sits else 0.9, 0), "UI_PROMPT3_TALK", _fg_talk.bind(id), null, false)
		_prompt_args["bur_fg_" + id] = f[1]
		# Uzaktan çizilmez: yalnız bekleme salonundan ve koridorun başından görünürler
		var st: Array = [p]
		while st.size() > 0:
			var n: Node = st.pop_back()
			st.append_array(n.get_children())
			if n is GeometryInstance3D:
				(n as GeometryInstance3D).visibility_range_end = 24.0
	# Hitler sıranın sonunda, herkesten bir adım uzakta; arkasındaki duvarda kırmızı "RED" damgalı başvurusu asılı
	var form := Props.box(self, Vector3(0.006, 0.3, 0.22), Vector3(-8.47, 1.5, -4.2), C_PAPER, Vector3(0, 0, 4))
	_lbl(form, "RED", "REJECTED", Vector3(0.006, 0.0, 0.0), 22, Color("b8323a"), Vector3(0, 90, 10), 0.2)


## Konuşulan figür oyuncuya döner, birkaç saniye sonra yine sıraya bakar
## Oturanlar (_FG_SIT) için kök sabit, yalnız SeatTwist döner; ayaktakiler eskisi gibi look_target ile bütün gövdeyle
func _look(p: Person, t: Node3D) -> void:
	var st := p.get_node_or_null("SeatTwist") as SeatTwist
	if st != null:
		st.target = t
	else:
		p.look_target = t


func _fg_face(id: String, secs: float) -> void:
	var p: Person = _fg.get(id)
	if not is_instance_valid(p) or player == null:
		return
	if id != "hit":
		_look(p, player)       # Hitler ceza köşesinde: konuşurken de duvara bakar (omzunun üstünden konuşur)
	p.talking = true
	get_tree().create_timer(secs).timeout.connect(_fg_unface.bind(id))


func _fg_unface(id: String) -> void:
	var p: Person = _fg.get(id)
	if not is_instance_valid(p):
		return
	_look(p, null)
	p.talking = false
	if p.get_node_or_null("SeatTwist") != null:
		return      # oturanın kökü hiç dönmedi; SeatTwist kendiliğinden geri sarar
	var tw := p.create_tween()
	tw.tween_property(p, "rotation:y", deg_to_rad(float(_fg_yaw[id])), 0.6).set_trans(Tween.TRANS_SINE)


## Sırayla söylenen kısa sahne: [[kimlik, anahtar, süre], ...]
func _fg_seq(lines: Array) -> void:
	_fg_busy = true
	for l in lines:
		var id: String = l[0]
		var secs: float = l[2]
		if not is_inside_tree():
			return
		_say(l[1], secs, _fg_spk(id))
		_fg_face(id, secs + 0.4)
		if l.size() > 3 and _fg.has(l[3]) and id != "hit":
			_look(_fg[id] as Person, _fg[l[3]])       # atışmada karşısındakine döner (Hitler duvara bakmaya devam)
		await get_tree().create_timer(secs + 0.2).timeout
	_fg_busy = false


func _fg_spk(id: String) -> String:
	for f in _FG:
		if f[0] == id:
			return f[1]
	return bark_speaker


# ---------------------------------------------------------------- Kendi aralarında atışma (v0.99.101)
## Kullanıcı: "karakterler birbirleriyle hep konuşur halde gibi gözüküyor ama yanlarına gidiyorsun ses yok; doğal
## hallerinde birbirine laf atmalı ve biz yaklaştıkça duymalıyız". Oyuncu bir grubun ~6,5 m yakınına gelince grup
## sıradaki atışmasını kendi arasında oynar: ses konuşanın ağzından gelir (3B, uzaklaştıkça kısılır), başının üstünde
## konuşma balonu çıkar, konuşan karşısındakine döner (Hitler duvara bakmaya devam eder). Oyuncu uzaklaşınca, bir konuşma
## kutusu açılınca ya da bir figürle konuşulunca keser. Test botunda kapalı.
const _AMB := {
	"G1": [[["BUR_AMB_G1_1_1", "NAPOLEON"], ["BUR_AMB_G1_1_2", "GENGHIS"]],
		[["BUR_AMB_G1_2_1", "NAPOLEON"], ["BUR_AMB_G1_2_2", "GENGHIS"], ["BUR_AMB_G1_2_3", "NAPOLEON"], ["BUR_AMB_G1_2_4", "GENGHIS"]],
		[["BUR_AMB_G1_3_1", "GENGHIS"], ["BUR_AMB_G1_3_2", "NAPOLEON"], ["BUR_AMB_G1_3_3", "GENGHIS"]],
		[["BUR_AMB_G1_4_1", "NAPOLEON"], ["BUR_AMB_G1_4_2", "GENGHIS"], ["BUR_AMB_G1_4_3", "NAPOLEON"]],
		[["BUR_AMB_G1_5_1", "GENGHIS"], ["BUR_AMB_G1_5_2", "NAPOLEON"], ["BUR_AMB_G1_5_3", "GENGHIS"]],
		[["BUR_AMB_G1_6_1", "NAPOLEON"], ["BUR_AMB_G1_6_2", "GENGHIS"], ["BUR_AMB_G1_6_3", "NAPOLEON"]],
		[["BUR_AMB_G1_7_1", "GENGHIS"], ["BUR_AMB_G1_7_2", "NAPOLEON"], ["BUR_AMB_G1_7_3", "GENGHIS"]],
		[["BUR_AMB_G1_8_1", "NAPOLEON"], ["BUR_AMB_G1_8_2", "GENGHIS"], ["BUR_AMB_G1_8_3", "NAPOLEON"]],
		[["BUR_AMB_G1_9_1", "GENGHIS"], ["BUR_AMB_G1_9_2", "NAPOLEON"], ["BUR_AMB_G1_9_3", "GENGHIS"], ["BUR_AMB_G1_9_4", "NAPOLEON"]]],
	"G2": [[["BUR_AMB_G2_1_1", "ROBOT"], ["BUR_AMB_G2_1_2", "HITLER"], ["BUR_AMB_G2_1_3", "ROBOT"]],
		[["BUR_AMB_G2_2_1", "NAPOLEON"], ["BUR_AMB_G2_2_2", "HITLER"], ["BUR_AMB_G2_2_3", "ROBOT"]],
		[["BUR_AMB_G2_3_1", "HITLER"], ["BUR_AMB_G2_3_2", "ROBOT"], ["BUR_AMB_G2_3_3", "HITLER"], ["BUR_AMB_G2_3_4", "ROBOT"]],
		[["BUR_AMB_G2_4_1", "ROBOT"], ["BUR_AMB_G2_4_2", "HITLER"], ["BUR_AMB_G2_4_3", "ROBOT"]],
		[["BUR_AMB_G2_5_1", "NAPOLEON"], ["BUR_AMB_G2_5_2", "ROBOT"], ["BUR_AMB_G2_5_3", "HITLER"]],
		[["BUR_AMB_G2_6_1", "HITLER"], ["BUR_AMB_G2_6_2", "ROBOT"], ["BUR_AMB_G2_6_3", "HITLER"], ["BUR_AMB_G2_6_4", "ROBOT"]],
		[["BUR_AMB_G2_7_1", "ROBOT"], ["BUR_AMB_G2_7_2", "HITLER"], ["BUR_AMB_G2_7_3", "ROBOT"]],
		[["BUR_AMB_G2_8_1", "NAPOLEON"], ["BUR_AMB_G2_8_2", "HITLER"], ["BUR_AMB_G2_8_3", "ROBOT"]],
		[["BUR_AMB_G2_9_1", "ROBOT"], ["BUR_AMB_G2_9_2", "HITLER"], ["BUR_AMB_G2_9_3", "ROBOT"]]],
	"G3": [[["BUR_AMB_G3_1_1", "MARCOPOLO"], ["BUR_AMB_G3_1_2", "GALILEO"], ["BUR_AMB_G3_1_3", "MARCOPOLO"]],
		[["BUR_AMB_G3_2_1", "GALILEO"], ["BUR_AMB_G3_2_2", "MARCOPOLO"], ["BUR_AMB_G3_2_3", "GALILEO"]],
		[["BUR_AMB_G3_3_1", "MARCOPOLO"], ["BUR_AMB_G3_3_2", "GALILEO"], ["BUR_AMB_G3_3_3", "MARCOPOLO"]],
		[["BUR_AMB_G3_4_1", "MARCOPOLO"], ["BUR_AMB_G3_4_2", "GALILEO"], ["BUR_AMB_G3_4_3", "MARCOPOLO"]],
		[["BUR_AMB_G3_5_1", "MARCOPOLO"], ["BUR_AMB_G3_5_2", "GALILEO"], ["BUR_AMB_G3_5_3", "MARCOPOLO"]],
		[["BUR_AMB_G3_6_1", "GALILEO"], ["BUR_AMB_G3_6_2", "MARCOPOLO"], ["BUR_AMB_G3_6_3", "GALILEO"]],
		[["BUR_AMB_G3_7_1", "GALILEO"], ["BUR_AMB_G3_7_2", "MARCOPOLO"], ["BUR_AMB_G3_7_3", "GALILEO"]],
		[["BUR_AMB_G3_8_1", "MARCOPOLO"], ["BUR_AMB_G3_8_2", "GALILEO"], ["BUR_AMB_G3_8_3", "MARCOPOLO"]]],
	"G4": [[["BUR_AMB_G4_1_1", "MOZART"], ["BUR_AMB_G4_1_2", "CURIE"], ["BUR_AMB_G4_1_3", "MOZART"]],
		[["BUR_AMB_G4_2_1", "CURIE"], ["BUR_AMB_G4_2_2", "MOZART"], ["BUR_AMB_G4_2_3", "CURIE"]],
		[["BUR_AMB_G4_3_1", "MOZART"], ["BUR_AMB_G4_3_2", "CURIE"], ["BUR_AMB_G4_3_3", "MOZART"]],
		[["BUR_AMB_G4_4_1", "CURIE"], ["BUR_AMB_G4_4_2", "MOZART"], ["BUR_AMB_G4_4_3", "CURIE"]],
		[["BUR_AMB_G4_5_1", "MOZART"], ["BUR_AMB_G4_5_2", "CURIE"], ["BUR_AMB_G4_5_3", "MOZART"]],
		[["BUR_AMB_G4_6_1", "CURIE"], ["BUR_AMB_G4_6_2", "MOZART"], ["BUR_AMB_G4_6_3", "CURIE"]],
		[["BUR_AMB_G4_7_1", "MOZART"], ["BUR_AMB_G4_7_2", "CURIE"], ["BUR_AMB_G4_7_3", "MOZART"]],
		[["BUR_AMB_G4_8_1", "MOZART"], ["BUR_AMB_G4_8_2", "CURIE"], ["BUR_AMB_G4_8_3", "MOZART"]]],
	"G5": [[["BUR_AMB_G5_1_1", "SINAN"], ["BUR_AMB_G5_1_2", "NASREDDIN"]],
		[["BUR_AMB_G5_2_1", "NASREDDIN"], ["BUR_AMB_G5_2_2", "SINAN"], ["BUR_AMB_G5_2_3", "NASREDDIN"]],
		[["BUR_AMB_G5_3_1", "SINAN"], ["BUR_AMB_G5_3_2", "NASREDDIN"], ["BUR_AMB_G5_3_3", "SINAN"], ["BUR_AMB_G5_3_4", "NASREDDIN"]],
		[["BUR_AMB_G5_4_1", "NASREDDIN"], ["BUR_AMB_G5_4_2", "SINAN"], ["BUR_AMB_G5_4_3", "NASREDDIN"], ["BUR_AMB_G5_4_4", "SINAN"]],
		[["BUR_AMB_G5_5_1", "SINAN"], ["BUR_AMB_G5_5_2", "NASREDDIN"], ["BUR_AMB_G5_5_3", "SINAN"]],
		[["BUR_AMB_G5_6_1", "NASREDDIN"], ["BUR_AMB_G5_6_2", "SINAN"], ["BUR_AMB_G5_6_3", "NASREDDIN"]],
		[["BUR_AMB_G5_7_1", "SINAN"], ["BUR_AMB_G5_7_2", "NASREDDIN"], ["BUR_AMB_G5_7_3", "SINAN"]],
		[["BUR_AMB_G5_8_1", "NASREDDIN"], ["BUR_AMB_G5_8_2", "SINAN"], ["BUR_AMB_G5_8_3", "NASREDDIN"]]],
	"G6": [[["BUR_AMB_G6_1_1", "GALILEO"], ["BUR_AMB_G6_1_2", "GAGARIN"], ["BUR_AMB_G6_1_3", "GALILEO"]],
		[["BUR_AMB_G6_2_1", "GAGARIN"], ["BUR_AMB_G6_2_2", "GALILEO"], ["BUR_AMB_G6_2_3", "GAGARIN"]],
		[["BUR_AMB_G6_3_1", "GAGARIN"], ["BUR_AMB_G6_3_2", "GALILEO"], ["BUR_AMB_G6_3_3", "GAGARIN"]],
		[["BUR_AMB_G6_4_1", "GAGARIN"], ["BUR_AMB_G6_4_2", "GALILEO"], ["BUR_AMB_G6_4_3", "GAGARIN"], ["BUR_AMB_G6_4_4", "GALILEO"]],
		[["BUR_AMB_G6_5_1", "GALILEO"], ["BUR_AMB_G6_5_2", "GAGARIN"], ["BUR_AMB_G6_5_3", "GALILEO"], ["BUR_AMB_G6_5_4", "GAGARIN"]],
		[["BUR_AMB_G6_6_1", "GALILEO"], ["BUR_AMB_G6_6_2", "GAGARIN"], ["BUR_AMB_G6_6_3", "GALILEO"]],
		[["BUR_AMB_G6_7_1", "GAGARIN"], ["BUR_AMB_G6_7_2", "GALILEO"], ["BUR_AMB_G6_7_3", "GAGARIN"]],
		[["BUR_AMB_G6_8_1", "GALILEO"], ["BUR_AMB_G6_8_2", "GAGARIN"], ["BUR_AMB_G6_8_3", "GALILEO"]],
		[["BUR_AMB_G6_9_1", "GAGARIN"], ["BUR_AMB_G6_9_2", "GALILEO"], ["BUR_AMB_G6_9_3", "GAGARIN"]]],
	"G7": [[["BUR_AMB_G7_1_1", "CAESAR"], ["BUR_AMB_G7_1_2", "SHAKESPEARE"], ["BUR_AMB_G7_1_3", "CAESAR"]],
		[["BUR_AMB_G7_2_1", "CAESAR"], ["BUR_AMB_G7_2_2", "SHAKESPEARE"], ["BUR_AMB_G7_2_3", "CAESAR"]],
		[["BUR_AMB_G7_3_1", "CAESAR"], ["BUR_AMB_G7_3_2", "NECMI"]],
		[["BUR_AMB_G7_4_1", "CAESAR"], ["BUR_AMB_G7_4_2", "SHAKESPEARE"], ["BUR_AMB_G7_4_3", "CAESAR"]],
		[["BUR_AMB_G7_5_1", "CAESAR"], ["BUR_AMB_G7_5_2", "SHAKESPEARE"], ["BUR_AMB_G7_5_3", "NECMI"]],
		[["BUR_AMB_G7_6_1", "SHAKESPEARE"], ["BUR_AMB_G7_6_2", "NECMI"], ["BUR_AMB_G7_6_3", "CAESAR"]],
		[["BUR_AMB_G7_7_1", "CAESAR"], ["BUR_AMB_G7_7_2", "SHAKESPEARE"], ["BUR_AMB_G7_7_3", "CAESAR"], ["BUR_AMB_G7_7_4", "NECMI"]],
		[["BUR_AMB_G7_8_1", "SHAKESPEARE"], ["BUR_AMB_G7_8_2", "CAESAR"], ["BUR_AMB_G7_8_3", "SHAKESPEARE"], ["BUR_AMB_G7_8_4", "NECMI"]],
		[["BUR_AMB_G7_9_1", "SHAKESPEARE"], ["BUR_AMB_G7_9_2", "CAESAR"], ["BUR_AMB_G7_9_3", "NECMI"]]],
	"G8": [[["BUR_AMB_G8_1_1", "COLUMBUS"], ["BUR_AMB_G8_1_2", "SABRI"], ["BUR_AMB_G8_1_3", "COLUMBUS"], ["BUR_AMB_G8_1_4", "SABRI"]],
		[["BUR_AMB_G8_2_1", "COLUMBUS"], ["BUR_AMB_G8_2_2", "SABRI"], ["BUR_AMB_G8_2_3", "COLUMBUS"], ["BUR_AMB_G8_2_4", "SABRI"]],
		[["BUR_AMB_G8_3_1", "COLUMBUS"], ["BUR_AMB_G8_3_2", "SABRI"], ["BUR_AMB_G8_3_3", "COLUMBUS"], ["BUR_AMB_G8_3_4", "SABRI"]],
		[["BUR_AMB_G8_4_1", "COLUMBUS"], ["BUR_AMB_G8_4_2", "SABRI"], ["BUR_AMB_G8_4_3", "COLUMBUS"], ["BUR_AMB_G8_4_4", "SABRI"]],
		[["BUR_AMB_G8_5_1", "COLUMBUS"], ["BUR_AMB_G8_5_2", "SABRI"], ["BUR_AMB_G8_5_3", "COLUMBUS"], ["BUR_AMB_G8_5_4", "SABRI"]],
		[["BUR_AMB_G8_6_1", "COLUMBUS"], ["BUR_AMB_G8_6_2", "SABRI"], ["BUR_AMB_G8_6_3", "COLUMBUS"], ["BUR_AMB_G8_6_4", "SABRI"]],
		[["BUR_AMB_G8_7_1", "COLUMBUS"], ["BUR_AMB_G8_7_2", "SABRI"], ["BUR_AMB_G8_7_3", "COLUMBUS"], ["BUR_AMB_G8_7_4", "SABRI"]],
		[["BUR_AMB_G8_8_1", "COLUMBUS"], ["BUR_AMB_G8_8_2", "SABRI"], ["BUR_AMB_G8_8_3", "COLUMBUS"], ["BUR_AMB_G8_8_4", "SABRI"]]],
	"G9": [[["BUR_AMB_G9_1_1", "CLEOPATRA"], ["BUR_AMB_G9_1_2", "SULEYMAN"], ["BUR_AMB_G9_1_3", "CLEOPATRA"]],
		[["BUR_AMB_G9_2_1", "SULEYMAN"], ["BUR_AMB_G9_2_2", "CLEOPATRA"]],
		[["BUR_AMB_G9_3_1", "CLEOPATRA"], ["BUR_AMB_G9_3_2", "SULEYMAN"], ["BUR_AMB_G9_3_3", "CLEOPATRA"]],
		[["BUR_AMB_G9_4_1", "CLEOPATRA"], ["BUR_AMB_G9_4_2", "SULEYMAN"], ["BUR_AMB_G9_4_3", "CLEOPATRA"]],
		[["BUR_AMB_G9_5_1", "SULEYMAN"], ["BUR_AMB_G9_5_2", "CLEOPATRA"], ["BUR_AMB_G9_5_3", "SULEYMAN"]],
		[["BUR_AMB_G9_6_1", "CLEOPATRA"], ["BUR_AMB_G9_6_2", "CLEOPATRA"], ["BUR_AMB_G9_6_3", "SULEYMAN"]],
		[["BUR_AMB_G9_7_1", "SULEYMAN"], ["BUR_AMB_G9_7_2", "CLEOPATRA"], ["BUR_AMB_G9_7_3", "SULEYMAN"]],
		[["BUR_AMB_G9_8_1", "CLEOPATRA"], ["BUR_AMB_G9_8_2", "SULEYMAN"], ["BUR_AMB_G9_8_3", "CLEOPATRA"]]],
	"G10": [[["BUR_AMB_G10_1_1", "LEONARDO"], ["BUR_AMB_G10_1_2", "EINSTEIN"], ["BUR_AMB_G10_1_3", "LEONARDO"]],
		[["BUR_AMB_G10_2_1", "EINSTEIN"], ["BUR_AMB_G10_2_2", "LEONARDO"], ["BUR_AMB_G10_2_3", "EINSTEIN"], ["BUR_AMB_G10_2_4", "LEONARDO"]],
		[["BUR_AMB_G10_3_1", "LEONARDO"], ["BUR_AMB_G10_3_2", "EINSTEIN"], ["BUR_AMB_G10_3_3", "LEONARDO"]],
		[["BUR_AMB_G10_4_1", "EINSTEIN"], ["BUR_AMB_G10_4_2", "LEONARDO"], ["BUR_AMB_G10_4_3", "EINSTEIN"]],
		[["BUR_AMB_G10_5_1", "EINSTEIN"], ["BUR_AMB_G10_5_2", "LEONARDO"], ["BUR_AMB_G10_5_3", "EINSTEIN"]],
		[["BUR_AMB_G10_6_1", "LEONARDO"], ["BUR_AMB_G10_6_2", "EINSTEIN"], ["BUR_AMB_G10_6_3", "LEONARDO"]],
		[["BUR_AMB_G10_7_1", "EINSTEIN"], ["BUR_AMB_G10_7_2", "LEONARDO"], ["BUR_AMB_G10_7_3", "EINSTEIN"], ["BUR_AMB_G10_7_4", "LEONARDO"]],
		[["BUR_AMB_G10_8_1", "LEONARDO"], ["BUR_AMB_G10_8_2", "EINSTEIN"], ["BUR_AMB_G10_8_3", "LEONARDO"]]],
	"G11": [[["BUR_AMB_G11_1_1", "GUIDE"], ["BUR_AMB_G11_1_2", "GUIDE"]],
		[["BUR_AMB_G11_2_1", "GUIDE"], ["BUR_AMB_G11_2_2", "GUIDE"]],
		[["BUR_AMB_G11_3_1", "GUIDE"], ["BUR_AMB_G11_3_2", "GUIDE"]],
		[["BUR_AMB_G11_4_1", "GUIDE"], ["BUR_AMB_G11_4_2", "GUIDE"]],
		[["BUR_AMB_G11_5_1", "GUIDE"], ["BUR_AMB_G11_5_2", "GUIDE"]],
		[["BUR_AMB_G11_6_1", "GUIDE"], ["BUR_AMB_G11_6_2", "GUIDE"]],
		[["BUR_AMB_G11_7_1", "GUIDE"], ["BUR_AMB_G11_7_2", "GUIDE"]],
		[["BUR_AMB_G11_8_1", "GUIDE"], ["BUR_AMB_G11_8_2", "GUIDE"]]],
	"G12": [[["BUR_AMB_G12_1_1", "ARCHAEOLOGIST"], ["BUR_AMB_G12_1_2", "ARCHAEOLOGIST"]],
		[["BUR_AMB_G12_2_1", "ARCHAEOLOGIST"], ["BUR_AMB_G12_2_2", "ARCHAEOLOGIST"]],
		[["BUR_AMB_G12_3_1", "ARCHAEOLOGIST"], ["BUR_AMB_G12_3_2", "ARCHAEOLOGIST"]],
		[["BUR_AMB_G12_4_1", "ARCHAEOLOGIST"], ["BUR_AMB_G12_4_2", "ARCHAEOLOGIST"]],
		[["BUR_AMB_G12_5_1", "ARCHAEOLOGIST"], ["BUR_AMB_G12_5_2", "ARCHAEOLOGIST"]],
		[["BUR_AMB_G12_6_1", "ARCHAEOLOGIST"], ["BUR_AMB_G12_6_2", "ARCHAEOLOGIST"]],
		[["BUR_AMB_G12_7_1", "ARCHAEOLOGIST"], ["BUR_AMB_G12_7_2", "ARCHAEOLOGIST"]],
		[["BUR_AMB_G12_8_1", "ARCHAEOLOGIST"], ["BUR_AMB_G12_8_2", "ARCHAEOLOGIST"]]],
	"G13": [[["BUR_AMB_G13_1_1", "TESLA"], ["BUR_AMB_G13_1_2", "EDISON"], ["BUR_AMB_G13_1_3", "TESLA"]],
		[["BUR_AMB_G13_2_1", "EDISON"], ["BUR_AMB_G13_2_2", "TESLA"], ["BUR_AMB_G13_2_3", "EDISON"], ["BUR_AMB_G13_2_4", "TESLA"]],
		[["BUR_AMB_G13_3_1", "TESLA"], ["BUR_AMB_G13_3_2", "EDISON"], ["BUR_AMB_G13_3_3", "TESLA"]],
		[["BUR_AMB_G13_4_1", "TESLA"], ["BUR_AMB_G13_4_2", "EDISON"], ["BUR_AMB_G13_4_3", "TESLA"]],
		[["BUR_AMB_G13_5_1", "EDISON"], ["BUR_AMB_G13_5_2", "TESLA"], ["BUR_AMB_G13_5_3", "EDISON"]],
		[["BUR_AMB_G13_6_1", "EINSTEIN"], ["BUR_AMB_G13_6_2", "TESLA"], ["BUR_AMB_G13_6_3", "EDISON"]],
		[["BUR_AMB_G13_7_1", "TESLA"], ["BUR_AMB_G13_7_2", "EDISON"], ["BUR_AMB_G13_7_3", "TESLA"], ["BUR_AMB_G13_7_4", "EDISON"]]],
	"G14": [[["BUR_AMB_G14_1_1", "SOCRATES"], ["BUR_AMB_G14_1_2", "DIOGENES"], ["BUR_AMB_G14_1_3", "SOCRATES"], ["BUR_AMB_G14_1_4", "DIOGENES"]],
		[["BUR_AMB_G14_2_1", "DIOGENES"], ["BUR_AMB_G14_2_2", "SOCRATES"], ["BUR_AMB_G14_2_3", "DIOGENES"]],
		[["BUR_AMB_G14_3_1", "SOCRATES"], ["BUR_AMB_G14_3_2", "DIOGENES"], ["BUR_AMB_G14_3_3", "SOCRATES"]],
		[["BUR_AMB_G14_4_1", "DIOGENES"], ["BUR_AMB_G14_4_2", "SOCRATES"], ["BUR_AMB_G14_4_3", "DIOGENES"]],
		[["BUR_AMB_G14_5_1", "SOCRATES"], ["BUR_AMB_G14_5_2", "DIOGENES"], ["BUR_AMB_G14_5_3", "SOCRATES"]],
		[["BUR_AMB_G14_6_1", "SOCRATES"], ["BUR_AMB_G14_6_2", "DIOGENES"], ["BUR_AMB_G14_6_3", "SOCRATES"]],
		[["BUR_AMB_G14_7_1", "ARCHAEOLOGIST"], ["BUR_AMB_G14_7_2", "SOCRATES"], ["BUR_AMB_G14_7_3", "DIOGENES"]]],
	"G15": [[["BUR_AMB_G15_1_1", "NEWTON"], ["BUR_AMB_G15_1_2", "EINSTEIN"], ["BUR_AMB_G15_1_3", "NEWTON"]],
		[["BUR_AMB_G15_2_1", "NEWTON"], ["BUR_AMB_G15_2_2", "EINSTEIN"], ["BUR_AMB_G15_2_3", "LEONARDO"]],
		[["BUR_AMB_G15_3_1", "NEWTON"], ["BUR_AMB_G15_3_2", "EINSTEIN"], ["BUR_AMB_G15_3_3", "NEWTON"]],
		[["BUR_AMB_G15_4_1", "NEWTON"], ["BUR_AMB_G15_4_2", "EINSTEIN"], ["BUR_AMB_G15_4_3", "LEONARDO"]],
		[["BUR_AMB_G15_5_1", "NEWTON"], ["BUR_AMB_G15_5_2", "EINSTEIN"], ["BUR_AMB_G15_5_3", "NEWTON"]],
		[["BUR_AMB_G15_6_1", "NEWTON"], ["BUR_AMB_G15_6_2", "EINSTEIN"], ["BUR_AMB_G15_6_3", "NEWTON"], ["BUR_AMB_G15_6_4", "EINSTEIN"]],
		[["BUR_AMB_G15_7_1", "LEONARDO"], ["BUR_AMB_G15_7_2", "NEWTON"], ["BUR_AMB_G15_7_3", "LEONARDO"]]],
	"G16": [[["BUR_AMB_G16_1_1", "SABRI"], ["BUR_AMB_G16_1_2", "EVLIYA"], ["BUR_AMB_G16_1_3", "SABRI"]],
		[["BUR_AMB_G16_2_1", "EVLIYA"], ["BUR_AMB_G16_2_2", "SABRI"], ["BUR_AMB_G16_2_3", "EVLIYA"]],
		[["BUR_AMB_G16_3_1", "COLUMBUS"], ["BUR_AMB_G16_3_2", "EVLIYA"], ["BUR_AMB_G16_3_3", "SABRI"]],
		[["BUR_AMB_G16_4_1", "EVLIYA"], ["BUR_AMB_G16_4_2", "COLUMBUS"], ["BUR_AMB_G16_4_3", "SABRI"]],
		[["BUR_AMB_G16_5_1", "EVLIYA"], ["BUR_AMB_G16_5_2", "SABRI"], ["BUR_AMB_G16_5_3", "COLUMBUS"], ["BUR_AMB_G16_5_4", "SABRI"]],
		[["BUR_AMB_G16_6_1", "SABRI"], ["BUR_AMB_G16_6_2", "EVLIYA"], ["BUR_AMB_G16_6_3", "SABRI"], ["BUR_AMB_G16_6_4", "COLUMBUS"]],
		[["BUR_AMB_G16_7_1", "COLUMBUS"], ["BUR_AMB_G16_7_2", "EVLIYA"], ["BUR_AMB_G16_7_3", "SABRI"]]],
}

const _AMB_SPK := {"NAPOLEON": "nap", "GENGHIS": "gen", "ROBOT": "rob", "HITLER": "hit", "MARCOPOLO": "pol",
	"GALILEO": "gal", "MOZART": "moz", "CURIE": "cur", "SINAN": "sin", "NASREDDIN": "nas", "GAGARIN": "gag",
	"CAESAR": "cae", "SHAKESPEARE": "shk", "COLUMBUS": "col", "CLEOPATRA": "cle", "SULEYMAN": "sul",
	"LEONARDO": "leo", "EINSTEIN": "ein", "GUIDE": "gui", "ARCHAEOLOGIST": "arc", "TESLA": "tes", "EDISON": "edi",
	"SOCRATES": "sok", "DIOGENES": "dio", "NEWTON": "new", "EVLIYA": "evl"}
const _AMB_NEAR := 6.5
const _AMB_FAR := 10.0
var _amb_on := false
var _amb_t := 0.0
var _amb_cool := {}          # grup → sıradaki atışmanın en erken zamanı (_fog_t)
var _amb_idx := {}           # grup → sıradaki atışma
var _amb_run := ""           # şu an oynayan grup
var _amb_tok := 0            # kesilince eski döngü kendini bırakır
var _amb_snd: AudioStreamPlayer3D
var _amb_bub: Label3D
var _amb_who: Person
var _amb_looked: Array = []  # bakışı karşısındakine çevrilenler (atışma bitince serbest)
var _wait_said := false      # bekleme salonuna ilk girişte Nihat'ın açıklaması (ziyaret başına bir kez)


func _amb_setup() -> void:
	if GameState.autotest:
		return
	_amb_snd = AudioStreamPlayer3D.new()
	_amb_snd.bus = "Voice"
	_amb_snd.unit_size = 3.0
	_amb_snd.max_distance = 16.0
	add_child(_amb_snd)
	_amb_bub = Label3D.new()
	_amb_bub.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_amb_bub.font_size = 30
	_amb_bub.pixel_size = 0.0016
	_amb_bub.outline_size = 10
	_amb_bub.modulate = Color("fffaf0")
	_amb_bub.outline_modulate = Color("1a1a22")
	_amb_bub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_amb_bub.width = 560.0
	_amb_bub.visible = false
	add_child(_amb_bub)
	_amb_on = true


func _amb_person(code: String) -> Person:
	match code:
		"NECMI":
			return _rb_necmi_p
		"SABRI":
			return _rb_sabri_p
	var id: String = _AMB_SPK.get(code, "")
	if id == "" or not _fg.has(id):
		return null
	return _fg[id] as Person


func _amb_center(g: String) -> Vector3:
	var sum := Vector3.ZERO
	var n := 0
	for ex: Array in _AMB[g]:
		for l: Array in ex:
			var p := _amb_person(l[1])
			if is_instance_valid(p):
				sum += p.global_position
				n += 1
	return sum / n if n > 0 else Vector3(0, -100, 0)


func _amb_tick(delta: float) -> void:
	if not _amb_on:
		return
	_amb_t -= delta
	if _amb_t > 0.0:
		return
	_amb_t = 0.4
	if not is_instance_valid(player):
		return
	var pp := player.global_position
	_wait_check(pp)
	var quiet := _fg_busy or (hud != null and hud.line_open) or get_tree().paused
	if _amb_run != "":
		if quiet or pp.distance_to(_amb_center(_amb_run)) > _AMB_FAR:
			_amb_stop()
		return
	if quiet:
		return
	var best := ""
	var bd := _AMB_NEAR
	for g: String in _AMB:
		if _fog_t < float(_amb_cool.get(g, 0.0)):
			continue
		var d := pp.distance_to(_amb_center(g))
		if d < bd:
			bd = d
			best = g
	if best != "":
		_amb_play(best)


func _amb_play(g: String) -> void:
	var exs: Array = _AMB[g]
	var i: int = _amb_idx.get(g, 0)
	_amb_idx[g] = i + 1
	_amb_run = g
	_amb_tok += 1
	var tok := _amb_tok
	var ex: Array = exs[i % exs.size()]
	for j in ex.size():
		if tok != _amb_tok or not is_inside_tree():
			return
		var l: Array = ex[j]
		var who := _amb_person(l[1])
		if not is_instance_valid(who):
			continue
		var other: Person = null
		for k in range(1, ex.size()):        # karşısındaki: sıradaki ya da önceki farklı konuşan
			for m: int in [j + k, j - k]:
				if other == null and m >= 0 and m < ex.size() and ex[m][1] != l[1]:
					other = _amb_person(ex[m][1])
		var secs := _amb_say(who, l[0], other)
		await get_tree().create_timer(secs + 0.45).timeout
	if tok != _amb_tok:
		return
	_amb_cool[g] = _fog_t + 4.0      # yakında durdukça konuşma sürer (kullanıcı: "hep devam etmeli"); sıradaki atışmaya geçer
	_amb_quiet()
	_amb_run = ""


func _amb_say(who: Person, key: String, other: Person) -> float:
	var vs: AudioStream = hud.voice_stream(key) if hud else null
	var secs := 1.4 + tr(key).length() * 0.06
	if vs:
		secs = maxf(GameState.voice_len(vs), 0.8)
		_amb_snd.stream = vs
		_amb_snd.volume_db = VoiceGain.db(key) - 3.0
		_amb_snd.global_position = who._head.global_position
		_amb_snd.play()
	_amb_bub.text = tr(key)
	_amb_bub.global_position = who._head.global_position + Vector3(0, 0.55, 0)
	_amb_bub.visible = true
	if is_instance_valid(_amb_who) and _amb_who != who:
		_amb_who.talking = false
	_amb_who = who
	who.talking = true
	if is_instance_valid(other) and who != _fg.get("hit"):
		_look(who, other)
		if not who in _amb_looked:
			_amb_looked.append(who)
	return secs


func _amb_stop() -> void:
	_amb_tok += 1
	if _amb_run != "":
		_amb_cool[_amb_run] = _fog_t + 2.0
	_amb_quiet()
	_amb_run = ""


func _amb_quiet() -> void:
	if _amb_snd:
		_amb_snd.stop()
	if _amb_bub:
		_amb_bub.visible = false
	if is_instance_valid(_amb_who):
		_amb_who.talking = false
	_amb_who = null
	for p in _amb_looked:
		if is_instance_valid(p):
			_look(p as Person, null)
	_amb_looked.clear()


## Bekleme salonu = Tarihe İtiraz Birimi. Kullanıcı: "tarihi figürler neden sıra bekliyor, açık ve net değil".
## Duvarda birimin levhası; Nihat salona ilk girişinde ne olduğunu söyler (ziyaret başına bir kez, yalnız Nihat).
func _wait_check(pp: Vector3) -> void:
	if _wait_said or pp.x > -3.0 or pp.z > -3.6 or pp.z < -11.4:
		return
	if player.hand_style != "nihat" or _fg_busy or (hud != null and hud.line_open):
		return
	_wait_said = true
	_say("BUR_WAIT_N_%d" % _fg_tier(), 7.0)


func _wait_sign() -> void:
	var x := -8.48
	var z := -5.25
	Props.box(self, Vector3(0.04, 0.78, 1.7), Vector3(x, 2.25, z), Color("1d3f5a"))
	Props.box(self, Vector3(0.045, 0.8, 0.03), Vector3(x, 2.25, z - 0.86), C_BRASS)
	Props.box(self, Vector3(0.045, 0.8, 0.03), Vector3(x, 2.25, z + 0.86), C_BRASS)
	Props.label(self, tr("BUR_WAIT_SIGN_1"), Vector3(x + 0.025, 2.47, z), 44, Color("f6e7b8"), Vector3(0, 90, 0), 1.55)
	Props.label(self, tr("BUR_WAIT_SIGN_2").replace(". ", ".\n"), Vector3(x + 0.025, 2.07, z), 22, Color("e8eef2"), Vector3(0, 90, 0), 1.5)


## Büro'ya üç ayrı zamanda gelinir: Bölüm 3 (ilk gün), 13-14 (kuşatmadan dönüş), 15 ve sonrası (17, 26, 27, final).
## Figür önce o ziyaretin repliklerini söyler (yenisi önce), sonra eskileri; aynı replik art arda gelmez.
func _fg_tier() -> int:
	var c := GameState.current_chapter
	return 1 if c <= 12 else (2 if c <= 14 else 3)


## İlk ziyaretin listesi: "@" = atışma (Napolyon ile Hitler, Sezar ile Shakespeare)
const _FG_T1 := {"nap": ["BUR_FG_NAP_1", "@", "BUR_FG_NAP_2"], "hit": ["BUR_FG_HIT_1", "@"],
	"cae": ["BUR_FG_CAE_1", "@", "BUR_FG_CAE_2"], "shk": ["BUR_FG_SHK_1", "@", "BUR_FG_SHK_2"]}


func _fg_lines(id: String) -> Array:
	var up := id.to_upper()
	var t1: Array = _FG_T1.get(id, [])
	if t1.is_empty():
		for i in range(1, 4):
			var k := "BUR_FG_%s_%d" % [up, i]
			if tr(k) != k:
				t1.append(k)
	var out: Array = []
	for t in range(_fg_tier(), 1, -1):
		for i in range(1, 3):
			out.append("BUR_FG_%s_V%d_%d" % [up, t, i])
	return out + t1


func _fg_talk(id: String) -> void:
	if _fg_busy:
		return
	var n := _count("bur_fg_" + id) + 1
	_cycles["bur_fg_" + id] = n
	var lines := _fg_lines(id)
	var item: String = lines[(n - 1) % lines.size()]
	if item != "@":
		_fg_seq([[id, item, 5.5]])
	elif id == "nap":
		_fg_seq([["nap", "BUR_FG_NAP_3", 5.0, "hit"], ["hit", "BUR_FG_HIT_R", 2.0, "nap"], ["nap", "BUR_FG_NAP_4", 1.6, "hit"]])
	elif id == "hit":
		_fg_seq([["hit", "BUR_FG_HIT_2", 4.0], ["nap", "BUR_FG_NAP_3", 5.0, "hit"], ["hit", "BUR_FG_HIT_R", 2.0, "nap"], ["nap", "BUR_FG_NAP_4", 1.6, "hit"]])
	else:
		_fg_seq([["cae", "BUR_FG_CAE_3", 5.5, "shk"], ["shk", "BUR_FG_SHK_R", 4.5, "cae"]])