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
	"otur": [KRM, "bork", "", "bagdas"],              # ocak başında bağdaş kurmuş yeniçeri (DURUŞ: eklemli)
	"otur2": [BEJ, "azap", "", "bagdas_ye"],          # ocak başında bağdaş kurmuş, kâseden yiyen azap
	"asci": [AK, "turban", "tool:ladle", "kazan_kar"],  # kazana belden eğilip karıştıran aşçı
	"kazma": [KHV, "azap", "tool:shovel", "kazma"],   # toprak kazan / siper işçisi (dizler bükük)
	"saka": [GRI, "turban", "tool:bucket", ""],       # su taşıyan saka
	"tokmak": [KHV, "turban", "tool:rammer", ""],     # top doldurma ekibi (tokmakçı)
	"manivela": [GRI, "azap", "tool:handspike", ""],  # topu yönelten (manivela)
	"balta": [BEJ, "azap", "tool:axe", "balta"],      # odun yaran (baltayı iki elle kaldırır)
	"bileyen": [KHV, "turban", "", "bagdas_bile"],    # bağdaş kurmuş, kucağındaki kılıcı taşla bileyen
	"uyuyan": [BEJ, "bork", "", "sirt_uzan"],        # ateş başında sırtüstü uyuyan (baş altında bohça)
	"namaz": [AK, "turban", "", "diz_ustu"],          # namaz safında (teşehhüd oturuşu: diz üstü)
	"seyis": [KHV, "turban", "", ""],                # at tımarı (atın yanında duran)
	"yuruyen": [KRM, "bork", "spear", ""],           # yürüyen bölük
	"katip": [AK, "turban", "", "bagdas_yaz"],       # tercüman/kâtip (bağdaş kurmuş, kucağında yazar)
	"esir": [Color("6a6a62"), "none", "", "diz_ustu", "C"],     # esir (sivil, başı açık; diz üstü çökmüş)
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
		# Hafif figür: duruşun sadeleştirilmiş silueti (ayakta / bağdaş / diz üstü / yatan / belden eğik). Bütün kişiler
		# tek ağda (renk köşe renginde): eskiden iki MultiMesh (gövde + baş) idi, oturan "y'si basık" dik çubuktu.
		# (Packed diziler değer türüdür: dizi içinde tutulup "as" ile eklenirse kopyaya eklenir, ağ boş kalırdı)
		var pv := PackedVector3Array()
		var pn := PackedVector3Array()
		var pc := PackedColorArray()
		for k: Array in kisiler:
			var t: String = k[2]
			var sp: Array = TIP.get(t, TIP["azap"])
			var fk := fig_tur(String(sp[3]))
			var xf := Transform3D(Basis(Vector3.UP, float(k[1])), k[0])
			for e: Array in [_ekle(figur("govde" + fk), xf, sp[0]), _ekle(figur("bas_baslik" + fk), xf, BASLIK.get(sp[1], BASLIK["azap"]))]:
				pv.append_array(e[0])
				pn.append_array(e[1])
				pc.append_array(e[2])
			pts.append(k[0])
		var arr := []
		arr.resize(Mesh.ARRAY_MAX)
		arr[Mesh.ARRAY_VERTEX] = pv
		arr[Mesh.ARRAY_NORMAL] = pn
		arr[Mesh.ARRAY_COLOR] = pc
		var am := ArrayMesh.new()
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
		var mi := MeshInstance3D.new()
		mi.mesh = am
		mi.name = "kisi_figur"
		mi.material_override = _figmat()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("no_walk", true)
		host.add_child(mi)
	host.set_meta("kisiler", pts)
	return kisiler.size()


## Duruşun hafif figür türü: "" ayakta, "_otur" (bağdaş/çömelme/kütük), "_diz" (diz üstü), "_yat" (uzanan),
## "_egil" (belden eğik iş)
static func fig_tur(pose: String) -> String:
	if pose in ["sirt_uzan", "yan_uzan", "doze"]:
		return "_yat"
	if pose in ["diz_ustu", "ates_ufle", "tek_diz"]:
		return "_diz"
	if pose.begins_with("bagdas") or pose in ["comel", "otur_kutuk", "otur_sandik", "otur_eyer", "sirt_dayali", "sit_ground", "write"]:
		return "_otur"
	if pose in ["kazan_kar", "kazma", "balta", "odun_at", "yuk_kaldir"]:
		return "_egil"
	return ""


static func _ekle(m: ArrayMesh, xf: Transform3D, col: Color) -> Array:
	var a := m.surface_get_arrays(0)
	var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
	var n: PackedVector3Array = a[Mesh.ARRAY_NORMAL]
	var c: PackedColorArray = a[Mesh.ARRAY_COLOR]
	var c2 := PackedColorArray()
	c2.resize(c.size())
	for i in c.size():
		c2[i] = c[i] * col
	return [xf * v, Transform3D(xf.basis, Vector3.ZERO) * n, c2]


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
		"govde_otur":
			# bağdaş: yere yayılmış dizler + kucak (etek), kısa gövde
			b.sph(Vector3(0, 0.1, 0.08), 0.33, Color(0.92, 0.92, 0.92), 6, Vector3(1.15, 0.38, 0.95))
			b.cyl(B.xf(Vector3(0, 0.48, -0.02)), 0.2, 0.52, Color.WHITE, 6, 0.17)
			b.cyl(B.xf(Vector3(0, 0.3, -0.02)), 0.215, 0.07, Color(0.55, 0.5, 0.42), 6)
			b.box(Vector3(-0.22, 0.42, 0.12), Vector3(0.09, 0.42, 0.1), Color(0.88, 0.88, 0.88), 0.0, Vector3(-35, 0, 8))
			b.box(Vector3(0.22, 0.42, 0.12), Vector3(0.09, 0.42, 0.1), Color(0.88, 0.88, 0.88), 0.0, Vector3(-35, 0, -8))
		"bas_baslik_otur":
			b.sph(Vector3(0, 0.88, 0.0), 0.12, Color("e8c2a0"), 5, Vector3(0.95, 1.1, 1.0))
			b.cyl(B.xf(Vector3(0, 1.02, -0.02)), 0.13, 0.2, Color.WHITE, 6, 0.1)
		"govde_diz":
			# diz üstü: yere katlanmış bacaklar (önde), dik gövde
			b.box(Vector3(0, 0.1, 0.14), Vector3(0.4, 0.2, 0.62), Color(0.92, 0.92, 0.92))
			b.cyl(B.xf(Vector3(0, 0.58, -0.04)), 0.21, 0.6, Color.WHITE, 6, 0.17)
			b.cyl(B.xf(Vector3(0, 0.38, -0.04)), 0.22, 0.07, Color(0.55, 0.5, 0.42), 6)
			b.box(Vector3(-0.22, 0.48, 0.08), Vector3(0.09, 0.42, 0.1), Color(0.88, 0.88, 0.88), 0.0, Vector3(-25, 0, 6))
			b.box(Vector3(0.22, 0.48, 0.08), Vector3(0.09, 0.42, 0.1), Color(0.88, 0.88, 0.88), 0.0, Vector3(-25, 0, -6))
		"bas_baslik_diz":
			b.sph(Vector3(0, 1.0, 0.0), 0.12, Color("e8c2a0"), 5, Vector3(0.95, 1.1, 1.0))
			b.cyl(B.xf(Vector3(0, 1.14, -0.02)), 0.13, 0.2, Color.WHITE, 6, 0.1)
		"govde_yat":
			# sırtüstü: yerde uzanan gövde (baş -z'de), bacaklar ileride, baş altında bohça
			b.cyl(B.xf(Vector3(0, 0.22, -0.3), 0.0, Vector3(90, 0, 0)), 0.23, 0.75, Color.WHITE, 6, 0.21)
			b.cyl(B.xf(Vector3(0, 0.16, 0.35), 0.0, Vector3(90, 0, 0)), 0.2, 0.62, Color(0.92, 0.92, 0.92), 6, 0.15)
			b.box(Vector3(0, 0.1, 0.7), Vector3(0.3, 0.18, 0.1), Color(0.3, 0.24, 0.2))
			b.box(Vector3(0, 0.07, -0.9), Vector3(0.42, 0.14, 0.3), Color(0.82, 0.76, 0.62))
		"bas_baslik_yat":
			b.sph(Vector3(0, 0.27, -0.85), 0.12, Color("e8c2a0"), 5, Vector3(0.95, 1.0, 1.1))
			b.cyl(B.xf(Vector3(0, 0.3, -1.0), 0.0, Vector3(-70, 0, 0)), 0.13, 0.2, Color.WHITE, 6, 0.1)
		"govde_egil":
			# belden eğik iş: bacaklar dik, gövde öne ~30°
			b.cyl(B.xf(Vector3(0, 0.33, -0.08)), 0.22, 0.66, Color(0.92, 0.92, 0.92), 6, 0.2)
			b.cyl(B.xf(Vector3(0, 0.85, 0.06), 0.0, Vector3(28, 0, 0)), 0.2, 0.5, Color.WHITE, 6, 0.17)
			b.box(Vector3(-0.2, 0.78, 0.28), Vector3(0.09, 0.48, 0.1), Color(0.88, 0.88, 0.88), 0.0, Vector3(-55, 0, 6))
			b.box(Vector3(0.2, 0.78, 0.28), Vector3(0.09, 0.48, 0.1), Color(0.88, 0.88, 0.88), 0.0, Vector3(-55, 0, -6))
			b.box(Vector3(0, 0.04, -0.04), Vector3(0.34, 0.08, 0.3), Color(0.3, 0.24, 0.2))
		"bas_baslik_egil":
			b.sph(Vector3(0, 1.25, 0.3), 0.12, Color("e8c2a0"), 5, Vector3(0.95, 1.1, 1.0))
			b.cyl(B.xf(Vector3(0, 1.36, 0.24), 0.0, Vector3(-20, 0, 0)), 0.13, 0.2, Color.WHITE, 6, 0.1)
		"baslik":
			b.cyl(B.xf(Vector3(0, 1.64, -0.01)), 0.13, 0.2, Color.WHITE, 6, 0.1)
			b.box(Vector3(0, 1.6, -0.12), Vector3(0.12, 0.22, 0.03), Color(0.9, 0.9, 0.9), 0.0, Vector3(15, 0, 0))   # yatırtma
	var m := IstOrdugahKit.bld_mesh(b)
	_fig[kind] = m
	return m
