class_name EdirneInterlude
extends Node
## Ara bölüm "ARIZA · Edirne Sarayı, 1444 yazı" (v0.99.6, v0.99.8'de hareket ve hikâye elden geçti; docs/SIEGE.md §8).
## Bölüm 17'nin Büro önsözünde, sözleşme ve kameradan sonra, taraf seçiminden önce: Büro'dan geçen her oyun bir kez görür.
##   0 Kalibrasyon: Nihat makineyi kameraya alıştırmak için beş dakikalık bir atlama ister. Asansörde kadran 1453'e
##     kurulur; çantada leblebi varsa biri kadranın dişlisine kaçar (kıvılcım), yoksa Tolga'nın telefonu çalar. Kadran
##     1444'e kayar: kırmızı arıza girdabı.
##   1 Havuz: Tolga sarayın havuzuna düşer (fes suda yüzer), sudan çıkar. Çınarın altında İskendernâme okuyan on iki
##     yaşındaki Mehmed kitabı kapatır, kalkar, havuza yürür: "Sen Hızır mısın?" (edirne_who). Babası tahtı ona bırakıp
##     Manisa'ya çekilmiştir; Halil Paşa kapıdan yürüyüp eğilir, divana çağırır: tahtta çocuk, işi yürüten vezir.
##   2 Ders: yerde yürünür, basamakta pabuçlar çıkar; Gürânî duvardan değneği alır, herkes minderine oturur (Tolga
##     da: göz hizası iner). "Âlem kadîm mi, hâdis mi?"; Tolga'ya "Dünya nasıldır?" (edirne_answer; "düz"de değnek
##     kalkar, eğilme QTE'si)
##   3 Kütüphane: şehzade raftan İskendernâme'yi alır, açar; usturlabın halkalarını çevirir (Uluğ Bey, Ali Kuşçu);
##     ilk Kayser (edirne_caesar; "Brütüs"te Halil yürüyerek gelir); defterini Tolga'ya uzatır (tuğra, surlu şehir);
##     gelecek (edirne_future); çantada küp (elinde çözer) ya da selfie çubuğu (flaş, karikatür) varsa
##   4 Rehine prensler: Vlad taburesinde gerçekten yontar (çakı, sopa, talaş), Radu nişan tahtasına ok atar; tarihi
##     değiştiren seçim (edirne_vlad: kebab: Radu matbahtan siniyle et getirir, şişler ızgarada E ile çevrilip kızarır /
##     policy: poliçe elden ele, Vlad yüzüğüyle mühürler / legend: duvara yarasa gölgesi, Vlad not alır / none)
##   5 Kaçış: Halil ve muhafızlar kapıdan koşarak gelir; havuza dalış (yakalanan sallanıp havuza atılır). Çocuklar
##     havuz kenarına koşup el sallar. Nihat geri çeker.
##   6 Büro: asansörden sırılsıklam inilir, Nihat peştemal uzatır; Vikipedi farkı; "Bu oyunun adı 'Gerçek Tarih Bu
##     Değil'… Ne yaptın sen?!"; düzeltme damgası, dipnot kalır.
## İzleri: 33o ve 26 (Fatih tanır), 14 (sicil), 15 (İnsanların Akıbeti), 12 (sonraki oyunlarda).
## Yürüyüşler yerdedir (_walk: basamak ve döşeme yüksekliğinde ara noktalar); otomatik testte de hızlı yürünür ve
## Unclip.walk_audit havada yürüyeni "VISAUDIT float walking" diye yakalar.
## Otomatik test (Bölüm 17 varyantı → seçimler):
##   "" (varsayılan)   hizir, dunno, veni, told, kebab
##   osm              time, round, brutus, silent, none
##   edirne_policy    greek, flat (eğilir), salad, told, policy
##   edirne_legend    hizir, flat (yer), brutus, book, legend   (--bag=phone,book,selfie,cube)
##   edirne_none      time, dunno, veni, silent, none

const ORIGIN := Vector3(3000.0, 0.0, 0.0)
const PICKS := {
	"": {"who": "hizir", "answer": "dunno", "caesar": "veni", "future": "told", "vlad": "kebab"},
	"osm": {"who": "time", "answer": "round", "caesar": "brutus", "future": "silent", "vlad": "none"},
	"edirne_policy": {"who": "greek", "answer": "flat", "caesar": "salad", "future": "told", "vlad": "policy"},
	"edirne_legend": {"who": "hizir", "answer": "flat", "caesar": "brutus", "future": "book", "vlad": "legend"},
	"edirne_none": {"who": "time", "answer": "dunno", "caesar": "veni", "future": "silent", "vlad": "none"},
}
const WHO := ["hizir", "time", "greek"]
## Seçime göre değişen replikler [konuşmacı, anahtar] çiftleriyle açıkça yazılır: tools/voice_map.py konuşmacıyı
## buradan okur (anahtar adındaki "M" kısaltması Müfide'ye gidiyordu, şehzadenin satırı onun sesiyle üretiliyordu).
const RUN_LINE := {"hizir": ["SPK_SEHZADE", "D17E_M_RUN_HIZIR"], "time": ["SPK_SEHZADE", "D17E_M_RUN_TIME"],
	"greek": ["SPK_SEHZADE", "D17E_M_RUN_GREEK"]}
const BYE_LINE := {"hizir": ["SPK_SEHZADE", "D17E_M_BYE_HIZIR"], "time": ["SPK_SEHZADE", "D17E_M_BYE_TIME"],
	"greek": ["SPK_SEHZADE", "D17E_M_BYE_GREEK"]}
const WHAT_LINE := {
	"kebab": [["SPK_TOLGA", "D17E_T_WHAT_KEBAB"], ["SPK_NIHAT", "D17E_N_WHAT_KEBAB"]],
	"policy": [["SPK_TOLGA", "D17E_T_WHAT_POLICY"], ["SPK_NIHAT", "D17E_N_WHAT_POLICY"]],
	"legend": [["SPK_TOLGA", "D17E_T_WHAT_LEGEND"], ["SPK_NIHAT", "D17E_N_WHAT_LEGEND"]],
	"none": [["SPK_TOLGA", "D17E_T_WHAT_NONE"], ["SPK_NIHAT", "D17E_N_WHAT_NONE"]]}
## Ofiste Vikipedi ekranının önü (ekran sol duvarda, x -2.9)
const BOARD_VIEW := Vector3(-1.3, 0.0, 1.2)

## Yollar (saray yerel; her nokta zemin yüksekliğinde: çimen 0, taş basamak 0,15, köşk döşemesi 0,3). Basamaklar
## kenarın iki yanındaki nokta çiftleriyle verilir (kenardan 8 cm önce, 8 cm sonra): _walk onları adım adım çıkar.
const POOL_MEET := Vector3(0.4, 0.0, 3.7)          # şehzade havuzun kuzey kenarında Tolga'yı karşılar
const TOLGA_OUT := Vector3(-1.2, 0.0, 2.75)        # Tolga havuzdan buraya çıkar
const PATH_TO_DERS := [Vector3(0.6, 0.0, 7.0), Vector3(0.6, 0.0, 10.92), Vector3(0.6, 0.15, 11.08), Vector3(0.6, 0.15, 11.42),
	Vector3(0.6, 0.3, 11.58), EdirnePalace.MEHMED_DERS]
## Kütüphanede masanın güneyinden dolaşılır (masa pencerenin önünde, şehzade masa ile pencere arasında durur)
const LIB_AROUND := Vector3(17.4, 0.3, -0.5)
const PATH_TO_LIB := [Vector3(0.6, 0.3, 11.58), Vector3(0.6, 0.15, 11.42), Vector3(0.6, 0.15, 11.08), Vector3(0.6, 0.0, 10.92),
	Vector3(5.5, 0.0, 9.8), Vector3(10.8, 0.0, 6.0), Vector3(12.42, 0.0, 1.0), Vector3(12.58, 0.15, 1.0), Vector3(12.92, 0.15, 1.0),
	Vector3(13.08, 0.3, 1.0), Vector3(14.6, 0.3, -0.5), LIB_AROUND, EdirnePalace.MEHMED_LIB]
const PATH_TO_AVLU := [LIB_AROUND, Vector3(14.6, 0.3, -0.5), Vector3(13.08, 0.3, 1.0), Vector3(12.92, 0.15, 1.0), Vector3(12.58, 0.15, 1.0),
	Vector3(12.42, 0.0, 1.0), Vector3(6.5, 0.0, -3.8), Vector3(-5.0, 0.0, -3.8), Vector3(-10.0, 0.0, -3.2), EdirnePalace.MEHMED_AVLU]
const SHELF_STAND := EdirnePalace.SHELF_STAND       # güney rafının önü (İskendernâme'ye uzanılır)
const ROD_STAND := Vector3(2.0, 0.3, 16.55)        # Gürânî değneğe uzanır
const RADU_ARCH := Vector3(-15.6, 0.0, -8.4)       # Radu'nun ok attığı yer (güneydeki nişan tahtasına bakar)
const RADU_TO_DOOR := [Vector3(-14.4, 0.0, -1.5), Vector3(-18.1, 0.0, -3.0)]   # Vlad'ın kuzeyinden rehine odasının kapısına
const RADU_TRAY := Vector3(-15.9, 0.0, -3.9)       # Radu siniyle mangalın yanına gelir
const RADU_WATCH := Vector3(-17.3, 0.0, -3.4)      # Radu mangalın kuzeybatısından izler (Tolga'nın görüşünün solunda, geride)
const VLAD_UP := Vector3(-14.4, 0.0, -2.7)         # Vlad taburesinden kalkınca durduğu yer (kütüğün doğu ucu)
const GURANI_TO_TOLGA := [Vector3(-0.7, 0.3, 15.9), Vector3(-0.45, 0.3, 13.8)]   # hocanın rahlesinin yanından Tolga'nın başına
const GURANI_BACK := [Vector3(-0.7, 0.3, 15.9), EdirnePalace.HOCA_SPOT]
const COOK_SPOT := Vector3(-15.25, 0.0, -4.75)     # Tolga mangalın başında
const HALIL_POOL := Vector3(4.4, 0.0, 1.0)         # Halil havuzun doğu kenarında eğilir
const GATE_IN := Vector3(0.0, 0.0, -15.5)

var host: Node3D
var hud: Hud
var player: Player
var bureau: Bureau
var nihat: Person
var board: Node3D
var palace: EdirnePalace
var mehmed: Person
var gurani: Person
var vlad: Person
var radu: Person
var halil: Person
var guards: Array[Person] = []
var _bureau_env: Environment
var _picks: Dictionary = {}
var _rod_done := false
var _archery := false
var _arrows: Array[Node3D] = []
## Canlı çekim (--flag=shots17:edirne_live): sahne gerçekten oynanır, ana anlarda kare alınır (_snap)
var _shot := Callable()


func run(h: Node3D, hd: Hud, pl: Player, bu: Bureau, ni: Person, bo: Node3D) -> void:
	host = h
	hud = hd
	player = pl
	bureau = bu
	nihat = ni
	board = bo
	host.add_child(self)
	_picks = PICKS.get(GameState.autotest_variant, PICKS[""])
	hud.set_objective("")
	await _calibration()
	await _arrive()
	await _lesson()
	await _library()
	await _hostages()
	await _escape()
	await _aftermath()
	# Sonraki oyunlarda Bölüm 12'de Fatih bir an durur (oyunlar arasında kalır)
	GameState.bump_stat("edirne_seen", 1, true)
	queue_free()


# ================================================================ yardımcılar

func _wait(s: float) -> void:
	await get_tree().create_timer(s).timeout


## Sahne arası nefes: oyunda s saniye, otomatik testte bir an.
## Biri bir şeyi almak için yanına yürür (kol boyuna kadar), ya da yerine döner. near: hedefin kol boyu önünde durur.
func _step_to(p: Person, target: Vector3, near := true) -> void:
	var to := target
	to.y = p.global_position.y
	if near:
		to = to + (p.global_position - to).normalized() * 0.75
	if GameState.autotest and not GameState.pace:
		p.global_position = to
		return
	var d := p.global_position.distance_to(to)
	if d < 0.1:
		return
	p.face_toward(to)
	var tw := create_tween()
	tw.tween_property(p, "global_position", to, d / 1.4)
	await tw.finished
	if not near:
		p.face_toward(player.global_position)

func _beat(s: float) -> void:
	await get_tree().create_timer(0.05 if GameState.autotest else s).timeout


func _p(local: Vector3) -> Vector3:
	return palace.to_global(local)


func _pick(kind: String) -> String:
	return String(_picks.get(kind, ""))


## Seçim: anahtarlar ve kimlikleri sırayla; otomatik testte varyantın kimliği seçilir.
func _choose(keys: Array, ids: Array, kind: String) -> String:
	var want := ids.find(_pick(kind))
	var c := await hud.choose(keys, 0.0, maxi(want, 0))
	return String(ids[clampi(c, 0, ids.size() - 1)])


## Ekranın ortasında kırmızı "[kaynak belirtilmeli]" damgası (rivayet, ya da Tolga tarihe salata soktu).
func _cn() -> void:
	Audio.sfx("stamp", -6.0, 1.3)
	var l := Label.new()
	l.text = tr("PROP17_WIKI_CN")
	l.add_theme_font_size_override("font_size", 34)
	l.add_theme_color_override("font_color", Color("e0302a"))
	l.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.9))
	l.add_theme_constant_override("outline_size", 8)
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	l.position.y += 150.0
	l.rotation = -0.06
	hud.add_child(l)
	var tw := l.create_tween()
	tw.tween_interval(0.4 if GameState.autotest else 1.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.5)
	tw.tween_callback(l.queue_free)


func _person(look: Dictionary, spk: String, at: Vector3, face: Vector3) -> Person:
	var p := Person.new(look)
	if spk != "":
		p.set_meta("spk", spk)
	else:
		p.set_meta("no_talk", true)
	p.set_meta("no_chat", true)
	p.set_meta("walk_float_audit", true)
	palace.add_child(p)
	p.position = at
	p.face_toward(_p(face))
	return p


## Bir kişi bir yol boyunca yürür (yerel noktalar, her biri zemin yüksekliğinde). Düz parçalar Walker.go ile (kimsenin
## içinden geçmez, engelin yanından dolanır); basamaklar ve kısa parçalar _step ile: kenarda ayak kalkar, öbür
## basamağa iner. Kimse havada yürümez: Walker yerde yürür (ground), yüksekliği her adımda ayağın altındaki zeminden
## alır. Otomatik testte de yürünür (üç kat hızlı): denetim yürüyüşü görür.
func _walk(who: Person, path: Array, spd := 1.3, direct := false) -> void:
	var s := spd * (3.0 if GameState.autotest else 1.0)
	# Sevinçle sıçrayan ("cheer") yere inince yürür: sıçrayışın tween'i yüksekliği yürüyüşle aynı anda yazıyordu
	# (Radu kebaba havada koşuyordu). En çok 1,5 sn: iz kalırsa yürüyüş sonsuza dek beklemesin.
	var at := 0.0
	while is_instance_valid(who) and who.has_meta("airborne") and at < 1.5:
		await get_tree().process_frame
		at += get_process_delta_time()
	if not is_instance_valid(who):
		return
	who.remove_meta("airborne")
	var gen := int(_walk_gen.get(who, 0))
	var prev := who.position
	for pt: Vector3 in path:
		if not is_instance_valid(who) or int(_walk_gen.get(who, 0)) != gen:
			return
		var flat := Vector2(pt.x - prev.x, pt.z - prev.z).length()
		if direct or absf(pt.y - prev.y) > 0.02 or flat < 0.6:
			await _step(who, prev, pt, s, gen)
		else:
			var w := Walker.go(who, _p(pt), s)
			w.ground = true
			await w.arrived
		prev = pt
	if is_instance_valid(who) and int(_walk_gen.get(who, 0)) == gen:
		who.position = path[-1]


## Süren yürüyüşü keser (yol arkadaşı kapıda takıldı, oyuncu çoktan vardı): bekleyen betik sürer, kişiyi çağıran yerine koyar.
var _walk_gen := {}
var _shoes: Array[Node3D] = []
const FLOOR_STEP := 0.15


func _cancel_walk(who: Person) -> void:
	if not is_instance_valid(who):
		return
	_walk_gen[who] = int(_walk_gen.get(who, 0)) + 1
	for n in who.get_parent().get_children():
		var w := n as Walker
		if w and w.person == who:
			w.set_physics_process(false)
			w.arrived.emit()
			w.queue_free()


## Basamak adımı: a'dan b'ye (yerel) kısa yürüyüş; yükseklik parçanın ortasında (kenarın üstünde) değişir, adım biraz
## yavaşlar. Bacaklar Rig'de hızdan kendiliğinden yürür.
func _step(who: Person, a: Vector3, b: Vector3, spd: float, gen := -1) -> void:
	var d := Vector2(b.x - a.x, b.z - a.z)
	if d.length() > 0.01:
		who.rotation.y = atan2(d.x, d.y)
	var secs := maxf(0.12, (d.length() + absf(b.y - a.y) * 2.0) / maxf(spd * 0.7, 0.1))
	var go := func(v: float) -> void:
		if not is_instance_valid(who) or (gen >= 0 and int(_walk_gen.get(who, 0)) != gen):
			return
		var p := a.lerp(b, v)
		p.y = lerpf(a.y, b.y, smoothstep(0.3, 0.7, v))
		who.position = p
	var tw := create_tween()
	tw.tween_method(go, 0.0, 1.0, secs)
	await tw.finished


## Biri yol boyunca yürür, oyuncu ardından gelir (hedefi işaretli). Oyuncu gelmezse (25 sn) yerine konur: sahne
## beklemesin. Otomatik testte kişi yürür, oyuncu ışınlanır.
func _go_together(who: Person, path: Array, player_to: Vector3, obj_key: String) -> void:
	if GameState.autotest:
		await _walk(who, path, 1.4)
		player.global_position = _p(player_to) + Vector3(0, 0.05, 0)
		await _wait(0.1)
		return
	var runner := _walk_bg(who, path, 1.4)
	player.frozen = false
	hud.set_objective(tr(obj_key), _p(player_to) + Vector3(0, 1.0, 0))
	var t := 0.0
	while player.global_position.distance_to(_p(player_to)) > 2.2 and t < 25.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	hud.set_objective("")
	player.frozen = true
	# Oyuncu vardı: yol arkadaşı birkaç saniye beklenir. Kapıda ya da basamakta takıldıysa (kütüphanede "Fatih'i beklerken
	# kilitlendi") perde arkasında yerine konur; eskiden yürüyüş bitene dek sınırsız beklenirdi.
	var w := 0.0
	while not runner.done and w < 6.0:
		await get_tree().process_frame
		w += get_process_delta_time()
	var far := player.global_position.distance_to(_p(player_to)) > 2.2
	if not runner.done or far:
		await hud.fade_to(1.0, 0.3)
		if not runner.done:
			_cancel_walk(who)
			who.position = path[-1]
		if far:
			player.global_position = _p(player_to) + Vector3(0, 0.05, 0)
		await hud.fade_to(0.0, 0.3)


## Arka planda süren yürüyüş (sahne beklemeden sürer): done, varınca true olur.
class Run:
	var done := false


func _walk_bg(who: Person, path: Array, spd := 1.3, direct := false) -> Run:
	var r := Run.new()
	_walk_mark(who, path, spd, r, direct)
	return r


func _walk_mark(who: Person, path: Array, spd: float, r: Run, direct := false) -> void:
	await _walk(who, path, spd, direct)
	r.done = true


func _until(r: Run, limit := 20.0) -> void:
	var t := 0.0
	while not r.done and t < limit:
		await get_tree().process_frame
		t += get_process_delta_time()


func _look(at: Node3D) -> void:
	if at:
		player.face(at.global_position + Vector3(0, 1.25 * at.scale.y if at is Person and (at as Person).child else 1.5, 0))


## Kamera yumuşakça bir noktaya döner (konuşan değişince, bir şey gösterilince).
func _turn(point: Vector3, secs := 0.45) -> void:
	if GameState.autotest:
		player.face(point)
		return
	var y0 := player.rotation.y
	var p0 := player.camera.rotation.x
	var to := point - player.global_position
	var y1 := atan2(-to.x, -to.z)
	var p1 := atan2(to.y - player.eye_height, Vector2(to.x, to.z).length())
	var step := func(v: float) -> void:
		player.rotation.y = lerp_angle(y0, y1, v)
		player.camera.rotation.x = lerpf(p0, p1, v)
	var tw := create_tween()
	tw.tween_method(step, 0.0, 1.0, secs).set_trans(Tween.TRANS_SINE)
	await tw.finished


func _turn_to(who: Node3D, secs := 0.45) -> void:
	if who:
		await _turn(who.global_position + Vector3(0, 1.25 * who.scale.y if who is Person and (who as Person).child else 1.5, 0), secs)


## Canlı çekimde bir kare: kısa bir bekleyişten sonra (hareket otursun), istenirse kamera birine döner. Oyunda hiçbir şey yapmaz.
func _snap(name: String, settle := 0.35, look: Node3D = null, look_y := -1.0) -> void:
	if not _shot.is_valid():
		return
	await get_tree().create_timer(settle).timeout
	if look and is_instance_valid(look):
		if look_y >= 0.0:
			player.face(look.global_position + Vector3(0, look_y, 0))
		else:
			_look(look)
	await _shot.call("c17L_" + GameState.autotest_variant + "_" + name + ".png")


# ================================================================ 0 kalibrasyon

func _calibration() -> void:
	await hud.say("SPK_NIHAT", "D17E_N_CAL_1")
	await hud.say("SPK_TOLGA", "D17E_T_CAL_1")
	await bureau.lift_board(player, hud, nihat, "D17E_N_LIFT_1")
	await bureau.lift_spin("1453", 1.2, nihat)
	if GameState.has_item("chickpeas"):
		player.show_prop("chickpeas", 1.2)
		await hud.say("SPK_TOLGA", "D17E_T_LEB")
		# Leblebi kadranın dişlisine kaçar: tık, kıvılcım, çark sarsılır
		Audio.sfx("timer_tick", -2.0, 1.7)
		Vfx.sparks(bureau, Bureau.PANEL_POS + Vector3(0.05, 0.0, -0.05), 0.4)
		var wt := bureau.panel_wheel.create_tween()
		wt.tween_property(bureau.panel_wheel, "rotation:x", bureau.panel_wheel.rotation.x + 1.4, 0.15)
		wt.tween_property(bureau.panel_wheel, "rotation:x", bureau.panel_wheel.rotation.x + 1.1, 0.1)
		nihat.emote("surprise")
		await hud.say("SPK_NIHAT", "D17E_N_LEB")
	else:
		for k in 2:
			Audio.sfx("radio_beep", -4.0, 1.5)
			await _wait(0.3)
		# Telefon çantada yoksa çalan, Hikmet'in telsizi (Telsiz-Kumanda cepten çıkar)
		if GameState.has_item("phone"):
			player.show_prop("phone", 2.2)
			await hud.say("SPK_TOLGA", "D17E_T_PHONE")
		else:
			player.radio_listen(2.6)
			await hud.say("SPK_TOLGA", "D17E_T_RADIO")
		nihat.emote("facepalm")
		await hud.say("SPK_NIHAT", "D17E_N_PHONE")
	# Kadran kayar: 1453 → 1444 (Nihat kolu tutmaya çalışır)
	nihat.reach_to(bureau.to_global(Bureau.PANEL_POS), 0.9)
	await _snap("01_cal", 0.2, nihat)
	for y in ["1452", "1450", "1449", "1447", "1446", "1444"]:
		bureau.set_dial(y)
		bureau.panel_wheel.rotation.x -= 0.6
		Audio.sfx("timer_tick", -6.0, 0.7)
		await _wait(0.16)
	hud.bark("SPK_NIHAT", "D17E_N_NO", 3.0)
	await bureau.lift_close(player)
	await bureau.lift_go(hud, "1453", "1444", true, tr("D17E_CAP_GLITCH"), 3.0)


# ================================================================ 1 havuz

func _enter_palace() -> void:
	palace = EdirnePalace.new()
	palace.position = ORIGIN
	host.add_child(palace)
	# Tek WorldEnvironment kalsın: Büro'nun ortamı 1444 yazıyla değişir (Büro gizlenir, sahnede kalır)
	_bureau_env = bureau.env_node.environment
	bureau.env_node.environment = EdirnePalace.make_env()
	bureau.visible = false
	Audio.voice_space("outdoor")
	Audio.ambience("amb_city_day")
	Audio.music("tender")
	mehmed = _person({"face": "fatih", "child": true, "coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "turban",
		"robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")}, "SPK_SEHZADE",
		EdirnePalace.READ_SPOT, EdirnePalace.POOL)
	mehmed.set_activity("read_ground")    # çınarın altında bağdaş kurmuş, kucağında İskendernâme
	gurani = _person({"face": {"nose": "long", "nose_s": 1.1, "eye_s": 0.85, "lid": 0.35, "brow": 1.5, "brow_tilt": 10.0,
		"wrinkles": true, "beard": "full", "mustache": "walrus", "head": Vector3(1.0, 1.1, 1.0)}, "coat": Color("2e2a36"),
		"pants": Color("23202a"), "hat": "turban", "robe": Color("3a3442"), "beard": true, "mustache": true,
		"hair": Color("4a4038"), "skin": Color("c8946a")}, "SPK_GURANI", EdirnePalace.HOCA_SPOT,
		EdirnePalace.HOCA_SPOT + Vector3(0, 0, -3))
	gurani.set_activity("sit_ground")
	# Vlad taburesinde, kütüğün başında: elinde çakı ve sopa, talaş düşer
	vlad = _person({"face": {"nose": "long", "nose_s": 1.2, "eye_s": 1.2, "eye_gap": 0.36, "brow": 1.6, "brow_tilt": 20.0,
		"head": Vector3(0.95, 1.12, 0.98), "blush": false}, "child": true, "coat": Color("5a1820"), "pants": Color("2a2026"),
		"hat": "kalpak", "hair": Color("1a1412"), "hair_style": "long", "skin": Color("e6c0a0")}, "SPK_VLAD",
		EdirnePalace.VLAD_SPOT, EdirnePalace.LOG)
	vlad.scale = Vector3.ONE * 1.12
	vlad.set_meta("no_unclip", true)      # taburede oturur
	vlad.set_activity("whittle")
	# Radu nişan tahtasına ok atar (yaylı; okları tahtaya saplanır)
	radu = _person({"face": {"nose": "button", "eye_s": 1.3, "brow_tilt": -12.0, "blush": true, "mouth_w": 1.2},
		"child": true, "coat": Color("3a6a9a"), "pants": Color("2a3040"), "hat": "kalpak", "hair": Color("6a4a2a"), "hair_style": "curly",
		"skin": Color("f0caa8")}, "SPK_RADU", RADU_ARCH, EdirnePalace.BUTT)
	radu.scale = Vector3.ONE * 0.86   # yedi yaşında: ağabeyinden ve şehzadeden küçük
	radu.equip("bow")
	# Halil Paşa kapıda: divana çağırmaya yürüyerek gelir, sonra çekilir (kütüphanede ve kaçışta yeniden gelir)
	halil = _person({"face": "candarli", "coat": Color("3a4a3a"), "pants": Color("2a2a24"), "hat": "vizier", "beard": true,
		"mustache": true, "hair": Color("6a6a6a"), "robe": Color("3a4a3a"), "skin": Color("d9a07a")}, "SPK_HALIL",
		GATE_IN, EdirnePalace.POOL)
	# Kapının iki yanında nöbetçiler (kovalamacada Halil'in muhafızları olur)
	for s in [-1.0, 1.0]:
		var g := _person({"coat": Color("b3262d"), "pants": Color("3a2a20"), "hat": "bork", "mustache": true, "skin": Color("d8a888")},
			"", EdirnePalace.GATE + Vector3(s * 2.4, 0, 1.2), EdirnePalace.POOL)
		g.equip("spear")
		guards.append(g)
	_archery = true
	_radu_archery()


## Radu ok atar: yay kalkar, ok yay çizip nişan tahtasına saplanır (tahtada en çok altı ok kalır). _archery sönünce durur.
func _radu_archery() -> void:
	while _archery and is_instance_valid(radu):
		await _wait(0.6 if GameState.autotest else randf_range(2.2, 3.4))
		if not _archery or not is_instance_valid(radu) or palace == null:
			return
		radu.face_toward(_p(EdirnePalace.BUTT))
		radu.emote("point")
		await _wait(0.25)
		var arrow := Node3D.new()
		palace.add_child(arrow)
		Props.cyl(arrow, 0.008, 0.6, Vector3.ZERO, Color("c8a878"), Vector3(90, 0, 0), 5)
		Props.box(arrow, Vector3(0.002, 0.04, 0.08), Vector3(0, 0, -0.27), Color("f0ece4"))
		Props.cyl(arrow, 0.012, 0.05, Vector3(0, 0, 0.3), Color("6a6a70"), Vector3(90, 0, 0), 5, 0.0)
		var from := palace.to_local(radu.global_position) + Vector3(0, 1.05 * radu.scale.y, 0)
		var hit := EdirnePalace.BUTT + Vector3(randf_range(-0.3, 0.3), 1.0 + randf_range(-0.25, 0.25), 0.17)
		arrow.position = from
		arrow.look_at_from_position(_p(from), _p(hit), Vector3.UP)
		arrow.rotate_object_local(Vector3.UP, PI)
		Audio.sfx("whoosh_fly", -14.0, 1.8)
		var mid := (from + hit) * 0.5 + Vector3(0, 0.6, 0)
		var tw := arrow.create_tween()
		tw.tween_method(func(v: float):
			arrow.position = from.lerp(mid, v).lerp(mid.lerp(hit, v), v), 0.0, 1.0, 0.45)
		await tw.finished
		Audio.sfx("land_thud", -12.0, 1.6)
		_arrows.append(arrow)
		if _arrows.size() > 6:
			var old: Node3D = _arrows.pop_front()
			if is_instance_valid(old):
				old.queue_free()


func _arrive() -> void:
	_enter_palace()
	# Çarpışmalar bir sonraki fizik karesinde gelir: önce bekle, sonra havuzun üstüne
	await get_tree().physics_frame
	await get_tree().physics_frame
	player.global_position = _p(Vector3(-1.9, 2.4, -1.0))
	player.face(_p(EdirnePalace.READ_SPOT) + Vector3(0, 0.8, 0))
	hud.cover_override = "ch17e"
	hud.set_fade(1.0)
	await hud.card([[tr("UI_CH17E_TITLE"), 44, Color("f2e6c9")], [tr("UI_CH17E_SUB"), 20, Color(1, 1, 1, 0.75)]], 2.8)
	hud.clear_card()
	hud.cover_override = ""
	await hud.fade_to(0.0, 0.4, Color.WHITE)
	var t := 0.0
	while not player.is_on_floor() and t < 1.5:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	Audio.sfx("splash", 0.0)
	Vfx.splash(palace, Vector3(-1.9, EdirnePalace.WATER_Y, -1.0), 1.6)
	player.shake(0.5)
	hud.wet(3.5)
	# Fes suda yüzer (takılıysa): biraz sürüklenir, Tolga kapar
	var fez: Node3D = null
	if GameState.flags.get("fez", true):
		fez = Node3D.new()
		palace.add_child(fez)
		fez.position = Vector3(-1.4, EdirnePalace.WATER_Y + 0.05, -0.4)
		fez.rotation_degrees = Vector3(0, 0, 160)
		Props.cyl(fez, 0.11, 0.15, Vector3.ZERO, Color("b3262d"), Vector3.ZERO, 8, 0.09)
		Props.cyl(fez, 0.006, 0.12, Vector3(0.05, -0.06, 0), Color("141414"), Vector3(0, 0, 30), 4)
		var ft := fez.create_tween().set_loops(4)
		ft.tween_property(fez, "position:y", EdirnePalace.WATER_Y + 0.08, 0.5).set_trans(Tween.TRANS_SINE)
		ft.tween_property(fez, "position:y", EdirnePalace.WATER_Y + 0.03, 0.5).set_trans(Tween.TRANS_SINE)
		fez.create_tween().tween_property(fez, "position:x", -0.9, 3.0)
	await _snap("02_splash", 0.4)
	# Şehzade sesi duyar: başını kaldırır, kitabını kapatır, kalkar ve havuza yürür
	mehmed.look_target = player
	await _beat(0.6)
	await hud.say("SPK_TOLGA", "D17E_T_SPLASH")
	# Kitabı kapatır, koltuğunun altına alır, kalkar
	Audio.sfx("paper_tear", -18.0, 0.6)
	mehmed.set_activity("")
	mehmed.tuck(_closed_book())
	await _beat(0.5)
	mehmed.look_target = null
	var meet := _walk_bg(mehmed, [Vector3(4.6, 0.0, 4.4), POOL_MEET], 1.1)
	_snap("03_mehmed_walk", 0.5, mehmed, 0.9)
	if fez:
		await hud.say("SPK_TOLGA", "D17E_T_FEZ")
		Audio.sfx("splash", -14.0, 1.6)
		fez.queue_free()
		player.show_prop("spare_fez", 1.0)
	# Tolga havuzdan çıkar: suda iki adım, kenara basar, çimene iner
	await _wade_out()
	await _until(meet)
	mehmed.face_toward(player.global_position)
	mehmed.look_target = player
	_look(mehmed)
	await hud.say("SPK_SEHZADE", "D17E_M_01")
	await hud.say("SPK_SEHZADE", "D17E_M_02")
	var who := await _choose(["UI_C17E_WHO_HIZIR", "UI_C17E_WHO_TIME", "UI_C17E_WHO_GREEK"], WHO, "who")
	GameState.flags["edirne_who"] = who
	# Halil Paşa konuşma sürerken kapıdan çıkıp yürür (eskiden konuşma bitince 17 m'lik yolu donmuş oyuncu sessizce
	# izliyordu: "Çandarlı gelirken bekleme"); nöbetçiler önünden geçerken selam durur
	var halil_come := _walk_bg(halil, [Vector3(4.6, 0.0, -6.0), HALIL_POOL], 1.5)
	for g in guards:
		g.emote("bow")
	match who:
		"hizir":
			await hud.say("SPK_TOLGA", "D17E_T_HIZIR")
			mehmed.emote("think")
			await hud.say("SPK_SEHZADE", "D17E_M_HIZIR")
		"time":
			await hud.say("SPK_TOLGA", "D17E_T_TIME")
			mehmed.emote("think")
			await hud.say("SPK_SEHZADE", "D17E_M_TIME")
			await hud.say("SPK_TOLGA", "D17E_T_TIME_2")
			mehmed.emote("nod")
			await hud.say("SPK_SEHZADE", "D17E_M_TIME_2")
		_:
			await hud.say("SPK_TOLGA", "D17E_T_GREEK")
			await hud.say("SPK_SEHZADE", "D17E_M_GREEK")
			await hud.say("SPK_TOLGA", "D17E_T_GREEK_2")
			mehmed.emote("laugh")
			await hud.say("SPK_SEHZADE", "D17E_M_GREEK_2")
	await hud.say("SPK_SEHZADE", "D17E_M_NAME")
	# Kapıdan gelen Halil Paşa eğilir: tahtta çocuk, divanı yürüten vezir
	await _until(halil_come, 10.0)
	if not halil_come.done:
		_cancel_walk(halil)
		halil.position = HALIL_POOL
	halil.face_toward(mehmed.global_position)
	halil.look_target = mehmed
	halil.emote("bow")
	await _snap("04_halil_bow", 0.25, halil, 1.2)
	await _beat(0.5)
	await hud.say("SPK_HALIL", "D17E_H_DIVAN")
	mehmed.look_target = halil
	await hud.say("SPK_SEHZADE", "D17E_M_DIVAN")
	halil.emote("bow")
	await hud.say("SPK_HALIL", "D17E_H_DIVAN_2")
	halil.look_target = null
	var back := _walk_bg(halil, [Vector3(4.6, 0.0, -6.0), GATE_IN], 1.3)
	mehmed.look_target = player
	await hud.say("SPK_SEHZADE", "D17E_M_COME")
	mehmed.look_target = null
	await _beat(0.3)
	_hide_when(halil, back)
	_snap("05_walk_ders", 0.7, mehmed, 0.8)
	_snap("05_walk_step", 1.0, mehmed, 0.8)
	await _go_together(mehmed, PATH_TO_DERS, EdirnePalace.TOLGA_DERS, "UI_OBJ17E_FOLLOW")


## Kapalı kitap (kırmızı meşin cilt, sırtı altın şeritli): koltuk altında taşınır.
func _closed_book() -> Node3D:
	var b := Node3D.new()
	Props.box(b, Vector3(0.2, 0.05, 0.27), Vector3.ZERO, Color("8a1c24"))
	Props.box(b, Vector3(0.19, 0.04, 0.005), Vector3(0, 0, 0.136), Color("efe6cf"))
	Props.box(b, Vector3(0.01, 0.052, 0.27), Vector3(-0.1, 0, 0), Color("c49a45"))
	return b


## Halil kapıya varınca görünmez olur (kütüphanede ve kaçışta yeniden gelir).
func _hide_when(who: Person, r: Run) -> void:
	await _until(r, 30.0)
	if is_instance_valid(who):
		who.visible = false


## Tolga havuzdan çıkar: suda yürür (dalgacıklar), kenarın taşına basar, çimene iner.
func _wade_out() -> void:
	var a := player.global_position
	var rim := _p(Vector3(TOLGA_OUT.x, EdirnePalace.RIM_H + 0.05, 2.17))
	var out := _p(TOLGA_OUT + Vector3(0, 0.05, 0))
	if GameState.autotest:
		player.global_position = out
		return
	var tw := create_tween()
	tw.tween_property(player, "global_position", Vector3(rim.x, a.y, _p(Vector3(0, 0, 1.6)).z), 1.3).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(Audio.sfx.bind("splash", -12.0, 1.4))
	tw.tween_property(player, "global_position", rim, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(Audio.sfx.bind("footstep_stone_2", -6.0, 1.0))
	tw.tween_property(player, "global_position", out, 0.4).set_trans(Tween.TRANS_SINE)
	await tw.finished
	Vfx.splash(palace, Vector3(TOLGA_OUT.x, EdirnePalace.WATER_Y, 1.8), 0.5)
	hud.wet(2.5)


# ================================================================ 2 ders

func _lesson() -> void:
	# Pabuçlar basamakta kalır: şehzadenin kırmızı pabuçları ve Tolga'nın ıslak ayakkabıları (çıkarken giyilir)
	_shoes.clear()
	for sx in [-0.09, 0.09]:
		_shoes.append(Props.box(palace, Vector3(0.09, 0.05, 0.2), Vector3(0.4 + sx, 0.175, 11.15), Color("a8262f"), Vector3(0, 8, 0)))
		_shoes.append(Props.box(palace, Vector3(0.11, 0.07, 0.27), Vector3(-0.9 + sx * 1.2, 0.185, 11.12), Color("2a2622"), Vector3(0, -12, 0)))
	mehmed.set_activity("")
	mehmed.face_toward(gurani.global_position)
	gurani.look_target = player
	await _settle_player(EdirnePalace.TOLGA_DERS, gurani)
	await hud.say("SPK_GURANI", "D17E_G_SHOES")
	await hud.say("SPK_TOLGA", "D17E_T_SHOES")
	# Gürânî kalkar, duvardaki değneği alır, postuna döner; şehzade bu arada değneğin hikâyesini anlatır
	_rod_done = false
	_fetch_rod()
	mehmed.face_toward(player.global_position)
	mehmed.look_target = player
	await hud.say("SPK_SEHZADE", "D17E_M_ROD")
	await hud.say("SPK_TOLGA", "D17E_T_ROD")
	await hud.say("SPK_SEHZADE", "D17E_M_ROD_2")
	_cn()
	var t := 0.0
	while not _rod_done and t < 12.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	mehmed.look_target = null
	mehmed.face_toward(gurani.global_position)
	gurani.look_target = mehmed
	await hud.say("SPK_GURANI", "D17E_G_01")
	# İkisi de minderine oturur: şehzade kitabını rahlesine bırakıp bağdaş kurar, Tolga'nın göz hizası iner
	mehmed.untuck_free()
	mehmed.set_activity("sit_ground")
	player.sit_view(true)
	await _beat(0.5)
	_turn_to(gurani)
	await _snap("06_seated", 0.8, gurani, 1.0)
	gurani.emote("stamp")
	Audio.sfx("chop", -8.0, 1.5)       # değnek rahleye vurur
	mehmed.set_activity("write")         # defter dizinde, kalem elinde: ders başlar
	await _snap("08_write", 0.6, mehmed, 0.6)
	await hud.say("SPK_GURANI", "D17E_G_02")
	mehmed.emote("think")
	await hud.say("SPK_SEHZADE", "D17E_M_03")
	await hud.say("SPK_GURANI", "D17E_G_03")
	gurani.look_target = player
	await hud.say("SPK_GURANI", "D17E_G_04")
	var ans := await _choose(["UI_C17E_ANS_ROUND", "UI_C17E_ANS_FLAT", "UI_C17E_ANS_DUNNO"], ["round", "flat", "dunno"], "answer")
	GameState.flags["edirne_answer"] = ans
	match ans:
		"round":
			await hud.say("SPK_TOLGA", "D17E_T_ROUND")
			await hud.say("SPK_GURANI", "D17E_G_ROUND")
			mehmed.look_target = gurani
			await hud.say("SPK_SEHZADE", "D17E_M_ROUND")
			await hud.say("SPK_GURANI", "D17E_G_ROUND_2")
		"flat":
			await hud.say("SPK_TOLGA", "D17E_T_FLAT")
			mehmed.look_target = player
			mehmed.emote("laugh")
			await hud.say("SPK_SEHZADE", "D17E_M_FLAT")
			# Gürânî postundan kalkar, rahlelerin arasından Tolga'nın başına gelir
			gurani.set_activity("")
			var come := _walk_bg(gurani, GURANI_TO_TOLGA, 1.0)
			await hud.say("SPK_GURANI", "D17E_G_FLAT")
			await hud.say("SPK_TOLGA", "D17E_T_FLAT_2")
			await _until(come, 8.0)
			gurani.face_toward(player.global_position)
			gurani.look_target = player
			if await _rod_qte():
				await hud.say("SPK_GURANI", "D17E_G_DODGE")
			else:
				await hud.say("SPK_TOLGA", "D17E_T_HIT")
			var back := _walk_bg(gurani, GURANI_BACK, 1.0)
			await _until(back, 8.0)
			gurani.face_toward(_p(EdirnePalace.HOCA_SPOT + Vector3(0, 0, -3)))
			gurani.set_activity("sit_ground")
		_:
			await hud.say("SPK_TOLGA", "D17E_T_DUNNO")
			await hud.say("SPK_GURANI", "D17E_G_DUNNO")
			mehmed.emote("nod")
			await hud.say("SPK_SEHZADE", "D17E_M_DUNNO")
	await hud.say("SPK_GURANI", "D17E_G_END")
	gurani.look_target = null
	mehmed.look_target = null
	mehmed.set_activity("")
	player.sit_view(false)
	await _beat(0.4)
	_snap("10_ders_down", 0.5, mehmed, 0.7)
	# Çıkarken basamakta pabuçlar giyilir (eskiden basamakta kalıyordu): şehzade eğilip giyer, Tolga da kendininkini
	await _walk(mehmed, PATH_TO_LIB.slice(0, 2), 1.0)
	await _settle_player(Vector3(-0.9, FLOOR_STEP, 11.4), null)
	player.face(_p(Vector3(-0.2, FLOOR_STEP + 0.25, 10.3)))      # basamağa, iki çift pabuca bakar
	mehmed.emote("lean")
	player.sit_view(false, -0.3)
	await _snap("10_shoes", 0.35)
	await _wait(0.2 if GameState.autotest else 0.5)
	# Pabuçlar ayağa: şehzadeninki onun ayaklarına, Tolga'nınki kendi ayaklarına (görüşün altına) kayar
	player.hand_gesture("reach")
	var tw := create_tween().set_parallel()
	for i in _shoes.size():
		var sh := _shoes[i]
		if not is_instance_valid(sh):
			continue
		var side := -0.1 if i < 2 else 0.1
		var feet := mehmed.global_position + Vector3(side, 0.03, 0) if i % 2 == 0 else player.global_position + Vector3(side, 0.04, 0.1)
		tw.tween_property(sh, "global_position", feet, 0.45).set_trans(Tween.TRANS_SINE)
	await tw.finished
	for sh in _shoes:
		if is_instance_valid(sh):
			sh.queue_free()
	_shoes.clear()
	Audio.sfx("cloth", -12.0)
	await _snap("10_shoes_on", 0.2, mehmed, 0.9)
	player.sit_view(false)
	await _go_together(mehmed, PATH_TO_LIB.slice(2), EdirnePalace.TOLGA_LIB, "UI_OBJ17E_FOLLOW")


## Oyuncu yerine (minder, rafın önü) yerleşir ve birine döner: yumuşak kayış, sonra dönüş.
func _settle_player(local: Vector3, look: Node3D) -> void:
	var to := _p(local) + Vector3(0, 0.05, 0)
	if GameState.autotest:
		player.global_position = to
		if look:
			_look(look)
		return
	var tw := create_tween()
	tw.tween_property(player, "global_position", to, 0.5).set_trans(Tween.TRANS_SINE)
	await tw.finished
	if look:
		await _turn_to(look)


## Gürânî kalkar, duvardaki değneğe yürür, uzanıp alır (duvardaki kaybolur, eline geçer), minderine döner, oturur.
func _fetch_rod() -> void:
	gurani.look_target = null
	gurani.set_activity("")
	await _beat(0.4)
	await _walk(gurani, [ROD_STAND], 0.9)
	gurani.face_toward(palace.rod.global_position)
	gurani.reach_to(palace.rod.global_position, 0.3)
	await _snap("07_rod_reach", 0.3, gurani, 1.5)
	await _wait(0.3 if GameState.autotest else 0.5)
	palace.rod.visible = false
	gurani.equip("rod")
	Audio.sfx("cloth", -10.0, 1.2)
	await _walk(gurani, [EdirnePalace.HOCA_SPOT], 0.9)
	gurani.face_toward(_p(EdirnePalace.HOCA_SPOT + Vector3(0, 0, -3)))
	gurani.set_activity("sit_ground")
	_rod_done = true


## Değnek iner: Ctrl (ya da boşluk) ile eğil. Gürânî Tolga'nın başında; değnek havaya kalkar ve iner.
## Döner: eğildi mi.
func _rod_qte() -> bool:
	hud.set_qte(tr("UI_QTE17E_ROD"))
	var ok := false
	var swung := false
	if GameState.autotest:
		gurani.emote("swing")
		await _snap("09_swing", 0.12, gurani, 1.3)
		await _wait(0.2)
		ok = GameState.autotest_variant == "edirne_policy"
	else:
		var t := 0.0
		while t < 1.1:
			await get_tree().process_frame
			t += get_process_delta_time()
			if not swung and t > 0.3:
				swung = true
				gurani.emote("swing")      # değnek ~0,9 sn'de iner
			hud.set_red_progress(t / 1.1, tr("UI_BAR17E_ROD"))
			if not ok and (Input.is_action_just_pressed("dive") or Input.is_action_just_pressed("jump")):
				ok = true
				player.duck(0.45, 0.7)
	hud.set_red_progress(0.0)
	hud.set_qte("")
	if ok:
		Audio.sfx("whoosh_fly", -6.0, 1.3)     # değnek başın üstünden geçer
	else:
		Audio.sfx("chop", -4.0, 1.4)
		player.shake(0.6)
		Vfx.stars(palace, palace.to_local(player.global_position) + Vector3(0, 1.2, 0))
	mehmed.emote("laugh")
	await _beat(0.6)
	return ok


# ================================================================ 3 İskender ve Kayser

func _library() -> void:
	# Şehzade raftan İskendernâme'yi alır, masaya döner, açar
	await _settle_player(EdirnePalace.TOLGA_LIB, mehmed)
	await _walk(mehmed, [SHELF_STAND], 0.9)
	mehmed.face_toward(palace.shelf_book.global_position)
	mehmed.reach_to(palace.shelf_book.global_position, 0.3)
	await _snap("11_shelf", 0.3, mehmed, 1.0)
	await _wait(0.3 if GameState.autotest else 0.5)
	palace.shelf_book.visible = false
	Audio.sfx("paper_tear", -16.0, 0.7)
	mehmed.tuck(_closed_book())
	await _walk(mehmed, [EdirnePalace.MEHMED_LIB], 0.9)
	# Masada açar: koltuk altından ele, sayfalar açılır
	mehmed.untuck_free()
	var book := Items.open_book()
	mehmed.hold_item(book, true)
	mehmed.face_toward(player.global_position)
	mehmed.look_target = player
	_turn_to(mehmed)
	Items.flip_pages(book, 3)
	await _snap("12_read", 0.3, mehmed, 0.8)
	await hud.say("SPK_SEHZADE", "D17E_M_ISK")
	await hud.say("SPK_TOLGA", "D17E_T_ISK")
	await hud.say("SPK_SEHZADE", "D17E_M_ISK_2")
	# Usturlap: şehzade pencerenin yanındaki askıya gider, halkalarını çevirir (Uluğ Bey'in göğü; ileride Ali Kuşçu)
	mehmed.release_item()
	book.queue_free()
	mehmed.look_target = null
	await _walk(mehmed, [EdirnePalace.ASTRO_SPOT], 0.9)
	mehmed.face_toward(palace.astro.global_position)
	mehmed.reach_to(palace.astro.global_position, 1.2)
	_spin_astro()
	_turn(palace.astro.global_position)
	await _snap("13_astro", 0.5)
	await hud.say("SPK_SEHZADE", "D17E_M_STARS")
	await hud.say("SPK_TOLGA", "D17E_T_STARS")
	mehmed.look_target = player
	_turn_to(mehmed)
	await hud.say("SPK_SEHZADE", "D17E_M_STARS_2")
	await hud.think("SPK_TOLGA", "D17E_T_STARS_2")
	await _walk(mehmed, [EdirnePalace.MEHMED_LIB], 0.9)
	mehmed.face_toward(player.global_position)
	await hud.say("SPK_SEHZADE", "D17E_M_KAYSER")
	var cae := await _choose(["UI_C17E_CAE_VENI", "UI_C17E_CAE_SALAD", "UI_C17E_CAE_BRUTUS"], ["veni", "salad", "brutus"], "caesar")
	GameState.flags["edirne_caesar"] = cae
	match cae:
		"veni":
			await hud.say("SPK_TOLGA", "D17E_T_VENI")
			mehmed.emote("think")
			await hud.say("SPK_SEHZADE", "D17E_M_VENI")
		"salad":
			await hud.say("SPK_TOLGA", "D17E_T_SALAD")
			mehmed.emote("shrug")
			await hud.say("SPK_SEHZADE", "D17E_M_SALAD")
			_cn()
			hud.bark("SPK_NIHAT", "D17E_N_SALAD", 2.5)
			await _wait(0.8)
		_:
			await hud.say("SPK_TOLGA", "D17E_T_BRUTUS")
			# O an Halil Paşa yürüyerek köşkün önüne gelir; şehzade ona uzun uzun bakar
			halil.visible = true
			halil.position = Vector3(8.5, 0.0, 1.0)
			await _walk(halil, [Vector3(11.4, 0.0, 0.2)], 1.5)
			halil.face_toward(mehmed.global_position)
			halil.emote("bow")
			await _snap("19_brutus", 0.25, halil, 1.3)
			await hud.say("SPK_HALIL", "D17E_H_LIB")
			mehmed.look_target = halil
			_turn_to(halil, 0.6)
			await _beat(1.0)
			await hud.say("SPK_SEHZADE", "D17E_M_BRUTUS")
			await hud.say("SPK_HALIL", "D17E_H_BRUTUS")
			await hud.say("SPK_SEHZADE", "D17E_M_BRUTUS_2")
			mehmed.look_target = player
			_turn_to(mehmed)
			var gone := _walk_bg(halil, [Vector3(8.5, 0.0, 1.0), Vector3(4.6, 0.0, -6.0), GATE_IN], 1.3)
			_hide_when(halil, gone)
			await hud.think("SPK_TOLGA", "D17E_T_BRUTUS_2")
	# Defter: şehzade masadaki defterini alıp Tolga'ya uzatır (tuğra denemeleri, surlu şehir, zincir)
	await mehmed.reach_to(palace.notebook.global_position, 0.2)
	palace.notebook.visible = false
	mehmed.emote("offer")
	player.show_prop("sehzade_notebook", 4.2)
	await _snap("14_notebook", 0.45)
	await hud.say("SPK_SEHZADE", "D17E_M_NOTE")
	await hud.say("SPK_SEHZADE", "D17E_M_NOTE_2")
	palace.notebook.visible = true
	var keys := ["UI_C17E_FUT_TELL"]
	var ids := ["told"]
	if GameState.has_item("book"):
		keys.append("UI_C17E_FUT_BOOK")
		ids.append("book")
	keys.append("UI_C17E_FUT_SILENT")
	ids.append("silent")
	var fut := await _choose(keys, ids, "future")
	GameState.flags["edirne_future"] = fut
	match fut:
		"told":
			await hud.say("SPK_TOLGA", "D17E_T_TELL")
			await hud.say("SPK_SEHZADE", "D17E_M_TELL")
			await hud.say("SPK_TOLGA", "D17E_T_TELL_2")
			await hud.say("SPK_SEHZADE", "D17E_M_TELL_2")
		"book":
			player.show_prop("book", 1.0)
			await hud.say("SPK_TOLGA", "D17E_T_BOOK")
			var b := Items.build("book")
			await mehmed.receive_item(b, player.global_position + Vector3(0, 1.3, 0), true)
			await _snap("15_book", 0.2, mehmed, 0.9)
			await _beat(1.2)
			await hud.say("SPK_SEHZADE", "D17E_M_BOOK")
			mehmed.release_item()
			b.queue_free()
			mehmed.reach_to(player.global_position + Vector3(0, 1.1, 0), 0.4)
			player.show_prop("book", 0.8)
			GameState.note_use("book", "book_sehzade")
			hud.bark("SPK_NIHAT", "D17E_N_BOOK", 3.0)
			await _wait(1.0)
		_:
			await hud.think("SPK_TOLGA", "D17E_T_SILENT")
			mehmed.emote("nod")
			await hud.say("SPK_SEHZADE", "D17E_M_SILENT")
	# Çantadakiler: Rubik küpü (şehzade elinde çevirir, köşelerden çözer) ve selfie çubuğu (flaş, sonra karikatür)
	if GameState.has_item("cube"):
		await hud.say("SPK_SEHZADE", "D17E_M_CUBE")
		player.show_prop("cube", 1.0)
		await hud.say("SPK_TOLGA", "D17E_T_CUBE")
		var c := _cube(false)
		await mehmed.receive_item(c, player.global_position + Vector3(0, 1.3, 0))
		await _snap("16_cube", 4.4, mehmed, 0.9)
		await _beat(1.6)
		mehmed.release_item()
		c.queue_free()
		var solved := _cube(true)
		mehmed.hold_item(solved)
		await _snap("17_cube_solved", 0.3, mehmed, 0.9)
		Audio.sfx("ui_confirm", -10.0, 1.2)
		await hud.say("SPK_SEHZADE", "D17E_M_CUBE_2")
		mehmed.release_item()
		solved.queue_free()
		await hud.say("SPK_TOLGA", "D17E_T_CUBE_2")
		GameState.note_use("cube", "cube_sehzade")
		GameState.flags["edirne_cube"] = true
	if GameState.has_item("selfie"):
		await hud.say("SPK_TOLGA", "D17E_T_SELFIE")
		player.show_prop("pole", 2.2)
		await hud.say("SPK_SEHZADE", "D17E_M_SELFIE")
		mehmed.emote("cheer")
		await _beat(0.4)
		Audio.sfx("camera", -2.0)
		mehmed.shut_eyes(0.5)
		await hud.fade_to(0.85, 0.05, Color.WHITE)
		await hud.fade_to(0.0, 0.3, Color.WHITE)
		mehmed.emote("write")
		await _beat(1.2)
		await hud.say("SPK_SEHZADE", "D17E_M_SELFIE_2")
		player.show_prop("sehzade_notebook_tolga", 2.6)
		await _snap("18_selfie_note", 0.45)
		await _beat(1.0)
		GameState.note_use("selfie", "selfie_sehzade")
		GameState.flags["edirne_selfie"] = true
	await hud.say("SPK_SEHZADE", "D17E_M_TO_AVLU")
	mehmed.look_target = null
	# Yolda anlatır: "arkadaşları" aslında rehine (eskiden "rehinelerimizi göstereyim" diyordu)
	get_tree().create_timer(0.3 if GameState.autotest else 2.0).timeout.connect(func():
		if is_instance_valid(hud) and hud.is_inside_tree():
			hud.bark("SPK_SEHZADE", "D17E_M_WAY_HOST", 8.0))
	await _go_together(mehmed, PATH_TO_AVLU, EdirnePalace.TOLGA_AVLU, "UI_OBJ17E_FOLLOW")


## Usturlabın üç halkası ayrı hızlarla döner, yavaşlayıp durur.
func _spin_astro() -> void:
	# Ağı ve cetveli çevirir: yıldızlar levhanın kemerleri üstünde döner (Uluğ Bey'in göğü)
	for spec: Array in [["Rete", TAU * 1.25, 2.6], ["Rule", -TAU * 0.6, 2.0]]:
		var n := palace.astro.find_child(spec[0], true, false) as Node3D
		if n:
			var tw := n.create_tween()
			tw.tween_property(n, "rotation:x", n.rotation.x + float(spec[1]), float(spec[2])).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	Audio.sfx("wood_creak", -16.0, 2.4)


## Rubik küpü: karışık ya da çözülmüş (her yüz tek renk).
func _cube(solved: bool) -> Node3D:
	var n := Node3D.new()
	var cols := [Color("c8323a"), Color("2f5fa8"), Color("3a8a4a"), Color("f2d040"), Color("f4f1ea"), Color("e8803a")]
	Props.box(n, Vector3(0.07, 0.07, 0.07), Vector3.ZERO, Color("1a1a1a"))
	var faces := [[Vector3(0, 0, 1), Vector3.ZERO], [Vector3(0, 0, -1), Vector3(0, 180, 0)], [Vector3(1, 0, 0), Vector3(0, 90, 0)],
		[Vector3(-1, 0, 0), Vector3(0, -90, 0)], [Vector3(0, 1, 0), Vector3(-90, 0, 0)], [Vector3(0, -1, 0), Vector3(90, 0, 0)]]
	for f in 6:
		var nrm: Vector3 = faces[f][0]
		var rot: Vector3 = faces[f][1]
		var face := Node3D.new()
		n.add_child(face)
		face.position = nrm * 0.0355
		face.rotation_degrees = rot
		for i in 9:
			var c: Color = cols[f] if solved else cols[(f * 7 + i * 5) % 6]
			Props.box(face, Vector3(0.02, 0.02, 0.002), Vector3(-0.023 + (i % 3) * 0.023, -0.023 + (i / 3) * 0.023, 0), c)
	return n


# ================================================================ 4 rehine prensler

func _hostages() -> void:
	# Radu oku bırakıp koşa koşa gelir; Vlad başını kaldırmadan yontmayı sürdürür
	mehmed.face_toward(vlad.global_position)
	await _settle_player(EdirnePalace.TOLGA_AVLU, vlad)
	if _shot.is_valid():
		player.face(_p(EdirnePalace.BUTT + Vector3(0, 1.0, 0)))
		await _snap("20_archery", 1.2)
		await _snap("21_vlad_whittle", 0.1, vlad, 0.55)
	_archery = false
	# Radu yayını çimene bırakıp koşar
	radu.unequip("Bow")
	var bow := Node3D.new()
	palace.add_child(bow)
	bow.position = RADU_ARCH + Vector3(0.3, 0.02, 0.2)
	bow.rotation_degrees = Vector3(0, 35, 90)
	Blades.bow_parts(bow)
	var run := _walk_bg(radu, [EdirnePalace.RADU_SPOT], 2.6)
	await hud.say("SPK_SEHZADE", "D17E_M_AVLU")
	await _until(run, 6.0)
	radu.face_toward(player.global_position)
	radu.look_target = player
	radu.emote("wave")
	await hud.say("SPK_RADU", "D17E_R_01")
	mehmed.look_target = player
	await hud.say("SPK_SEHZADE", "D17E_M_DRACUL")
	player.shake(0.2)
	await hud.say("SPK_TOLGA", "D17E_T_DRAC")
	await hud.say("SPK_SEHZADE", "D17E_M_VAMP")
	# Vlad ilk kez başını kaldırır
	vlad.look_target = player
	_turn_to(vlad)
	await hud.say("SPK_VLAD", "D17E_V_01")
	await hud.say("SPK_VLAD", "D17E_V_02")
	mehmed.look_target = vlad
	await hud.say("SPK_SEHZADE", "D17E_M_VLAD")
	vlad.look_target = null       # yontmaya döner
	await hud.say("SPK_VLAD", "D17E_V_03")
	radu.emote("laugh")
	await hud.say("SPK_RADU", "D17E_R_02")
	await hud.say("SPK_RADU", "D17E_R_03")
	vlad.look_target = radu
	await hud.say("SPK_VLAD", "D17E_V_04")
	_vlad_brood()
	vlad.look_target = player
	mehmed.look_target = player
	await hud.think("SPK_TOLGA", "D17E_T_PANIC")
	var v := await _choose(["UI_C17E_VLAD_KEBAB", "UI_C17E_VLAD_POLICY", "UI_C17E_VLAD_LEGEND", "UI_C17E_VLAD_NONE"],
		["kebab", "policy", "legend", "none"], "vlad")
	GameState.flags["edirne_vlad"] = v
	match v:
		"kebab":
			await _kebab()
		"policy":
			await _policy()
		"legend":
			await _legend()
		_:
			# Tolga bir adım geri çekilir; Vlad yontmayı sürdürür, sonra uzun uzun bakar
			if not GameState.autotest:
				var away := player.global_position - vlad.global_position
				away.y = 0.0
				var tw := create_tween()
				tw.tween_property(player, "global_position", player.global_position + away.normalized() * 0.7, 0.6).set_trans(Tween.TRANS_SINE)
				await tw.finished
			await hud.say("SPK_TOLGA", "D17E_T_NONE")
			vlad.look_target = null
			vlad.set_activity("whittle")
			await _beat(1.4)
			vlad.look_target = player
			await hud.say("SPK_VLAD", "D17E_V_NONE")
			await hud.say("SPK_TOLGA", "D17E_T_NONE_2")
			_vlad_brood()
			await _snap("30_none", 0.4, vlad, 0.9)
			await _beat(1.2)


## Vlad çakıyla sopayı kucağına bırakır, kollarını kavuşturur (taburede oturur).
func _vlad_brood() -> void:
	vlad.set_activity("sit")
	vlad.emote("arms_cross")


## Vlad taburesinden kalkar, kütüğün yanına bir adım atar (taburenin içinde dikilmesin).
func _vlad_up() -> void:
	vlad.set_activity("")
	vlad.remove_meta("no_unclip")
	await _beat(0.3)
	await _walk(vlad, [VLAD_UP], 0.8)
	vlad.face_toward(player.global_position)


## Kebap: Radu matbaha koşar, Vlad yonttuğu sopaları uzatır, Radu siniyle et ve soğan getirir; Tolga şişleri
## mangalın ızgarasına dizer, ateş yanar; E basılı tutuldukça şişler döner, et kızarır (rengi çiğden kahveye), duman
## ve cızırtı artar. Sonra Vlad şişi alır, koklar, ısırır; Radu sevinir, şehzade tadar.
func _kebab() -> void:
	await hud.say("SPK_TOLGA", "D17E_T_KEB")
	radu.emote("cheer")
	await hud.say("SPK_RADU", "D17E_R_KEB")
	radu.look_target = null
	var fetch := _walk_bg(radu, RADU_TO_DOOR, 2.8)
	# Vlad kalkar, yonttuğu dört sopayı bir demet hâlinde uzatır
	await _vlad_up()
	vlad.look_target = player
	var bundle := Node3D.new()
	for k in 4:
		# Yelpaze gibi açılmış dört sivri sopa (uçları öne)
		var st := Node3D.new()
		bundle.add_child(st)
		st.rotation_degrees = Vector3(0, -9 + k * 6, 0)
		st.position = Vector3(-0.02 + k * 0.014, k * 0.006, 0)
		Props.cyl(st, 0.011, 0.55, Vector3.ZERO, Color("c8a878"), Vector3(90, 0, 0), 5)
		Props.cyl(st, 0.011, 0.07, Vector3(0, 0, -0.31), Color("e8d8b0"), Vector3(-90, 0, 0), 5, 0.002)
	vlad.hold_item(bundle, false, false)
	await _snap("22_bundle", 0.3, vlad, 0.9)
	await hud.say("SPK_VLAD", "D17E_V_KEB_0")
	await vlad.reach_to(player.global_position + Vector3(0, 1.1, 0), 0.3)
	vlad.release_item()
	bundle.queue_free()
	player.hand_gesture("reach")
	await _until(fetch, 8.0)
	radu.visible = false             # matbaha girdi
	await _beat(1.6)
	# Radu bakır siniyle döner
	radu.visible = true
	radu.carry("tray")
	await _walk(radu, [RADU_TRAY], 2.0)
	radu.face_toward(player.global_position)
	radu.look_target = player
	await _snap("23_tray", 0.25, radu, 0.8)
	await hud.say("SPK_RADU", "D17E_R_KEB_BACK")
	# Sini kütüğün üstüne konur; Radu mangalın öbür yanına çekilir, Tolga mangalın başına geçer
	var tray := radu.drop_carry()
	if tray:
		var tt := tray.create_tween()
		tt.tween_property(tray, "global_position", _p(EdirnePalace.LOG + Vector3(0.22, 0.68, 0.0)), 0.05 if GameState.autotest else 0.4)
		tt.parallel().tween_property(tray, "global_rotation", Vector3.ZERO, 0.05 if GameState.autotest else 0.4)
	# Kısa ve engelsiz bir çekiliş: Walker oyuncunun dibinde beklemesin diye doğrudan adımlarla
	var aside := _walk_bg(radu, [RADU_WATCH], 1.4, true)
	await _settle_player(COOK_SPOT, null)
	await _turn(_p(EdirnePalace.BRAZIER + Vector3(0, 0.62, 0)))
	await _until(aside, 4.0)
	radu.face_toward(_p(EdirnePalace.BRAZIER))
	palace.light_brazier(0.08)
	Audio.sfx("fire_crackle", -6.0)
	# Izgara: beş demir çubuk (doğu-batı); dört şiş (kuzu, soğan, kuzu, soğan, kuzu) çubukların üstüne, Tolga'ya enlemesine
	var grill := Node3D.new()
	palace.add_child(grill)
	grill.position = EdirnePalace.BRAZIER + Vector3(0, 0.64, 0)
	for k in 5:
		Props.cyl(grill, 0.006, 0.7, Vector3(0, 0, -0.24 + k * 0.12), Color("3a3634"), Vector3(0, 0, 90), 4)
	var meat := Props.mat(Color("b4363a")).duplicate() as StandardMaterial3D
	var onion := Props.mat(Color("f0e6d0")).duplicate() as StandardMaterial3D
	var skewers: Array[Node3D] = []
	for k in 4:
		var sk := Node3D.new()
		grill.add_child(sk)
		sk.position = Vector3(-0.15 + k * 0.1, 0.035, 0)
		Props.cyl(sk, 0.007, 0.8, Vector3.ZERO, Color("c8a878"), Vector3(90, 0, 0), 5)
		for j in 5:
			var piece := Props.box(sk, Vector3(0.045, 0.045, 0.05), Vector3(0, 0, -0.2 + j * 0.1), Color("b4363a"), Vector3(0, 0, j * 17.0))
			piece.material_override = meat if j % 2 == 0 else onion
		sk.visible = false
		skewers.append(sk)
	for sk in skewers:
		player.hand_gesture("reach")
		await _beat(0.2)
		sk.visible = true
		Audio.sfx("fire_crackle", -10.0, 1.8)
		await _beat(0.25)
	var smoke := Vfx.steam(palace, EdirnePalace.BRAZIER + Vector3(0, 0.75, 0))
	smoke.scale_amount_min = 0.3
	smoke.scale_amount_max = 0.7
	await _cook(skewers, meat, onion, smoke)
	# Vlad bir şiş alır: koklar, ısırır
	var mine := skewers[1]
	var held := mine.duplicate() as Node3D
	mine.visible = false
	held.rotation = Vector3.ZERO
	var vlad_home := vlad.global_position
	await _step_to(vlad, mine.global_position)          # mangalın başına gelip alır (şiş 2,7 m uçuyordu)
	await vlad.receive_item(held, mine.global_position, false, false)
	_step_to(vlad, vlad_home, false)
	vlad.emote("sniff")
	await _beat(1.0)
	vlad.emote("eat")
	Audio.sfx("chop", -18.0, 2.2)
	await _snap("25_vlad_eat", 0.3, vlad, 1.0)
	await hud.say("SPK_VLAD", "D17E_V_KEB")
	radu.emote("cheer")
	await hud.say("SPK_RADU", "D17E_R_KEB_2")
	# Şehzade de bir şiş alır, tadar
	var his := skewers[2].duplicate() as Node3D
	skewers[2].visible = false
	his.rotation = Vector3.ZERO
	var mehmed_home := mehmed.global_position
	await _step_to(mehmed, skewers[2].global_position)   # Şehzade de mangala gelir (4,3 m uçuyordu)
	await mehmed.receive_item(his, skewers[2].global_position, false, false)
	_step_to(mehmed, mehmed_home, false)
	mehmed.emote("eat")
	await hud.say("SPK_SEHZADE", "D17E_M_KEB")
	vlad.look_target = player
	await hud.say("SPK_VLAD", "D17E_V_KEB_2")
	await hud.say("SPK_TOLGA", "D17E_T_KEB_2")
	smoke.emitting = false


## Şişleri çevir (E basılı): basılı tutuldukça şişler kendi ekseninde döner, et kızarır (çiğ kırmızıdan kahveye),
## duman koyulaşır, cızırdar; Tolga'nın eli her çevirişte uzanır. Bırakınca durur; uzun süre çevrilmezse bir yüz
## kararır, alev parlar ve Vlad uyarır. Otomatik testte kendiliğinden çevrilir.
func _cook(skewers: Array[Node3D], meat: StandardMaterial3D, onion: StandardMaterial3D, smoke: CPUParticles3D) -> void:
	var raw := Color("b4363a")
	var done := Color("5e3418")
	onion.albedo_color = Color("f0e6d0")
	var seconds := 2.6
	hud.set_qte(tr("UI_QTE17E_TURN"))
	var h := 0.0
	var gest := 0.0
	var idle := 0.0
	var warned := false
	var snaps := [0.0, 0.5, 0.95]
	while h < seconds:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		var turning := Input.is_action_pressed("interact") or GameState.autotest
		if turning:
			idle = 0.0
			h += dt * (6.0 if GameState.autotest else 1.0)
			for sk in skewers:
				if sk.visible:
					sk.rotation.z += dt * 4.5
			gest -= dt
			if gest <= 0.0:
				gest = 0.5
				player.hand_gesture("reach")
				Audio.sfx("fire_crackle", -12.0, randf_range(1.6, 2.0))     # cızırtı
		else:
			idle += dt
			if idle > 4.0 and not warned:
				# Çevrilmeyen yüz kararır, alev parlar
				warned = true
				meat.albedo_color = meat.albedo_color.darkened(0.35)
				Vfx.sparks(palace, EdirnePalace.BRAZIER + Vector3(0, 0.7, 0), 0.6)
				Audio.sfx("fire_crackle", -4.0, 0.8)
				hud.bark("SPK_VLAD", "D17E_V_BURN", 2.5)
		var p := clampf(h / seconds, 0.0, 1.0)
		if _shot.is_valid() and snaps.size() > 0 and p >= snaps[0]:
			await _snap("24_grill_%02d" % int(snaps.pop_front() * 100.0), 0.05)
		if not warned or turning:
			meat.albedo_color = meat.albedo_color.lerp(raw.lerp(done, p), clampf(dt * 6.0, 0.0, 1.0))
			onion.albedo_color = Color("f0e6d0").lerp(Color("c8904a"), p)
		smoke.scale_amount_min = lerpf(0.3, 1.0, p)
		smoke.scale_amount_max = lerpf(0.7, 2.0, p)
		hud.set_red_progress(p, tr("UI_BAR17E_COOK"))
	meat.albedo_color = done
	onion.albedo_color = Color("c8904a")
	hud.set_red_progress(0.0)
	hud.set_qte("")
	Audio.sfx("ui_confirm", -12.0, 1.3)


## Poliçe: Tolga poliçeyi uzatır (Vlad'ın eline geçer, okur); "kazık" dendiğinde Vlad sivri sopasını kaldırıp ona bakar;
## sonra poliçeyi kütüğe koyup mühür yüzüğünü basar.
func _policy() -> void:
	await hud.say("SPK_TOLGA", "D17E_T_POL")
	await _vlad_up()
	player.show_prop("policy", 1.4)
	await _beat(1.0)
	var paper := Node3D.new()
	Props.box(paper, Vector3(0.2, 0.004, 0.27), Vector3.ZERO, Color("f7f3ea"))
	Props.box(paper, Vector3(0.2, 0.0045, 0.035), Vector3(0, 0.001, -0.11), Color("2a4a8a"))
	await vlad.receive_item(paper, player.global_position + Vector3(0, 1.2, 0), true)
	await _snap("26_policy_read", 0.2, vlad, 1.0)
	await hud.say("SPK_VLAD", "D17E_V_POL")
	await hud.say("SPK_TOLGA", "D17E_T_POL_2")
	# Poliçe kütüğe; elde sivri sopa: ucuna uzun uzun bakar
	vlad.release_item()
	paper.queue_free()
	var sheet := Props.box(palace, Vector3(0.2, 0.004, 0.27), EdirnePalace.LOG + Vector3(0.12, 0.665, 0.0), Color("f7f3ea"))
	sheet.rotation_degrees = Vector3(0, 20, 0)
	Props.box(palace, Vector3(0.2, 0.005, 0.035), EdirnePalace.LOG + Vector3(0.1, 0.666, -0.1), Color("2a4a8a"), Vector3(0, 20, 0))
	var stake := Node3D.new()
	Props.cyl(stake, 0.016, 0.62, Vector3.ZERO, Color("b89a6a"), Vector3(90, 0, 0), 6)
	Props.cyl(stake, 0.016, 0.1, Vector3(0, 0, -0.36), Color("e8d8b0"), Vector3(-90, 0, 0), 6, 0.002)
	vlad.hold_item(stake, false, false)
	await _snap("27_stake", 0.3, vlad, 1.0)
	await _beat(0.6)
	await hud.say("SPK_VLAD", "D17E_V_POL_2")
	await hud.say("SPK_TOLGA", "D17E_T_POL_3")
	vlad.release_item()
	stake.queue_free()
	# Mühür yüzüğü: Vlad kütüğe eğilip basar, kırmızı mühür kalır
	vlad.face_toward(sheet.global_position)
	vlad.emote("stamp")
	await _wait(0.25)
	Audio.sfx("stamp", -4.0, 0.9)
	Props.cyl(palace, 0.03, 0.002, EdirnePalace.LOG + Vector3(0.14, 0.668, 0.05), Color("a8182a"), Vector3.ZERO, 10)
	vlad.face_toward(player.global_position)
	await hud.say("SPK_VLAD", "D17E_V_POL_3")
	mehmed.emote("facepalm")
	await hud.say("SPK_SEHZADE", "D17E_M_POL")


## Efsane: mangal yanar, Tolga ellerini ateşin önünde birleştirir; duvara kanat çırpan bir yarasa gölgesi düşer. Radu
## korkup ağabeyinin arkasına saklanır; Vlad gölgeye bakar, sonra not alır.
func _legend() -> void:
	await hud.say("SPK_TOLGA", "D17E_T_LEG")
	palace.light_brazier()
	Audio.sfx("fire_crackle", -8.0)
	player.hand_gesture("show")
	var bat := _bat_shadow()
	_turn(bat.global_position, 0.6)
	radu.emote("surprise")
	await _snap("28_bat", 0.7)
	await hud.say("SPK_RADU", "D17E_R_LEG_0")
	var hide := _walk_bg(radu, [EdirnePalace.VLAD_SPOT + Vector3(0.55, 0, 0.6)], 2.2)
	vlad.look_target = bat
	await hud.say("SPK_VLAD", "D17E_V_LEG")
	_turn_to(vlad)
	vlad.look_target = player
	await hud.say("SPK_TOLGA", "D17E_T_LEG_2")
	await _until(hide, 4.0)
	await _snap("29_radu_hide", 0.2, vlad, 0.8)
	radu.face_toward(player.global_position)
	radu.look_target = bat if is_instance_valid(bat) else player
	# Vlad not alır: çakısıyla kütüğe kazır (pelerin, yarasa, sarımsak); kütükte üç çentik kalır
	vlad.look_target = null
	vlad.set_activity("whittle")
	for k in 3:
		Audio.sfx("chop", -16.0, 1.9 + k * 0.1)
		Props.box(palace, Vector3(0.006, 0.05, 0.004), EdirnePalace.LOG + Vector3(-0.12 + k * 0.05, 0.5, 0.245), Color("3a2a1a"),
			Vector3(0, 0, -12 + k * 10))
		await _beat(0.35)
	await hud.say("SPK_VLAD", "D17E_V_LEG_2")
	radu.look_target = vlad
	radu.emote("cheer")
	await hud.say("SPK_RADU", "D17E_R_LEG")


## Rehine odalarının duvarına düşen yarasa gölgesi: mangalın ışığında kanat çırpar (Tolga'nın el gölgesi).
func _bat_shadow() -> Node3D:
	var bat := Node3D.new()
	palace.add_child(bat)
	var wall_x := -EdirnePalace.WALL_X + 3.42
	bat.position = Vector3(wall_x, 2.0, -5.6)
	bat.rotation_degrees = Vector3(0, 90, 0)
	var shade := Color(0.05, 0.04, 0.06)
	var body := Props.ball(bat, 0.12, Vector3.ZERO, shade, Vector3(0.7, 1.0, 0.05), 8)
	body.material_override = Props.mat(Color(0.05, 0.04, 0.06, 0.62), 0.0, true, "", false)
	var wings: Array[Node3D] = []
	for sx in [-1, 1]:
		var w := Node3D.new()
		bat.add_child(w)
		w.position = Vector3(sx * 0.06, 0.04, 0)
		for k in 3:
			var seg := Props.box(w, Vector3(0.22, 0.12 - k * 0.025, 0.01), Vector3(sx * (0.11 + k * 0.08), -k * 0.035, 0), shade, Vector3(0, 0, -sx * (10 + k * 12)))
			seg.material_override = body.material_override
		wings.append(w)
	bat.scale = Vector3.ONE * 0.01
	var grow := bat.create_tween()
	grow.tween_property(bat, "scale", Vector3.ONE * 2.2, 0.6).set_trans(Tween.TRANS_BACK)
	for i in 2:
		var w: Node3D = wings[i]
		var sx := -1.0 if i == 0 else 1.0
		var tw := w.create_tween().set_loops(14)
		tw.tween_property(w, "rotation:z", sx * 0.55, 0.22).set_trans(Tween.TRANS_SINE)
		tw.tween_property(w, "rotation:z", -sx * 0.25, 0.22).set_trans(Tween.TRANS_SINE)
	var drift := bat.create_tween()
	drift.tween_property(bat, "position:z", -4.2, 5.0).set_trans(Tween.TRANS_SINE)
	drift.tween_property(bat, "scale", Vector3.ONE * 0.01, 0.8)
	drift.tween_callback(bat.queue_free)
	return bat


# ================================================================ 5 kaçış

func _escape() -> void:
	# Halil Paşa ve muhafızlar kapıdan koşarak gelir; Halil parmağıyla gösterir
	halil.visible = true
	halil.position = GATE_IN
	var spots := [EdirnePalace.TOLGA_AVLU + Vector3(2.2, 0, -4.6), EdirnePalace.TOLGA_AVLU + Vector3(4.4, 0, -4.2)]
	var runs: Array[Run] = []
	for i in guards.size():
		guards[i].set_meta("no_audit", true)
		# Önce kuzeye (gül tarhlarının arasından değil, yanından), sonra avluya
		var gp := palace.to_local(guards[i].global_position)
		runs.append(_walk_bg(guards[i], [Vector3(gp.x, 0.0, -12.6), spots[i]], 3.4))
	await _walk(halil, [EdirnePalace.TOLGA_AVLU + Vector3(3.2, 0, -3.4)], 3.0)
	for r in runs:
		await _until(r, 8.0)
	halil.face_toward(player.global_position)
	for g in guards:
		g.face_toward(player.global_position)
	_turn_to(halil)
	halil.emote("point")
	await _snap("31_halil_point", 0.3, halil, 1.3)
	await hud.say("SPK_HALIL", "D17E_H_SPY")
	await hud.say("SPK_TOLGA", "D17E_T_SPY")
	var who := String(GameState.flags.get("edirne_who", "hizir"))
	mehmed.look_target = player
	mehmed.emote("point")
	var run_line: Array = RUN_LINE.get(who, RUN_LINE["hizir"])
	await hud.say(run_line[0], run_line[1])
	# Havuza koş: muhafızlar peşinde. Yakalanan da havuza atılır (yenilgi yok)
	Audio.music("chase")
	var pool_at := _p(EdirnePalace.POOL)
	var caught := false
	if GameState.autotest:
		player.global_position = pool_at + Vector3(0.6, 0.6, 0.2)
		await _wait(0.2)
	else:
		player.frozen = false
		hud.set_objective(tr("UI_OBJ17E_POOL"), pool_at + Vector3(0, 0.8, 0))
		hud.set_chase(tr("UI_CHASE17E"), 0.0)
		var t := 0.0
		while t < 40.0:
			await get_tree().process_frame
			var dt := get_process_delta_time()
			t += dt
			var lp := palace.to_local(player.global_position)
			if absf(lp.x) < EdirnePalace.POOL_SIZE.x * 0.5 + 0.6 and absf(lp.z) < EdirnePalace.POOL_SIZE.y * 0.5 + 0.6:
				break
			var near := 99.0
			for g in guards:
				var to := player.global_position - g.global_position
				to.y = 0.0
				near = minf(near, to.length())
				if to.length() > 0.8:
					g.global_position += to.normalized() * minf(to.length() - 0.8, 3.1 * dt)
					g.face_toward(player.global_position)
			hud.set_chase(tr("UI_CHASE17E"), clampf(1.0 - near / 8.0, 0.0, 1.0))
			if near < 1.0:
				caught = true
				break
		hud.set_objective("")
		hud.set_chase("", 0.0)
		player.frozen = true
		if caught or t >= 40.0:
			# İki muhafız Tolga'yı kollarından tutar, sallar, havuza fırlatır
			var here := player.global_position
			for i in guards.size():
				guards[i].global_position = here + player.global_transform.basis.x * (0.75 if i == 0 else -0.75)
				guards[i].face_toward(here)
			await hud.say("SPK_HALIL", "D17E_H_TOSS")
			await _toss(here, pool_at + Vector3(0.6, EdirnePalace.WATER_Y, 0.2))
		else:
			await _dive(pool_at + Vector3(0.6, EdirnePalace.WATER_Y, 0.2))
	# Çocuklar havuz kenarına koşar
	var kid_runs: Array[Run] = []
	for spec in [[mehmed, Vector3(-1.6, 0.0, 2.95)], [radu, Vector3(-0.4, 0.0, 3.1)], [vlad, Vector3(0.9, 0.0, 2.95)]]:
		var k: Person = spec[0]
		# Eldekini bırakır (şiş, poliçe): elde bir şey tutan Rig kilitli kalır, bacaklar yürümez
		k.release_item()
		k.untuck_free()
		k.set_activity("")
		k.remove_meta("no_unclip")
		k.look_target = null
		kid_runs.append(_walk_bg(k, [Vector3((spec[1] as Vector3).x, 0.0, 5.5), spec[1]], 2.8))
	Audio.sfx("splash", 0.0)
	Vfx.splash(palace, EdirnePalace.POOL + Vector3(0.6, EdirnePalace.WATER_Y, 0.2), 1.4)
	hud.wet(3.0)
	hud.bark("SPK_NIHAT", "D17E_N_PULL", 3.0)
	for r in kid_runs:
		await _until(r, 7.0)
	for k in [mehmed, radu, vlad]:
		(k as Person).look_target = player
	_turn_to(mehmed)
	mehmed.emote("wave")
	radu.emote("wave")
	await _snap("32_kids_wave", 0.3, mehmed, 0.6)
	var bye_line: Array = BYE_LINE.get(who, BYE_LINE["hizir"])
	await hud.say(bye_line[0], bye_line[1])
	vlad.emote("arms_cross")
	await hud.say("SPK_TOLGA", "D17E_T_BYE")
	# Ters girdap: 1444 → zamanın dışı
	var v := TimeVortex.new()
	host.add_child(v)
	await v.play_text("1444", tr("UI_JUMP_BUREAU"), 0.5 if GameState.autotest else 2.4, false, tr("D17E_CAP_BACK"))
	Audio.sfx("machine_jump", -4.0)
	hud.set_fade(1.0, Color.WHITE)
	v.queue_free()
	_leave_palace()


## Havuza dalış: kısa bir sıçrayış, kamera suya döner, su altı mavisi.
func _dive(into: Vector3) -> void:
	var a := player.global_position
	var top := (a + into) * 0.5 + Vector3(0, 1.4, 0)
	var tw := create_tween()
	tw.tween_method(func(v: float):
		player.global_position = a.lerp(top, v).lerp(top.lerp(into, v), v), 0.0, 1.0, 0.8)
	tw.parallel().tween_property(player.camera, "rotation:x", -1.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tw.finished
	await hud.fade_to(0.55, 0.12, Color("2a6a9a"))
	await _wait(0.5)
	await hud.fade_to(0.0, 0.35, Color("2a6a9a"))
	player.camera.rotation.x = 0.0


## Muhafızlar sallar ve fırlatır: oyuncu iki salınımdan sonra yay çizerek havuza düşer.
func _toss(from: Vector3, into: Vector3) -> void:
	for i in 2:
		player.shake(0.25)
		Audio.sfx("heave_shout", -10.0, 1.1 + i * 0.1)
		await _wait(0.35)
	var top := (from + into) * 0.5 + Vector3(0, 2.4, 0)
	var tw := create_tween()
	tw.tween_method(func(v: float):
		player.global_position = from.lerp(top, v).lerp(top.lerp(into, v), v), 0.0, 1.0, 1.0)
	tw.parallel().tween_property(player, "rotation:y", player.rotation.y + TAU, 1.0)
	await tw.finished
	Audio.sfx("fall_scream", -10.0, 1.2)


func _leave_palace() -> void:
	_archery = false
	bureau.env_node.environment = _bureau_env
	bureau.visible = true
	palace.queue_free()
	palace = null
	Audio.voice_space("room")
	Audio.ambience("")
	Audio.music("bureau")


# ================================================================ 6 Büro'da sonrası

func _aftermath() -> void:
	await get_tree().physics_frame
	player.global_position = bureau.to_global(Bureau.LIFT_IN) + Vector3(0, 0.05, 0)
	player.face(bureau.to_global(Vector3(Bureau.COR_W / 2, 1.45, Bureau.LIFT_Z)))
	nihat.position = Bureau.NIHAT_PANEL_POS
	nihat.look_target = player
	await hud.fade_to(0.0, 0.6, Color.WHITE)
	hud.wet(3.5)
	Audio.sfx("door_open", -6.0)
	await bureau.open_lift()
	await _wait(0.4)
	await hud.fade_to(1.0, 0.2)
	player.global_position = bureau.to_global(Bureau.LIFT_OUT) + Vector3(0, 0.05, 0)
	player.face(nihat.global_position + Vector3(0, 1.5, 0))
	await hud.fade_to(0.0, 0.3)
	# Damlar: sırılsıklam Tolga'nın ayağının dibine su damlar
	for i in 3:
		Audio.sfx("splash", -24.0, 2.6 + i * 0.2)
		await _beat(0.25)
	await hud.say("SPK_NIHAT", "D17E_N_BACK_1")
	await hud.say("SPK_TOLGA", "D17E_T_BACK_1")
	nihat.emote("offer2")
	player.show_prop("towel", 2.2)
	await _snap("33_towel", 0.45)
	await hud.say("SPK_NIHAT", "D17E_N_TOWEL")
	# Müfide masasından koşar
	var mu := bureau.mufide
	var mu_home := mu.position
	await _bureau_walk(mu, Vector3(0.7, 0, Bureau.LIFT_Z + 2.1), 3.0)
	mu.face_toward(nihat.global_position)
	await _snap("34_mufide", 0.1, mu, 1.4)
	await hud.say("SPK_MUFIDE", "D17E_MU_01")
	await hud.say("SPK_NIHAT", "D17E_N_OFFICE")
	# Ofise: Vikipedi ekranında değişiklik farkı
	await hud.fade_to(1.0, 0.4)
	mu.position = mu_home
	nihat.position = Bureau.NIHAT_OFFICE_POS
	player.global_position = bureau.to_global(BOARD_VIEW) + Vector3(0, 0.05, 0)
	var vlad_pick := String(GameState.flags.get("edirne_vlad", "none"))
	var diff := wiki_diff(board, vlad_pick)
	player.face(board.global_position)
	await hud.fade_to(0.0, 0.5)
	Audio.sfx("typewriter_bell", -6.0)
	await _wait(0.6 if GameState.autotest else 1.6)
	nihat.look_target = player
	nihat.emote("point")
	await hud.say("SPK_NIHAT", "D17E_N_META")
	await hud.say("SPK_TOLGA", "D17E_T_META")
	await hud.say("SPK_NIHAT", "D17E_N_META_2")
	for line: Array in WHAT_LINE.get(vlad_pick, WHAT_LINE["none"]):
		await hud.say(line[0], line[1])
	# Düzeltme damgası: asıl tarih geri gelir, dipnot kalır
	nihat.stamp()
	Audio.sfx("stamp", -2.0)
	await hud.say("SPK_NIHAT", "D17E_N_FIX")
	_wiki_fix(diff, vlad_pick)
	await _wait(0.4)
	await _snap("35_wiki_fixed", 0.2)
	await hud.say("SPK_TOLGA", "D17E_T_FIX")
	await hud.say("SPK_NIHAT", "D17E_N_FIX_2")


## Büro'da yürüyüş (Müfide): Büro yerel noktasına Walker ile.
func _bureau_walk(who: Person, local: Vector3, spd: float) -> void:
	var w := Walker.go(who, bureau.to_global(local), spd * (2.0 if GameState.autotest else 1.0))
	await w.arrived
	who.position = local



# ================================================================ Vikipedi

## Vikipedi ekranı: değişiklik farkı (kırmızı üstü çizili eski satır, yeşil yeni satır, [kaynak belirtilmeli]).
## Döner: eklenen düğüm (düzeltmede dipnota döner).
static func wiki_diff(b: Node3D, vlad_pick: String) -> Node3D:
	for c in b.get_children():
		if c is Label3D or (c is MeshInstance3D and c.position.z > 0.02):
			c.visible = false
	var n := Node3D.new()
	n.name = "WikiDiff"
	b.add_child(n)
	var k := vlad_pick.to_upper()
	Props.label(n, TranslationServer.translate("PROP17E_DIFF_HEAD"), Vector3(0, 0.47, 0.036), 22, Color("202122"), Vector3.ZERO, 1.5)
	Props.box(n, Vector3(1.56, 0.26, 0.004), Vector3(0, 0.25, 0.034), Color("ffe0de"))
	Props.box(n, Vector3(1.56, 0.62, 0.004), Vector3(0, -0.22, 0.034), Color("dcf5dc"))
	var ol := _wrap(n, "− " + TranslationServer.translate("PROP17E_DIFF_OLD_" + k), Vector3(0, 0.25, 0.038), 17, Color("a01818"), 1.44)
	Props.box(n, Vector3(minf(1.4, Props.text_width(ol.text, ol.font_size, ol.pixel_size)), 0.008, 0.002), Vector3(0, 0.25, 0.04), Color("a01818"))
	_wrap(n, "+ " + TranslationServer.translate("PROP17E_DIFF_NEW_" + k), Vector3(0, -0.2, 0.038), 15, Color("146014"), 1.44)
	Props.label(n, TranslationServer.translate("PROP17_WIKI_CN"), Vector3(0.45, -0.49, 0.038), 13, Color("cc2a2a"), Vector3.ZERO)
	return n


## Ekranda satırlara sarılan yazı (width_m metre genişliğinde).
static func _wrap(parent: Node3D, text: String, pos: Vector3, size: int, color: Color, width_m: float) -> Label3D:
	var l := Props.label(parent, text, pos, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.width = width_m / l.pixel_size
	return l


## Düzeltme damgası: fark kalkar, asıl satır geri gelir, yanında dipnot (tarih inatçıdır; dipnotlar daha inatçı).
func _wiki_fix(diff: Node3D, vlad_pick: String) -> void:
	if is_instance_valid(diff):
		diff.queue_free()
	var n := Node3D.new()
	n.name = "WikiFixed"
	board.add_child(n)
	var k := vlad_pick.to_upper()
	Props.label(n, tr("PROP17E_DIFF_HEAD"), Vector3(0, 0.47, 0.036), 22, Color("202122"), Vector3.ZERO, 1.5)
	_wrap(n, tr("PROP17E_DIFF_OLD_" + k), Vector3(0, 0.2, 0.038), 18, Color("202122"), 1.44)
	_wrap(n, tr("PROP17E_FOOT_" + k) + " " + tr("PROP17_WIKI_CN"), Vector3(0, -0.06, 0.038), 16, Color("8a4a1a"), 1.44)
	Props.box(n, Vector3(0.5, 0.16, 0.01), Vector3(0.42, -0.36, 0.04), Color("c8262f"), Vector3(0, 0, -8))
	Props.label(n, tr("PROP17E_FIXED"), Vector3(0.42, -0.36, 0.046), 16, Color("fff0e0"), Vector3(0, 0, -8), 0.48)




# ================================================================ çekimler (--flag=shots17:edirne / edirne_live)

## Görsel tur. "edirne": durağan kareler (kapak, asansör, arıza, ıslaklık, Vikipedi, gönderiş). "edirne_live": ara bölüm
## gerçekten oynanır (otomatik test hızında, seçimler --flag=shots_variant:<varyant> ile), ana anlarda _snap kare alır:
## yürüyüşler, oturuş, uzanışlar, eldeki eşyalar, ızgara üç aşamada. Bölüm 17'nin _run_shots'ından çağrılır.
func shots(h: Node3D, hd: Hud, pl: Player, bu: Bureau, ni: Person, bo: Node3D, shot: Callable) -> void:
	if str(GameState.flags.get("shots17", "")) == "edirne_live":
		GameState.autotest = true
		GameState.autotest_variant = str(GameState.flags.get("shots_variant", ""))
		_shot = shot
		await run(h, hd, pl, bu, ni, bo)
		return
	host = h
	hud = hd
	player = pl
	bureau = bu
	nihat = ni
	board = bo
	host.add_child(self)
	hud.set_fade(0.0)
	# Asansör: Nihat panelde, kadran 1453
	player.global_position = bureau.to_global(Bureau.LIFT_FRONT + Vector3(0.6, 0, 1.6)) + Vector3(0, 0.05, 0)
	nihat.position = Bureau.NIHAT_PANEL_POS
	player.face(bureau.to_global(Vector3(-1.6, 1.6, Bureau.LIFT_Z + 0.6)))
	bureau.set_dial("1453")
	await bureau.open_lift()
	await _wait(0.4)
	await shot.call("c17e_01_lift.png")
	# Arıza girdabı (ortasında)
	var v := TimeVortex.new()
	host.add_child(v)
	v._fit(4)
	v._year.text = "HATA"
	v._year.modulate.a = 1.0
	v._mat.set_shader_parameter("prog", 0.55)
	v._mat.set_shader_parameter("glitch", 1.0)
	v._caption.text = tr("D17E_CAP_GLITCH")
	v._caption.modulate.a = 1.0
	await _wait(0.2)
	await shot.call("c17e_02_glitch.png")
	v.queue_free()
	_enter_palace()
	_archery = false
	await _wait(1.0)
	# Havuzdan çıkış: ıslak ekran, çınar altında okuyan şehzade
	player.global_position = _p(Vector3(-1.2, 0.05, 2.75))
	_look(mehmed)
	hud.wet(3.0)
	await _wait(0.5)
	await shot.call("c17e_03_pool.png")
	await _wait(3.0)
	# Kapak (assets/art/covers/ch17e.png): üç çocuk çınarın önünde; arkada Dershâne'de Gürânî, surun ardında
	# yapımdaki Üç Şerefeli
	var cam := _p(Vector3(2.6, 0.05, 3.4))
	var kids: Array[Person] = [vlad, mehmed, radu]
	var spots: Array[Vector3] = [Vector3(1.6, 0, 6.6), Vector3(2.75, 0, 6.2), Vector3(3.85, 0, 6.5)]
	var homes: Array[Vector3] = []
	for i in kids.size():
		homes.append(kids[i].position)
		kids[i].set_activity("")
		kids[i].position = spots[i]
		kids[i].face_toward(cam)
		kids[i].look_target = player
	mehmed.release_item()
	player.global_position = cam
	player.face(_p(Vector3(2.75, 1.45, 6.4)))
	radu.emote("wave")
	hud.visible = false
	await _wait(0.7)
	await shot.call("c17e_00_cover.png")
	hud.visible = true
	for i in kids.size():
		kids[i].position = homes[i]
		kids[i].look_target = null
	vlad.set_activity("whittle")
	# Avlu: Vlad taburesinde yontar (çakı, sopa, talaş), mangal yanar
	mehmed.position = EdirnePalace.MEHMED_AVLU
	mehmed.face_toward(vlad.global_position)
	palace.light_brazier()
	player.global_position = _p(EdirnePalace.TOLGA_AVLU + Vector3(0.4, 0.05, 0.2))
	player.face(vlad.global_position + Vector3(0, 0.6, 0))
	await _wait(2.5)
	await shot.call("c17e_06_hostages.png")
	_leave_palace()
	# Büro: Vikipedi farkı
	await _wait(0.3)
	var pick := str(GameState.flags.get("shots_vlad", "kebab"))
	wiki_diff(board, pick)
	player.global_position = bureau.to_global(BOARD_VIEW) + Vector3(0, 0.05, 0)
	player.face(board.global_position)
	await _wait(0.5)
	await shot.call("c17e_08_wiki.png")
	# Gerçek gönderiş: Büro'dan kuşatmanın ilk sayfasına giden girdap (ortasında)
	var j := TimeVortex.new()
	host.add_child(j)
	var to := Siege.date_label(36)
	j._fit(to.length())
	j._year.text = to
	j._year.modulate.a = 1.0
	j._mat.set_shader_parameter("prog", 0.5)
	j._caption.text = tr("UI_JUMP_CAP_FIRST")
	j._caption.modulate.a = 1.0
	await _wait(0.2)
	await shot.call("c17e_09_jump.png")
	j.queue_free()
