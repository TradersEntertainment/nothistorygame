class_name IstOrdugahKisi
extends RefCounted
## Ordugâhın insanları (ORDUGÂH-4, docs/ORDUGAH_1453.md §3): yakın katmanda (lod 0) oyunun GERÇEK asker modeli
## (Soldier/Person, Crowd'un pişirdiği birebir donmuş kopya: börk, sarık, kaftan, silah, iş aleti dâhil), orta katmanda
## (lod 1) hafif figür (gövde + yüz + başlık, üç MultiMesh), uzak katmanda (lod 2) yok (piksel altı).
## Kişi satırı: [yerel konum Vector3 (zeminde), yaw (rad), tip]. Tipler TIP tablosunda: kim, ne yapıyor.
## Renkler §3.2: çoğu ağartılmamış yün/keten (krem, bej, gri, kahve); çivit ve kök boya kırmızısı azınlık. Başlık:
## yeniçeri beyaz börk ("bork"), öbürleri kırmızı keçe ("azap") ya da sarık ("turban"). Modern fes YOK.

const KRM := Color("cdbf9a")
const BEJ := Color("b8a882")
const GRI := Color("8f8064")
const KHV := Color("6a563c")
const CIV := Color("3a4f78")       # çivit (yeniçeri dolaması)
const KOK := Color("8c3a2e")       # kök boya kırmızısı
const AK := Color("e8e0c8")

## tip → [kaftan, başlık, silah/alet, duruş]
const TIP := {
	"nobet": [CIV, "bork", "spear", ""],             # yeniçeri nöbetçi
	"okcu": [KRM, "bork", "bow", ""],                # yeniçeri okçu (perde ardında)
	"azap": [GRI, "azap", "spear", ""],              # azap, mızraklı
	"sipahi": [KOK, "turban", "sword_shield", ""],   # atından inmiş sipahi
	"otur": [KRM, "bork", "", "sit_ground"],          # ocak başında oturan yeniçeri
	"otur2": [BEJ, "azap", "", "sit_ground"],         # ocak başında oturan azap
	"asci": [AK, "turban", "tool:ladle", "stir"],     # kazan karıştıran aşçı
	"kazma": [KHV, "azap", "tool:shovel", "dig"],     # toprak kazan / siper işçisi
	"saka": [GRI, "turban", "tool:bucket", ""],       # su taşıyan saka
	"tokmak": [KHV, "turban", "tool:rammer", ""],     # top doldurma ekibi (tokmakçı)
	"manivela": [GRI, "azap", "tool:handspike", ""],  # topu yönelten (manivela)
	"balta": [BEJ, "azap", "tool:axe", "chop"],       # odun kesen
	"bileyen": [KHV, "turban", "tool:hammer", "hammer"],  # silah bileyen / demirci
	"uyuyan": [BEJ, "bork", "", "doze"],             # çadır önünde uyuklayan
	"namaz": [AK, "turban", "", "sit_ground"],        # namaz safında (oturuş)
	"seyis": [KHV, "turban", "", ""],                # at tımarı (atın yanında duran)
	"yuruyen": [KRM, "bork", "spear", ""],           # yürüyen bölük
	"katip": [AK, "turban", "", "write"],            # tercüman/kâtip (yere oturmuş yazar)
	"esir": [Color("6a6a62"), "none", "", "sit_ground", "C"],   # esir (sivil, başı açık)
	"tuccar": [Color("3a6a8a"), "turban", "", "", "C"],     # çerçi/tüccar (sivil)
	"alici": [BEJ, "azap", "", ""],                  # pazarda gezinen asker
	"sohbet": [BEJ, "turban", "", ""],               # ORDUGÂH-5: ocak başında ayakta konuşan (silahsız)
}

## Hafif figürde başlık rengi
const BASLIK := {"bork": Color("eee8d6"), "azap": Color("a8281f"), "turban": Color("e6dcc2"), "none": Color("3a2a1e")}

static var _fig := {}


## host'a kişileri kurar. lod 0: gerçek model (Crowd), lod 1: hafif figür. Döner: kurulan kişi sayısı.
## Kişi noktaları host meta "kisiler" (PackedVector3Array, yerel) olarak saklanır (sonda sayar).
static func kur(host: Node3D, kisiler: Array, lod: int) -> int:
	if kisiler.is_empty() or lod >= 2:
		return 0
	var pts := PackedVector3Array()
	if host.has_meta("kisiler"):
		pts = host.get_meta("kisiler")
	if lod == 0:
		var groups := {}
		for k: Array in kisiler:
			var t: String = k[2]
			if not groups.has(t):
				groups[t] = []
			(groups[t] as Array).append(Transform3D(Basis(Vector3.UP, float(k[1])), k[0]))
			pts.append(k[0])
		for t: String in groups:
			var sp: Array = TIP.get(t, TIP["azap"])
			var m: ArrayMesh = Crowd.civilian(sp[0], sp[1], sp[3]) if sp.size() > 4 else Crowd.ottoman(sp[0], sp[1], sp[2], sp[3])
			var mi := Scenery.scatter(host, m, groups[t], [], Crowd.material())
			mi.name = "kisi_" + t
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.set_meta("no_walk", true)
	else:
		var gx: Array = []
		var gc: Array = []
		var hc: Array = []
		var fx: Array = []
		for k: Array in kisiler:
			var t: String = k[2]
			var sp: Array = TIP.get(t, TIP["azap"])
			var oturan := String(sp[3]) in ["sit_ground", "doze", "write"]
			var sc := Vector3(1, 0.58, 1) if oturan else Vector3.ONE
			var xf := Transform3D(Basis(Vector3.UP, float(k[1])).scaled(sc), k[0])
			gx.append(xf)
			gc.append(sp[0])
			hc.append(BASLIK.get(sp[1], BASLIK["azap"]))
			fx.append(xf)
			pts.append(k[0])
		# iki çizim: gövde (kaftan rengi) + baş ve başlık (başlık rengi; yüz bu uzaklıkta 1–2 piksel)
		_mm(host, figur("govde"), gx, gc, "kisi_govde")
		_mm(host, figur("bas_baslik"), fx, hc, "kisi_baslik")
	host.set_meta("kisiler", pts)
	return kisiler.size()


static func _mm(host: Node3D, mesh: Mesh, xfs: Array, cols: Array, nm: String) -> void:
	var mi := IstOrdugahKit.mm(host, mesh, xfs, cols, nm, "", false)
	if mi:
		mi.material_override = _figmat()


static var _fmat: StandardMaterial3D

static func _figmat() -> StandardMaterial3D:
	if _fmat == null:
		_fmat = StandardMaterial3D.new()
		_fmat.vertex_color_use_as_albedo = true
		_fmat.vertex_color_is_srgb = true
		_fmat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		_fmat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		_fmat.roughness = 1.0
	return _fmat


## Hafif figür parçaları (birim boy ~1,72 m; taban y 0, yüz +z): "govde" beyaz (örnek rengi kaftan),
## "bas" yüz/el (sabit ten rengi), "baslik" beyaz (örnek rengi başlık)
static func figur(kind: String) -> ArrayMesh:
	if _fig.has(kind):
		return _fig[kind]
	var b := IstOrdugahKit.Bld.new()
	var B := IstOrdugahKit.Bld
	match kind:
		"govde":
			b.cyl(B.xf(Vector3(0, 0.55, 0)), 0.26, 1.1, Color(0.92, 0.92, 0.92), 6, 0.2)        # dolama (etek)
			b.cyl(B.xf(Vector3(0, 1.22, 0)), 0.2, 0.36, Color.WHITE, 6, 0.17)                    # göğüs
			b.cyl(B.xf(Vector3(0, 1.0, 0)), 0.215, 0.07, Color(0.55, 0.5, 0.42), 6)              # kuşak
			b.box(Vector3(-0.24, 1.1, 0.04), Vector3(0.09, 0.5, 0.1), Color(0.88, 0.88, 0.88), 0.0, Vector3(0, 0, 8))
			b.box(Vector3(0.24, 1.1, 0.04), Vector3(0.09, 0.5, 0.1), Color(0.88, 0.88, 0.88), 0.0, Vector3(0, 0, -8))
			b.box(Vector3(0, 0.04, 0.04), Vector3(0.34, 0.08, 0.24), Color(0.3, 0.24, 0.2))        # çizme
		"bas":
			b.sph(Vector3(0, 1.5, 0.01), 0.12, Color("c99a74"), 6, Vector3(0.95, 1.1, 1.0))
			b.box(Vector3(0, 1.43, 0.1), Vector3(0.13, 0.05, 0.04), Color("3a2a1e"))              # bıyık
		"bas_baslik":
			b.sph(Vector3(0, 1.5, 0.01), 0.12, Color("e8c2a0"), 5, Vector3(0.95, 1.1, 1.0))
			b.cyl(B.xf(Vector3(0, 1.64, -0.01)), 0.13, 0.2, Color.WHITE, 6, 0.1)
		"baslik":
			b.cyl(B.xf(Vector3(0, 1.64, -0.01)), 0.13, 0.2, Color.WHITE, 6, 0.1)
			b.box(Vector3(0, 1.6, -0.12), Vector3(0.12, 0.22, 0.03), Color(0.9, 0.9, 0.9), 0.0, Vector3(15, 0, 0))   # yatırtma
	var m := IstOrdugahKit.bld_mesh(b)
	_fig[kind] = m
	return m
