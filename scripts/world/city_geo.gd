class_name CityGeo
extends RefCounted
## Gerçek İstanbul (1453) → oyun dünyası (World1453) koordinat dönüşümü (docs/ISTANBUL_PLAN.md §1).
##
## Gerçek koordinat: Ayasofya'nın merkezi (0, 0); e doğuya, n kuzeye, metre (WGS84 enlem/boylamdan yerel düzleme:
## e = (boylam − 28,9802°) · 111 320 · cos 41,01°, n = (enlem − 41,0086°) · 111 320).
## Oyun dünyası: x kara surları boyunca (+x Marmara), −z şehrin içi (Ayasofya z −1480); bkz. World1453.
##
## Oyun haritası gerçeğin sıkıştırılmış ve hafifçe bükülmüş bir kopyasıdır (kara surları düz bir çizgi, Haliç kıyısı
## x −700'de düz). Dönüşüm iki parçalı:
##   1. en küçük kareler afin uyumu (ölçek ≈ 0,285, yani gerçeğin ≈ 1/3,5'i; ayna: dünya ekseni sol el),
##   2. dayanak noktalarında (bugünkü bölgeler ve anıtlar) kalan farkı sıfırlayan ince levha eğrisi (thin plate spline)
##      : dayanak noktası TAM yerine düşer, aradaki her şey yumuşakça ve katlanmadan bükülür.
## Böylece var olan bölgelerin (hub, Blakherna, Petrion, Ayasofya, Galata…) yerleri değişmez; araştırma dizinindeki
## (docs/ISTANBUL_YERLER.csv) her yer bu işlevle haritaya düşer.

const LAT0 := 41.0086
const LON0 := 28.9802
const M_PER_DEG := 111320.0
const COS_LAT := 0.754710          # cos(41,01°)

## Afin uyum (yalnız ölçek ve yön bilgisi, ters dönüşümün başlangıcı): dünya ≈ A · (e, n) + T. Ölçek √|det| ≈ 0,285.
const AX := Vector2(-0.1343186, -0.2101416)      # x ≈ AX · (e, n) + T.x
const AZ := Vector2(-0.3238939, 0.0972445)       # z ≈ AZ · (e, n) + T.y
const T := Vector2(-445.5678, -1553.3154)

## İnce levha eğrisi (thin plate spline, km cinsinden): dünya = TPS_A0 + TPS_AE · e + TPS_AN · n + Σ wᵢ · U(|r − rᵢ|),
## U(d) = d² ln d. Dayanaklar TAM yerine düşer; 100 m'lik ızgarada (5676 nokta) katlanma yok (Jacobian işareti hep
## aynı). Katsayılar dayanaklardan hesaplandı (docs/_kanit_istanbul/arac/geo_tps.py); dayanak değişirse yeniden üretilir.
const TPS_A0 := Vector2(-1008.0482795, -1490.6414513)
const TPS_AE := Vector2(-38.7639933, -329.1139373)
const TPS_AN := Vector2(-150.2894599, 59.9582432)
## Dayanaklar: [ad, gerçek (e, n) m, dünya (x, z), TPS ağırlığı]. Gerçek konumlar enlem/boylamdan (±50 m; araştırma
## dizini gelince güncellenir), dünya konumları World1453.LANDMARKS ve bölge kayıtlarından.
const ANCHORS := [
	["ayasofya", Vector2(0.00, 0.00), Vector2(-560.0, -1480.0), Vector2(0.6355646, 21.3682274)],
	["hippodrome", Vector2(-420.01, -289.43), Vector2(-470.0, -1440.0), Vector2(-62.8653099, -93.1659592)],
	["column", Vector2(-756.01, 0.00), Vector2(-470.0, -1300.0), Vector2(35.2491574, 56.7461793)],
	["forum_tauri", Vector2(-1360.82, 211.51), Vector2(-390.0, -1130.0), Vector2(9.4141317, -10.5104160)],
	["apostles", Vector2(-2562.05, 1191.12), Vector2(-330.0, -760.0), Vector2(32.9450650, -48.9518350)],
	["pantokrator", Vector2(-1974.04, 1246.78), Vector2(-540.0, -930.0), Vector2(-34.2931493, 44.8672912)],
	["pammakaristos", Vector2(-2830.85, 2337.72), Vector2(-575.0, -470.0), Vector2(109.1956865, 89.8375277)],
	["petrion_gate", Vector2(-2536.85, 2404.51), Vector2(-700.0, -650.0), Vector2(-86.8764917, -168.4347758)],
	["khora", Vector2(-3444.06, 2515.83), Vector2(-500.0, -85.0), Vector2(369.0835366, -8.4303823)],
	["blachernae_palace", Vector2(-3326.46, 2816.40), Vector2(-668.0, -72.0), Vector2(-258.7358929, 92.5080938)],
	["harisios", Vector2(-3771.67, 2337.72), Vector2(-460.0, 0.0), Vector2(-179.9154239, 24.1647287)],
	["romanos", Vector2(-4939.29, 1113.20), Vector2(0.0, 0.0), Vector2(16.9971077, -33.6052621)],
	["pege", Vector2(-5241.70, -434.15), Vector2(340.0, 0.0), Vector2(-50.4911884, -35.2225069)],
	["golden_gate", Vector2(-4838.49, -1636.40), Vector2(650.0, -10.0), Vector2(-9.5129397, 10.4827934)],
	["studios", Vector2(-4309.28, -923.96), Vector2(540.0, -158.0), Vector2(67.7573089, 42.7955467)],
	["eugenius", Vector2(630.01, 857.16), Vector2(-690.0, -1525.0), Vector2(2.3424608, 67.8569296)],
	["galata_tower", Vector2(-504.01, 1892.44), Vector2(-971.0, -1330.0), Vector2(-32.0765589, -24.5368960)],
	["damalis", Vector2(2007.64, 1391.50), Vector2(-560.0, -2072.0), Vector2(29.5664904, -21.8874412)],
	["eyup", Vector2(-3880.87, 4363.74), Vector2(-690.0, 250.0), Vector2(41.5804452, -5.8818433)],
]


## Enlem/boylam → gerçek (e, n) metre
static func ll_to_real(lat: float, lon: float) -> Vector2:
	return Vector2((lon - LON0) * M_PER_DEG * COS_LAT, (lat - LAT0) * M_PER_DEG)


## Gerçek (e, n) → dünya (x, z)
static func real_to_world(r: Vector2) -> Vector2:
	var k := r / 1000.0
	var out := TPS_A0 + TPS_AE * k.x + TPS_AN * k.y
	for a: Array in ANCHORS:
		var d := k.distance_to((a[1] as Vector2) / 1000.0)
		if d > 0.0:
			out += (a[3] as Vector2) * (d * d * log(d))
	return out


## Dünya (x, z) → gerçek (e, n): afinin tersinden başlayıp sayısal Jacobian'lı Newton adımları (yer dizini ve araç için).
## Bükme dayanakların arasında katlanabilir (iki gerçek nokta bir dünya noktasına): o zaman en yakın çözüm döner.
static func world_to_real(w: Vector2) -> Vector2:
	var det := AX.x * AZ.y - AX.y * AZ.x
	var q := w - T
	var r := Vector2((AZ.y * q.x - AX.y * q.y) / det, (-AZ.x * q.x + AX.x * q.y) / det)
	for k in 30:
		var f := real_to_world(r)
		var err := w - f
		if err.length() < 0.05:
			break
		var h := 5.0
		var jx := (real_to_world(r + Vector2(h, 0)) - f) / h
		var jy := (real_to_world(r + Vector2(0, h)) - f) / h
		var jd := jx.x * jy.y - jy.x * jx.y
		if absf(jd) < 1e-6:
			break
		var step := Vector2((jy.y * err.x - jy.x * err.y) / jd, (-jx.y * err.x + jx.x * err.y) / jd)
		r += step.limit_length(400.0)
	return r


## Enlem/boylam → dünya noktası (y: görünen yüzey)
static func ll_to_world(lat: float, lon: float) -> Vector3:
	var w := real_to_world(ll_to_real(lat, lon))
	return Vector3(w.x, World1453.surface_h(w.x, w.y), w.y)


## Yer dizini (CSV): başlıkta "enlem"/"lat" ve "boylam"/"lon" ya da "dogu_m"/"e" ve "kuzey_m"/"n" sütunları; ad sütunu
## "ad"/"name"/"kimlik". Döner: [{ad, real: Vector2, world: Vector3, row: Dictionary}]. Okunamayan satır atlanır.
static func load_places(path: String) -> Array:
	var out: Array = []
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return out
	var head := f.get_csv_line()
	var col := {}
	for i in head.size():
		col[head[i].strip_edges().to_lower()] = i
	var pick := func(names: Array) -> int:
		for nm: String in names:
			if col.has(nm):
				return col[nm]
		return -1
	var c_ad: int = pick.call(["ad", "name", "kimlik", "id"])
	var c_lat: int = pick.call(["enlem", "lat", "latitude"])
	var c_lon: int = pick.call(["boylam", "lon", "lng", "longitude"])
	var c_e: int = pick.call(["dogu_m", "doğu_m", "e", "east"])
	var c_n: int = pick.call(["kuzey_m", "n", "north"])
	while not f.eof_reached():
		var row := f.get_csv_line()
		if row.size() < head.size():
			continue
		var r := Vector2.INF
		if c_lat >= 0 and c_lon >= 0 and row[c_lat].is_valid_float() and row[c_lon].is_valid_float():
			r = ll_to_real(row[c_lat].to_float(), row[c_lon].to_float())
		elif c_e >= 0 and c_n >= 0 and row[c_e].is_valid_float() and row[c_n].is_valid_float():
			r = Vector2(row[c_e].to_float(), row[c_n].to_float())
		if r == Vector2.INF:
			continue
		var w := real_to_world(r)
		var d := {}
		for i in head.size():
			d[head[i]] = row[i]
		out.append({"ad": row[c_ad] if c_ad >= 0 else "", "real": r,
			"world": Vector3(w.x, World1453.surface_h(w.x, w.y), w.y), "row": d})
	return out
