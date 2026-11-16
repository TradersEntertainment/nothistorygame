class_name HareketHis
extends Node
## Tolga'nın hareket hissi: koşuda görüş açısı ve hafif öne eğilme, dönüşte yatış, havada kolların açılması, inişte
## yüksekliğe göre kamera çökmesi + toz + ses (yüksek inişte kısa çömelme), serbest düşüşte kol savrulması, rüzgâr ve
## sarsıntı (uzun düşüşte Bölüm 2'nin çığlığı), merdiven tepesinde ve kenardan çıkışta kameranın sıçramadan yetişmesi.
## Menzil, hız, zıplama, sendeleme eşiği, hasar ve nefes değerlerine dokunmaz: yalnız eğri ve geri bildirim (bkz.
## docs/_kanit_fizik_hareket/dokum.md). Kamera efektleri ayarlardan kapatılır ("hareket_kamera"); kapalıyken
## görüş açısı, yatış, eğilme, çökme ve sarsıntı yok, ses ve el hareketi kalır.
## Denetim (HAREKETAUDIT, bölüm koşularında 0 satır beklenir): zıplama tepesi/menzil sınırı aşıldı, inişten sonra
## takılma, kamera duvarın içinde, görüş açısı ayardan sapıp geri dönmedi.

const FOV_KOSU := 5.0             # koşuda görüş açısına eklenen (derece, ayardakine göre)
const EGILME_KOSU := 1.1          # koşuda öne eğilme (derece)
const YATIS_DONUS := 1.6          # dönüşte en çok yatış (derece)
const YATIS_YAN := 0.8            # yana yürürken yatış (derece)
const YUKSEK_INIS := 2.5          # bu yükseklikten inişte kısa çömelme ve "Ay!"
const DUSUS_HISSI := 3.0          # bu yükseklikten serbest düşüşte kollar savrulur, rüzgâr ve sarsıntı
const CIGLIK_DUSUS := 6.0         # öngörülen düşüş bundan uzunsa Tolga bağırır (Bölüm 2'nin çığlığı)
const AYAR := "hareket_kamera"

var p: Player
var _yerde := false
var _hava_tepe := -INF
var _hava_t := 0.0
var _son_y := INF
var _son_xz := Vector2.INF
var _vy := 0.0                    # konumdan ölçülen dikey hız (ara sahne tween'leri de sayılır)
var _hava_k := 0.0                # 0..1 havada kolların açıklığı
var _kosu_k := 0.0
var _fov_ek := 0.0                # kameraya bu bileşenin eklediği görüş açısı (sahiplik denetimi için)
var _fov_yazilan := INF
var _egilme := 0.0                # camera.rotation.x'e eklenmiş öne eğilme (rad); kaldırıp yeniden eklenir
var _egilme_ek := 0.0             # kenardan çıkışta eklenen öne eğilme (rad, Traversal verir)
var _yatis := 0.0
var _son_yaw := INF
# İniş çökmesi: kritik sönümlü yay (kamera y ofseti)
var _cok := 0.0
var _cok_v := 0.0
var _cok_hedef := 0.0
var _cok_tut := 0.0
var _nefes_k := 0.0              # tırmanırken yorgunluk 0..1 (Traversal verir): göz hizası nefesle iner kalkar
var _nefes_faz := 0.0
var _kamera := true
var _ofs := Vector3.ZERO          # kameranın yerel konum ofseti (merdiven tepesi, kenardan çıkış: sıçramadan yetişir)
# Düşüş
var _dusus_t := 0.0
var _ruzgar: AudioStreamPlayer
var _ruzgar_hedef := -80.0
var _ciglik_t := -1.0
var _dis_dusus := 0.0             # dusus_hissi (bölümün kendi düşüşü) kalan süre
var _dis_ciglik := false
var _ay_cool := 0.0
var _adim_n := 0
# Denetim
var _audit_seen := {}
var _zipla_y0 := INF
var _zipla_tepe := -INF
var _zipla_coyote := 0.0
var _zipla_xz := Vector2.INF       # kalkış (coyote'ta kenar) noktası
var _zipla_hiz := 0.0
var _takilma_t := 0.0
var _inis_hiz := 0.0
var _inis_t := 99.0
var _duvar_n := 0
var _duvar_t := 0.0
var _fov_t := 0.0


func _init(player: Player) -> void:
	p = player
	name = "HareketHis"
	process_mode = Node.PROCESS_MODE_PAUSABLE


static func acik() -> bool:
	if not GameState.settings.has(AYAR):
		# Ayar yeni: GameState varsayılanlarında yok; kayıtlı ayar dosyasında varsa oradan (yoksa açık)
		var v := true
		if not GameState._saving_disabled():
			var cfg: ConfigFile = GameState._load_cfg(GameState.SETTINGS_PATH)
			if cfg != null:
				v = bool(cfg.get_value("settings", AYAR, true))
		GameState.settings[AYAR] = v
	return bool(GameState.settings[AYAR])


func _sessiz() -> bool:
	return GameState.autotest and not GameState.pace


# ---------------------------------------------------------------- zıplama kayıtları (denetim)

## Oyuncu zıpladı (yerden ya da kenardan çıktıktan hemen sonra: coyote). c: kenardan bu yana geçen süre.
func zipladi(c: float) -> void:
	_zipla_y0 = p.global_position.y + (_g() * c * c * 0.5 if c > 0.0 else 0.0)     # kenarın yüksekliği
	_zipla_tepe = p.global_position.y
	_zipla_coyote = c
	var hv := Vector2(p.velocity.x, p.velocity.z)
	_zipla_xz = Vector2(p.global_position.x, p.global_position.z) - hv * c
	_zipla_hiz = maxf(hv.length(), Player.RUN * maxf(p.speed_mult, 1.0))


func _g() -> float:
	return float(ProjectSettings.get_setting("physics/3d/default_gravity"))


# ---------------------------------------------------------------- her fizik adımı (Player._after_move)

## Kameranın y ofseti (çökme), yerel konum ofseti ve yatış (rad) döner; Player kamerayı yazarken ekler.
func adim(delta: float, horiz: float) -> void:
	var kamera := acik()
	_kamera = kamera
	var y := p.global_position.y
	var xz := Vector2(p.global_position.x, p.global_position.z)
	if _son_xz != Vector2.INF and xz.distance_to(_son_xz) > 1.5:
		_son_y = INF                     # ışınlanma: zıplama/düşüş kayıtları yeniden başlar
		_zipla_y0 = INF
		_zipla_xz = Vector2.INF
	_son_xz = xz
	if _son_y != INF and absf(y - _son_y) < 3.0:
		_vy = lerpf(_vy, (y - _son_y) / maxf(delta, 0.0001), clampf(delta * 30.0, 0.0, 1.0))
	else:
		_vy = 0.0          # ışınlanma: havadaki tepe de yeniden başlar
		_hava_tepe = y
		_zipla_y0 = INF
		_zipla_xz = Vector2.INF
	_son_y = y
	_ay_cool = maxf(0.0, _ay_cool - delta)
	var serbest := not p.frozen and not p.pinned and p.ladder == null and not p.floating and p.gravity_on \
			and (p.traversal == null or p.traversal.state == "") and not (p.powers and p.powers.flying)
	var yerde := p.is_on_floor()
	if yerde:
		if not _yerde:
			_indi(_hava_tepe - y, serbest)
		_hava_tepe = y
		_hava_t = 0.0
		_dusus_t = 0.0
	else:
		# Merdivende, duvarda, ara sahnede ya da yüzerken düşüş sayılmaz: tepe serbest kalınan andan ölçülür
		_hava_tepe = y if (_yerde or not serbest) else maxf(_hava_tepe, y)
		_hava_t += delta
	_yerde = yerde
	if _zipla_y0 != INF:
		_zipla_tepe = maxf(_zipla_tepe, y)
		if _zipla_xz != Vector2.INF and not yerde and y < _zipla_y0 - 0.02 and _vy < 0.0:
			# Kalkış hizasına geri inildi: yatay yol, o hızla kenardan zıplamanın en uzun yolunu aşmasın
			var d := Vector2(p.global_position.x, p.global_position.z).distance_to(_zipla_xz)
			var en := _zipla_hiz * 2.0 * Player.JUMP / _g() + 0.2
			if d > en:
				_audit("menzil", "yol=%.2f sinir=%.2f coyote=%.2f" % [d, en, _zipla_coyote])
			_zipla_xz = Vector2.INF
		if yerde or not serbest:
			_zipla_denetle()
	# Havada kollar (el donanımı): zıplayınca ve düşerken hafifçe açılır
	var hava_hedef := 1.0 if (not yerde and serbest and _hava_t > 0.12) else 0.0
	_hava_k = move_toward(_hava_k, hava_hedef, delta * (5.0 if hava_hedef > _hava_k else 8.0))
	# Serbest düşüş: 3 m'yi geçince kollar savrulur, rüzgâr ve sarsıntı; uzun düşüşte çığlık
	var dusen := serbest and not yerde and _vy < -4.5 and (_hava_tepe - y) > 1.0
	if dusen:
		_dusus_t += delta
		var once := _hava_tepe - y
		var kalan := _yere_kalan()
		if once + kalan >= DUSUS_HISSI and once > 1.2:
			p.flail(0.3)
			if kamera:
				p.shake(clampf((-_vy - 5.0) * 0.025, 0.04, 0.16))
			_ruzgar_hedef = linear_to_db(clampf((-_vy - 4.0) / 10.0, 0.05, 1.0)) - 10.0
			if _ciglik_t < 0.0 and once + kalan >= CIGLIK_DUSUS and kalan > 2.0:
				_bagir()
		else:
			_ruzgar_hedef = -80.0
	elif _dis_dusus <= 0.0:
		_ruzgar_hedef = -80.0
	if _ciglik_t >= 0.0:
		_ciglik_t += delta
	if _dis_dusus > 0.0:
		_dis_dusus -= delta
		p.flail(0.2)
		if kamera:
			p.shake(0.12)
		_ruzgar_hedef = -12.0
		if _dis_dusus <= 0.0:
			_dis_bitti()
	_ruzgar_sur(delta)
	# Koşu: görüş açısı, öne eğilme, adım sesine takım elbise hışırtısı
	var kosuyor := serbest and yerde and horiz > Player.WALK * p.speed_mult + 0.4 and p.move_mode == "walk"
	_kosu_k = move_toward(_kosu_k, 1.0 if kosuyor else 0.0, delta * (3.5 if kosuyor else 4.5))
	_fov(delta, kamera)
	_egil(delta, kamera, serbest)
	# Yatış: dönüş hızına ve yana yürümeye göre
	var yaw := p.rotation.y            # oyuncu sahne kökünde ya da dönmeyen bir düğümde; yalnız değişim hızı gerekir
	var dyaw := 0.0
	if _son_yaw != INF:
		dyaw = wrapf(yaw - _son_yaw, -PI, PI) / maxf(delta, 0.0001)
		if absf(dyaw) > 12.0:
			dyaw = 0.0           # bölümün çevirdiği bakış (face)
	_son_yaw = yaw
	var hedef_yatis := 0.0
	if kamera and serbest and yerde and horiz > 1.0:
		var yan := p.velocity.dot(p.transform.basis.x) / maxf(horiz, 0.001)
		hedef_yatis = clampf(-dyaw * 0.012 * clampf(horiz / Player.RUN, 0.0, 1.0), -1.0, 1.0) * deg_to_rad(YATIS_DONUS) \
			- yan * deg_to_rad(YATIS_YAN) * clampf(horiz / Player.WALK, 0.0, 1.0)
	_yatis = lerpf(_yatis, hedef_yatis, clampf(delta * 6.0, 0.0, 1.0))
	# İniş çökmesi: kritik sönümlü yay
	if _cok_tut > 0.0:
		_cok_tut -= delta
		if _cok_tut <= 0.0:
			_cok_hedef = 0.0
	var k := 260.0
	var c := 2.0 * sqrt(k)
	_cok_v += (k * (_cok_hedef - _cok) - c * _cok_v) * delta
	_cok += _cok_v * delta
	if not kamera:
		_cok = 0.0
		_cok_v = 0.0
	_nefes_faz = fmod(_nefes_faz + delta * (1.4 + 2.2 * _nefes_k) * TAU, TAU)
	_ofs = _ofs.lerp(Vector3.ZERO, clampf(delta * 7.0, 0.0, 1.0))
	if _ofs.length() < 0.002:
		_ofs = Vector3.ZERO
	_takilma(delta, horiz, serbest)
	_inis_t += delta
	_duvar_denetle(delta)


func kamera_y() -> float:
	if _nefes_k > 0.0 and _kamera:
		return _cok + sin(_nefes_faz) * 0.012 * _nefes_k
	return _cok


## Tırmanırken yorgunluk (0..1): göz hizası nefesle iner kalkar, nefes azaldıkça hızlanır.
func nefes(k: float) -> void:
	_nefes_k = k


func kamera_ofs() -> Vector3:
	return _ofs


func yatis() -> float:
	return _yatis


func hava() -> float:
	return _hava_k


## Adım sesi çaldı: koşarken her ikinci adımda takım elbise hışırtısı (Tolga).
func adim_sesi() -> void:
	_adim_n += 1
	if _kosu_k > 0.6 and p.hand_style == "tolga" and _adim_n % 2 == 0 and not _sessiz():
		Audio.sfx("cloth", -27.0 + randf_range(-1.5, 0.5), randf_range(1.05, 1.25))


# ---------------------------------------------------------------- iniş

func _indi(fall: float, serbest: bool) -> void:
	var hiz := -_vy
	_inis_t = 0.0
	_inis_hiz = p.horizontal_speed()
	if _ciglik_t >= 0.0:
		_ciglik_kes()
	if not serbest or fall < 0.25:
		return
	var sendeler := p._stagger > 0.3          # Traversal: yüksekten düşüş (STAGGER_FALL) göz hizasını kendisi indirir
	var dip := clampf((fall - 0.2) * 0.05, 0.015, 0.11)
	var tut := 0.05
	if fall >= YUKSEK_INIS:
		dip = 0.2                              # kısa çömelme
		tut = 0.16
	if sendeler:
		dip = 0.05
		tut = 0.03
	_cok_hedef = -dip
	_cok_tut = tut
	_cok_v = -hiz * 0.35
	if fall >= 1.0:
		_toz(clampf(fall / 3.0, 0.5, 1.3))
	if _sessiz():
		return
	# Ses: Traversal açıksa iniş sesini o çalar (1,2 m üstü); kapalıysa burada (aynı eşik ve ses)
	var trav := p.can_climb and p.traversal != null
	if not trav and fall > 1.2:
		Audio.sfx("land_thud", -16.0 if fall < YUKSEK_INIS else -10.0, 1.1 if fall < YUKSEK_INIS else 0.92)
	if fall >= YUKSEK_INIS:
		Audio.sfx("cloth", -18.0, 0.9)
		if not sendeler and _ay_cool <= 0.0 and p.hand_style == "tolga":
			_ay_cool = 25.0
			var hud := p.get_tree().get_first_node_in_group("hud") as Hud
			if hud and not hud.is_talking():
				hud.bark("SPK_TOLGA", "D4B_T_HIT_1", 1.2)        # var olan "Ay!"


func _toz(size: float) -> void:
	var sc := p.get_tree().current_scene
	if sc == null:
		return
	var at := p.global_position
	for i in p.get_slide_collision_count():
		var col := p.get_slide_collision(i)
		if col.get_normal().y > 0.6:
			at.y = col.get_position().y
			break
	# Ayağın dibinde, bakış yönüne 0,35 m kaymış (birinci şahısta ayağın tam altı kadraja girmiyor); zemine oturur
	var ileri := -p.camera.global_transform.basis.z
	ileri.y = 0.0
	if ileri.length_squared() > 0.001:
		var on := at + ileri.normalized() * 0.35
		var q := PhysicsRayQueryParameters3D.create(on + Vector3.UP * 0.4, on + Vector3.DOWN * 0.3, p.collision_mask, [p.get_rid()])
		var hit := p.get_world_3d().direct_space_state.intersect_ray(q)
		if not hit.is_empty() and (hit["normal"] as Vector3).y > 0.6:
			at = hit["position"]          # önde zemin varsa oraya (kenarın ötesinde havada toz olmaz)
	Vfx.dust_puff(sc, at + Vector3(0, 0.08, 0), size, Color(0.72, 0.65, 0.55, 0.42))


# ---------------------------------------------------------------- düşüş

## Bölümün kendi düşüşü (Bölüm 2 kızaktan uçuş, 44b kuyu): kollar savrulur, kamera hafifçe sarsılır, rüzgâr yükselir;
## bagir: Tolga'nın Bölüm 2 çığlığı (D2_T_FALL_SCREAM), süre sonunda kesilir. Akışı beklemez.
func dusus(sure: float, bagir: bool) -> void:
	_dis_dusus = sure
	_dis_ciglik = bagir
	p.flail(sure + 0.2)
	if bagir:
		_bagir()


func _dis_bitti() -> void:
	_ruzgar_hedef = -80.0
	if _dis_ciglik:
		_dis_ciglik = false
		_ciglik_kes()


func _bagir() -> void:
	_ciglik_t = 0.0
	if _sessiz() or p.hand_style != "tolga":
		return
	var hud := p.get_tree().get_first_node_in_group("hud") as Hud
	if hud:
		hud.bark("SPK_TOLGA", "D2_T_FALL_SCREAM", 3.0, true)


func _ciglik_kes() -> void:
	var t := _ciglik_t
	_ciglik_t = -1.0
	if _sessiz() or p.hand_style != "tolga" or t > 3.0:
		return
	var hud := p.get_tree().get_first_node_in_group("hud") as Hud
	if hud and hud.is_talking():
		hud.cut_voice()


## Ayağın altındaki zemine kalan (en çok 40 m).
func _yere_kalan() -> float:
	var from := p.global_position + Vector3.UP * 0.1
	var q := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 40.0, p.collision_mask, [p.get_rid()])
	var hit := p.get_world_3d().direct_space_state.intersect_ray(q)
	return 40.0 if hit.is_empty() else from.y - (hit["position"] as Vector3).y


func _ruzgar_sur(delta: float) -> void:
	if _sessiz():
		return
	if _ruzgar == null:
		if _ruzgar_hedef <= -79.0:
			return
		var s := load("res://assets/audio/sfx/whoosh_fly.ogg") as AudioStream
		if s == null:
			return
		s = s.duplicate()
		if s is AudioStreamOggVorbis:
			(s as AudioStreamOggVorbis).loop = true
		_ruzgar = AudioStreamPlayer.new()
		_ruzgar.stream = s
		_ruzgar.bus = "SFX"
		_ruzgar.volume_db = -60.0
		_ruzgar.pitch_scale = 0.7
		add_child(_ruzgar)
	var hedef := _ruzgar_hedef
	_ruzgar.volume_db = move_toward(_ruzgar.volume_db, hedef, delta * (60.0 if hedef > _ruzgar.volume_db else 90.0))
	_ruzgar.pitch_scale = lerpf(_ruzgar.pitch_scale, clampf(0.6 + (-_vy) * 0.03, 0.6, 1.1), clampf(delta * 3.0, 0.0, 1.0))
	if _ruzgar.volume_db > -55.0:
		if not _ruzgar.playing:
			_ruzgar.play()
	elif _ruzgar.playing:
		_ruzgar.stop()


# ---------------------------------------------------------------- görüş açısı ve eğilme

func _fov(delta: float, kamera: bool) -> void:
	var cam := p.camera
	var taban := float(GameState.settings.get("fov", 72.0))
	# Kamerayı başka biri (yakınlaştırma, çekim, bölüm tween'i) oynatıyorsa dokunulmaz, katkı sıfırlanır
	if _fov_yazilan != INF and absf(cam.fov - _fov_yazilan) > 0.01:
		_fov_ek = 0.0
		_fov_yazilan = INF
		return
	var sahip := absf(cam.fov - (taban + _fov_ek)) < 0.02
	var hedef := FOV_KOSU * _kosu_k if kamera else 0.0
	if not sahip:
		_fov_ek = 0.0
		_fov_yazilan = INF
		return
	_fov_ek = move_toward(_fov_ek, hedef, delta * FOV_KOSU * 3.0)
	if cam.fov != taban + _fov_ek:
		cam.fov = taban + _fov_ek          # yalnız değişince (her karede yazmak kamerayı her karede günceller)
	_fov_yazilan = cam.fov
	# Denetim: koşu bitti, katkı 1,5 sn'de sıfıra dönmedi
	if _kosu_k <= 0.0 and _fov_ek > 0.05:
		_fov_t += delta
		if _fov_t > 1.5:
			_audit("fov", "ek=%.2f taban=%.1f fov=%.2f" % [_fov_ek, taban, cam.fov])
	else:
		_fov_t = 0.0


## Kenardan çıkışta Traversal'ın verdiği öne eğilme (derece) ve kamera yükselişi (m, yerel ofset).
func kenar_egilme(der: float, yuksel: float) -> void:
	_egilme_ek = deg_to_rad(der)
	_ofs.y = maxf(_ofs.y, yuksel)


## Kamera bir anda yer değiştirdi (merdiven tepesi, kenar): eski göz noktasından yumuşakça yetişir.
func kamera_yetis(eski_goz: Vector3) -> void:
	var yeni := p.camera.global_position
	var d := p.global_transform.basis.inverse() * (eski_goz - yeni)
	if d.length() < 1.6:
		_ofs = d


## Tutunma darbesi: kamera bir an aşağı çöker (el duvarı yakaladı).
func darbe(m: float) -> void:
	if not acik():
		return
	_cok_v -= m * 12.0


func _egil(delta: float, kamera: bool, serbest: bool) -> void:
	var cam := p.camera
	var hedef := 0.0
	if kamera and not p.look_lock:
		if serbest:
			hedef = -deg_to_rad(EGILME_KOSU) * _kosu_k
		hedef -= _egilme_ek
	var yeni := lerpf(_egilme, hedef, clampf(delta * 9.0, 0.0, 1.0))
	if absf(yeni - hedef) < 0.0005:
		yeni = hedef
	if yeni != _egilme:
		cam.rotation.x = clampf(cam.rotation.x - _egilme + yeni, deg_to_rad(-89), deg_to_rad(89))
		_egilme = yeni


# ---------------------------------------------------------------- denetim

func _audit(tur: String, ayrinti: String) -> void:
	if _audit_seen.has(tur):
		return
	_audit_seen[tur] = true
	var sc := p.get_tree().current_scene
	print("HAREKETAUDIT %s sahne=%s p=%s %s" % [tur, sc.scene_file_path.get_file() if sc else "?", p.global_position.snapped(Vector3.ONE * 0.1), ayrinti])


func _zipla_denetle() -> void:
	var tepe := _zipla_tepe - _zipla_y0
	var en := Player.JUMP * Player.JUMP / (2.0 * _g())
	if tepe > en + 0.06:
		_audit("zipla_tepe", "tepe=%.2f sinir=%.2f coyote=%.2f" % [tepe, en, _zipla_coyote])
	_zipla_y0 = INF
	_zipla_xz = Vector2.INF


func _takilma(delta: float, horiz: float, serbest: bool) -> void:
	# İnişten sonra 0,6 sn içinde, hızla inen oyuncu ileri basılı olduğu hâlde duruyor ve önünde duvar yok
	if _inis_t > 0.6 or _inis_hiz < 2.0 or not serbest or p.move_mode != "walk":
		_takilma_t = 0.0
		return
	var ileri := Input.get_vector("move_left", "move_right", "move_forward", "move_back").length() > 0.5
	var duvar := false
	for i in p.get_slide_collision_count():
		if p.get_slide_collision(i).get_normal().y < 0.7:
			duvar = true
	if ileri and horiz < 0.3 and not duvar and p.is_on_floor():
		_takilma_t += delta
		if _takilma_t > 0.35:
			_audit("inis_takilma", "inis_hiz=%.1f hiz=%.2f" % [_inis_hiz, horiz])
	else:
		_takilma_t = 0.0


func _duvar_denetle(delta: float) -> void:
	_duvar_t -= delta
	if _duvar_t > 0.0 or not p.camera.current or p.frozen:
		return
	_duvar_t = 0.2
	# Gövdenin ekseninden (göz hizasının biraz altı) kameraya: arada katı yüzey varsa kamera duvarın içinde/ardında
	var cam := p.camera.global_position
	var from := p.global_position + Vector3.UP * clampf(p.eye_height * 0.8, 0.4, 1.4)
	if from.distance_to(cam) < 0.05:
		_duvar_n = 0
		return
	var q := PhysicsRayQueryParameters3D.create(from, cam, 1, [p.get_rid()])
	q.hit_back_faces = false
	var hit := p.get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		_duvar_n = 0
		return
	_duvar_n += 1
	if _duvar_n >= 3:
		var col: Object = hit["collider"]
		_audit("kamera_duvar", "carpan=%s ofs=%s cok=%.2f" % [(col as Node).name if col is Node else "?", _ofs.snapped(Vector3.ONE * 0.01), _cok])
