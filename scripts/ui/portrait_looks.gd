class_name PortraitLooks
## Konuşma kartının stüdyo portresi (PortraitStudio) için her konuşmacının görünüşü: oyunda onu kuran sahnedeki
## Person tanımıyla aynı (yüz, kıyafet, başlık, sakal). Konuşan sahnede değilse (telsiz, uzak ses, oyuncunun kendisi)
## kart bu görünüşle kurulan canlı bir kafayı gösterir: ağzı sesle oynar, göz kırpar. Eski düz çizimlerin yerine.
## Değişen görünüşler (Tolga'nın fesi, kaftanı, isi; Hüseyin'in fesi) look() içinde duruma göre seçilir.

## kind: "person" (Person.new(p)), "hikmet" (Hikmet sınıfı), "chicken" (Sinerji), "radio" (telsiz/hoparlör: kafa yok,
## konuşan cihaz)
const LOOKS := {
	# 2026 ve 1977
	"SPK_NIHAT": {"face": "nihat", "coat": Color("4a4a52"), "pants": Color("4a4a52"), "hat": "fedora", "mustache": true, "hair": Color("3a2a1e"), "skin": Color("ecb892")},
	"SPK_MUFIDE": {"coat": Color("6b3a4a"), "pants": Color("3a2a30"), "hair": Color("9a9a9a"), "hat": "bun", "glasses": true, "skirt": true, "skin": Color("e8b894"), "face": {"wrinkles": true, "nose": "long", "brow_tilt": 8.0}},
	"SPK_RIZA": {"coat": Color("7a6a4a"), "pants": Color("3a3228"), "hair": Color("2a2a2a"), "mustache": true, "glasses": true, "face": {"nose": "bulb", "bags": true, "brow": 1.2}},
	"SPK_CEMIL": {"coat": Color("5a6a7a"), "pants": Color("3a3a42"), "hair": Color("d8d8d0"), "mustache": true, "glasses": true, "skin": Color("e0a57e"), "face": {"wrinkles": true, "nose": "round"}},
	"SPK_AGENT1": {"coat": Color("2a2a30"), "pants": Color("2a2a30"), "hat": "fedora", "glasses": true, "skin": Color("e0b08a"), "face": {"nose": "long", "brow": 1.3, "brow_tilt": 10.0}},
	"SPK_AGENT2": {"coat": Color("2a2a30"), "pants": Color("2a2a30"), "hat": "fedora", "mustache": true, "skin": Color("d8a070"), "face": {"nose": "round", "brow": 1.1}},
	"SPK_MANAGER": {"coat": Color("3a3a42"), "pants": Color("2a2a30"), "glasses": true, "hair": Color("6a6a6a"), "mustache": true, "skin": Color("e0b08a")},
	"SPK_COWORKER_A": {"coat": Color("4a6a5a"), "pants": Color("2a2a30"), "hair": Color("3a2a1e"), "skirt": true, "hat": "bun", "skin": Color("e8b894")},
	"SPK_COWORKER_B": {"coat": Color("5a5a7a"), "pants": Color("2a2a30"), "hair": Color("2a1e14"), "glasses": true, "skin": Color("d8a880")},
	"SPK_DRIVER": {"coat": Color("6a6a5a"), "pants": Color("3a3a42"), "mustache": true, "hair": Color("2a2a2a"), "skin": Color("d8a070")},
	"SPK_NEWSAGENT": {"coat": Color("6a5a48"), "pants": Color("3a3a42"), "hat": "fedora", "mustache": true, "glasses": true, "skin": Color("d8a880")},
	"SPK_KAHVECI": {"coat": Color("f0ece4"), "pants": Color("3a3a42"), "mustache": true, "hair": Color("2a2a2a"), "skin": Color("d8a070"), "apron": Color("e8e0d0")},
	"SPK_AGENCY": {"coat": Color("4a4038"), "pants": Color("2a2a30"), "glasses": true, "hair": Color("1a1410"), "mustache": true, "skin": Color("e0b08a")},
	# Ordugâh (Perde I-II)
	"SPK_HASAN": {"coat": Color("b3262d"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("d9a07a")},
	"SPK_HUSEYIN": {"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("d9a07a")},
	"SPK_GUARDS": {"coat": Color("b3262d"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("d9a07a")},
	"SPK_KADRI": {"face": "kadri", "coat": Color("f3efe4"), "pants": Color("6a5a48"), "hat": "cook", "mustache": true, "hair": Color("2a1e14"), "apron": Color("e8e2d4"), "skin": Color("d9a07a")},
	"SPK_LUTFI": {"face": "lutfi", "coat": Color("3a6b3a"), "pants": Color("2a3a2a"), "hat": "turban", "mustache": true, "beard": true, "hair": Color("3a2a1e"), "robe": Color("3a6b3a")},
	"SPK_URBAN": {"face": "urban", "coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "hat": "kalpak", "mustache": true, "beard": true, "hair": Color("8a5a2a"), "apron": Color("4a3020")},
	"SPK_FATIH": {"face": "fatih", "coat": Color("b3262d"), "pants": Color("6a1a1a"), "hat": "sultan", "mustache": true, "robe": Color("c8323a"), "hair": Color("2a1e14"), "skin": Color("e0b08a")},
	"SPK_CANDARLI": {"face": "candarli", "coat": Color("3a4a3a"), "pants": Color("2a2a24"), "hat": "vizier", "beard": true, "mustache": true, "hair": Color("8a8a8a"), "robe": Color("3a4a3a"), "skin": Color("d9a07a")},
	"SPK_HALIL": {"face": "candarli", "coat": Color("3a4a3a"), "pants": Color("2a2a24"), "hat": "vizier", "beard": true, "mustache": true, "hair": Color("8a8a8a"), "robe": Color("3a4a3a"), "skin": Color("d9a07a")},
	"SPK_AGA": {"coat": Color("8a2b22"), "pants": Color("4a2a20"), "hat": "turban", "mustache": true, "robe": Color("8a2b22"), "beard": true, "skin": Color("c89070"), "face": {"nose": "hook", "brow": 1.5, "brow_tilt": 14.0}},
	"SPK_PASHA": {"coat": Color("3a4a6a"), "pants": Color("2a2a30"), "hat": "turban", "beard": true, "robe": Color("3a4a6a"), "hair": Color("5a5a5a")},
	"SPK_ZAGANOS": {"coat": Color("2f4a6a"), "pants": Color("2a2a30"), "hat": "turban", "beard": true, "mustache": true, "robe": Color("2f4a6a"), "skin": Color("d9a07a"), "face": {"nose": "hook", "brow": 1.3, "brow_tilt": 12.0}},
	"SPK_SARUCA": {"coat": Color("8a2b22"), "pants": Color("3a2a1e"), "robe": Color("8a2b22"), "hat": "vizier", "beard": true, "mustache": true, "skin": Color("d09a70")},
	"SPK_CAMELEER": {"coat": Color("a07a4a"), "pants": Color("5a4a36"), "hat": "turban", "mustache": true, "beard": true, "skin": Color("b8805c")},
	"SPK_DERVISH": {"coat": Color("6a5a48"), "pants": Color("4a4038"), "hat": "turban", "beard": true, "robe": Color("7a6a50"), "hair": Color("8a8a88"), "skin": Color("c89070")},
	"SPK_TAILOR": {"coat": Color("8a3a5a"), "pants": Color("3a2a2a"), "hat": "turban", "mustache": true, "skin": Color("d9a07a"), "face": {"nose": "long", "eye_s": 1.15}},
	"SPK_CALLIGRAPHER": {"coat": Color("e8e0d0"), "pants": Color("6a5a48"), "hat": "turban", "beard": true, "hair": Color("b8b4a8"), "robe": Color("4a5a6a"), "skin": Color("d8b090")},
	"SPK_HUNGARIAN": {"coat": Color("2f5a3a"), "pants": Color("3a2a1e"), "hat": "kalpak", "mustache": true, "hair": Color("8a5a2a")},
	"SPK_ENVOY": {"coat": Color("8a6a3a"), "pants": Color("4a3a2a"), "hat": "turban", "beard": true, "mustache": true, "hair": Color("5a5a5a"), "robe": Color("a8804a"), "skin": Color("d9a07a")},
	"SPK_RIDER": {"coat": Color("b3262d"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("c89070")},
	"SPK_AKSEMSEDDIN": {"coat": Color("e8e0d0"), "pants": Color("d8d0c0"), "robe": Color("6a7a5a"), "hat": "turban", "beard": true, "hair": Color("e0e0d8"), "skin": Color("d8b090")},
	# Kuşatma, Osmanlı tarafı
	"SPK_TOPCU": {"coat": Color("6a4a2c"), "pants": Color("3a2a1e"), "hat": "bork", "mustache": true, "beard": true, "apron": Color("3a2a1a"), "skin": Color("c89070")},
	"SPK_USTA": {"coat": Color("6a5a3a"), "pants": Color("3a3028"), "hat": "turban", "beard": true, "mustache": true, "hair": Color("5a5a5a"), "apron": Color("8a7050"), "skin": Color("d9a07a")},
	"SPK_MINER": {"coat": Color("6a5a48"), "pants": Color("3a3028"), "hat": "none", "beard": true, "mustache": true, "hair": Color("4a3a2a"), "apron": Color("4a3a2a"), "skin": Color("c89070")},
	"SPK_NOVOMINER": {"coat": Color("5a4632"), "pants": Color("4a3e30"), "hat": "hood", "beard": true, "mustache": true, "apron": Color("3a2a1c"), "hair": Color("2a1e14"), "skin": Color("c89070")},
	"SPK_KASIM": {"coat": Color("4a5a3a"), "pants": Color("3a3028"), "hat": "turban", "beard": true, "mustache": true, "hair": Color("2a1e14"), "skin": Color("c89070")},
	"SPK_ISMAIL": {"coat": Color("2f5a4a"), "pants": Color("2a3a30"), "hat": "turban", "beard": true, "mustache": true, "hair": Color("4a4a4a"), "robe": Color("2f5a4a"), "skin": Color("d9a07a"), "face": {"nose": "long"}},
	"SPK_FIRUZ": {"coat": Color("6a1a1a"), "pants": Color("e8e0d0"), "hat": "turban", "mustache": true, "beard": true, "skin": Color("c89070")},
	"SPK_MASON": {"coat": Color("8a7a60"), "pants": Color("e8e0d0"), "hat": "turban", "beard": true, "hair": Color("b8b4a8"), "skin": Color("c89070")},
	"SPK_DULGER": {"coat": Color("7a5a3a"), "pants": Color("e8e0d0"), "hat": "turban", "mustache": true, "beard": true, "skin": Color("c89070")},
	"SPK_BALTA": {"coat": Color("2f4a6a"), "pants": Color("e8e0d0"), "hat": "turban", "beard": true, "mustache": true, "robe": Color("2f4a6a"), "skin": Color("d8a882"), "face": {"brow": 1.2, "beard": "full"}},
	"SPK_CAVUS": {"coat": Color("6a1a1a"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "beard": true, "hair": Color("8a8a88"), "skin": Color("c89070")},
	"SPK_KARACA": {"coat": Color("2a4a8a"), "pants": Color("e8e0d0"), "hat": "kalpak", "beard": true, "mustache": true, "skin": Color("c89070")},
	"SPK_HERALD": {"coat": Color("2f5fa8"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("c89070")},
	"SPK_DROVER": {"coat": Color("5a4a36"), "pants": Color("4a3a2a"), "hat": "bork", "beard": true, "hair": Color("c8c4b8"), "skin": Color("c08868")},
	"SPK_AZAP": {"coat": Color("8a3a2e"), "pants": Color("e8e0d0"), "hat": "azap", "mustache": true, "skin": Color("c89070")},
	"SPK_AZAPBASI": {"coat": Color("b3262d"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "beard": true, "skin": Color("c89070")},
	"SPK_JANISSARY": {"coat": Color("b3262d"), "pants": Color("3a3028"), "hat": "bork", "mustache": true},
	"SPK_PATROL": {"coat": Color("3a5a78"), "pants": Color("e8e0d0"), "hat": "turban", "mustache": true, "beard": true, "skin": Color("c89070")},
	"SPK_ROWER": {"coat": Color("8a6a4a"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("c89070")},
	"SPK_WOMAN": {"coat": Color("6a3a5a"), "pants": Color("3a2a30"), "skirt": true, "hat": "scarf", "scarf": Color("c8a070"), "skin": Color("d9a07a")},
	# Şehir, Galata, Venedik ve Ceneviz
	"SPK_NIKO": {"face": "niko", "coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hair": Color("2a1e14"), "hat": "helm", "mustache": true, "beard": true, "skin": Color("d9a07a")},
	"SPK_GIUST": {"face": "giustiniani", "coat": Color("a8aeb6"), "pants": Color("6a2a2a"), "hat": "condottiero", "beard": true, "mustache": true, "hair": Color("5a3a1e"), "skin": Color("e8b894")},
	"SPK_EMPEROR": {"face": "emperor", "coat": Color("5a2a6a"), "pants": Color("3a1a4a"), "hat": "stemma", "beard": true, "mustache": true, "hair": Color("6a6a6a"), "robe": Color("5a2a6a")},
	"SPK_THEODOROS": {"coat": Color("5a3a6a"), "pants": Color("3a2a4a"), "hat": "kamelaukion", "robe": Color("5a3a6a"), "beard": true, "hair": Color("6a6a6a"), "skin": Color("e0b08a")},
	"SPK_NOTARAS": {"coat": Color("5a2a6a"), "robe": Color("6a3a7a"), "hat": "kamelaukion", "beard": true, "hair": Color("5a4a3a"), "skin": Color("e0b08a")},
	"SPK_ISIDORE": {"face": "cardinal", "coat": Color("b3262d"), "robe": Color("b3262d"), "hat": "galero", "beard": true, "hair": Color("e8e8e8"), "skin": Color("e8c0a0")},
	"SPK_BAILO": {"coat": Color("a8182a"), "pants": Color("3a2a2a"), "robe": Color("a8182a"), "hat": "berretta", "beard": true, "mustache": true, "hair": Color("6a4a2a")},
	"SPK_CLERK": {"coat": Color("4a3a5a"), "pants": Color("2a2a30"), "hat": "kamelaukion", "robe": Color("4a3a5a"), "beard": true, "hair": Color("5a4a3a"), "skin": Color("e0b08a")},
	"SPK_PAINTER": {"coat": Color("3a5a8a"), "pants": Color("2a2a30"), "hat": "kamelaukion", "beard": true, "hair": Color("3a2a1e")},
	"SPK_MONK": {"coat": Color("2a2226"), "pants": Color("2a2226"), "robe": Color("2a2226"), "beard": true, "hair": Color("3a3030"), "hat": "none"},
	"SPK_PRIEST": {"coat": Color("1a1a20"), "pants": Color("1a1a20"), "robe": Color("1a1a20"), "beard": true, "hair": Color("d0d0c8"), "hat": "kamelaukion", "skin": Color("d8b090")},
	"SPK_TOWNSMAN": {"coat": Color("4a4a58"), "pants": Color("2a2a30"), "beard": true, "hair": Color("c8c8c0"), "robe": Color("3a3a40"), "skin": Color("d8b090")},
	"SPK_DEFENDER": {"coat": Color("7a2a24"), "pants": Color("3a2a22"), "hat": "helm", "beard": true, "mustache": true, "skin": Color("e0b08a")},
	"SPK_LOOKOUT": {"coat": Color("6a2a2a"), "pants": Color("3a3028"), "hat": "helm", "beard": true, "mustache": true},
	"SPK_CITY_GUARD": {"coat": Color("7a2a24"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true, "beard": true},
	"SPK_GRANT": {"coat": Color("5a5a62"), "pants": Color("3a3a40"), "hat": "none", "beard": true, "hair": Color("8a5a2a"), "apron": Color("3a3028"), "skin": Color("e8b894")},
	"SPK_KID": {"coat": Color("c8603a"), "pants": Color("3a3a5a"), "hair": Color("5a3a1e"), "skin": Color("f0c8a0"), "child": true},
	"SPK_WITNESS": {"coat": Color("5a7a9a"), "pants": Color("3a3a5a"), "hair": Color("3a2a1e"), "skin": Color("f0c8a0"), "child": true},
	"SPK_TREVISANO": {"coat": Color("6a1e22"), "pants": Color("2a2226"), "hat": "berretta", "beard": true, "skin": Color("e0b08a"), "face": {"nose": "long", "brow": 1.2, "beard": "short", "head": Vector3(1.0, 1.05, 1.0)}},
	"SPK_COCO": {"coat": Color("2a3a6a"), "pants": Color("2a2226"), "hat": "berretta", "beard": true, "mustache": true, "face": {"nose": "hook", "brow": 1.4, "brow_tilt": 6.0, "beard": "short", "head": Vector3(1.04, 1.0, 1.0)}},
	"SPK_BRIG": {"coat": Color("2a3a6a"), "pants": Color("2a2226"), "hat": "berretta", "beard": true, "mustache": true, "skin": Color("dcae88"), "hair": Color("3a2a1e"), "face": {"nose": "long", "brow": 1.2, "beard": "short"}},
	"SPK_CATTANEO": {"coat": Color("2a3a6a"), "pants": Color("2a2226"), "hat": "berretta", "beard": true, "mustache": true, "skin": Color("dcae88"), "face": {"nose": "long", "brow": 1.1}},
	"SPK_GENOESE": {"coat": Color("2f4a6a"), "pants": Color("2a2226"), "hat": "berretta", "mustache": true, "beard": true, "skin": Color("e0b08a")},
	"SPK_RIZZO": {"coat": Color("6a1a2a"), "pants": Color("2a2226"), "hat": "berretta", "mustache": true, "beard": true},
	"SPK_PODESTA": {"coat": Color("6a1a2a"), "pants": Color("2a2a30"), "hat": "none", "beard": true, "hair": Color("8a8a8a"), "robe": Color("6a1a2a"), "skin": Color("e8c0a0")},
	"SPK_WINE": {"coat": Color("7a2a3a"), "pants": Color("3a2a2a"), "hat": "plume", "beard": true, "skin": Color("e8b894")},
	"SPK_NOTARY": {"coat": Color("2a2a3a"), "pants": Color("2a2a30"), "glasses": true, "hat": "none", "hair": Color("6a6a6a")},
	"SPK_DOUBLE": {"coat": Color("c98a3a"), "pants": Color("4a3a2a"), "hat": "turban", "mustache": true},
	"SPK_CAPTAIN": {"coat": Color("1a2a4a"), "pants": Color("2a2a30"), "hat": "plume", "beard": true, "mustache": true, "skin": Color("e0a57e")},
	"SPK_FISHMONGER": {"coat": Color("5a6a7a"), "pants": Color("3a3a3a"), "apron": Color("d8d0c0"), "mustache": true, "hat": "none"},
}

## Hem Bizans hem Osmanlı tarafında konuşan genel askerler/halk: sahneye göre giyinir
const SIDED := {
	"SPK_SOLDIER": [{"coat": Color("8a2b22"), "pants": Color("4a3a2a"), "hat": "helm", "mustache": true, "beard": true, "skin": Color("d9a07a")},
		{"coat": Color("b3262d"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("c89070")}],
	"SPK_SAILOR": [{"coat": Color("3a4a6a"), "pants": Color("2a2226"), "hat": "none", "beard": true, "hair": Color("3a2a1e"), "skin": Color("dcae88")},
		{"coat": Color("7a4a3a"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "skin": Color("d9a07a")}],
	"SPK_SAILOR2": [{"coat": Color("4a4a5a"), "pants": Color("2a2226"), "hat": "none", "beard": true, "mustache": true, "hair": Color("b0b0a8"), "skin": Color("dcae88")},
		{"coat": Color("6a5040"), "pants": Color("e8e0d0"), "hat": "bork", "mustache": true, "beard": true, "hair": Color("b0b0a8"), "skin": Color("c08868")}],
}

## Kafa yerine konuşan cihaz: telsiz (Büro), radyo (garaj), minibüsün hoparlörü
const DEVICES := {"SPK_RADIO": "radio", "SPK_BUREAU_RADIO": "radio", "SPK_VAN": "loudspeaker"}

## Osmanlı tarafındaki sahneler (adı "o" ile bitenlerden başka): otağ kapısı, ziyafet, top dökümü, huzur, köprü
const OTTOMAN_SCENES := ["chapter9", "chapter10", "chapter10b", "chapter10z", "chapter12", "chapter16", "chapter18"]


## Konuşmacının görünüşü: {"kind": ..., "p": Person tanımı, "sig": önbellek imzası}. Bilinmeyen konuşmacı: anahtarın
## tohumundan rastgele bir yüz, sahnenin tarafına göre giysi (yine de canlı kafa; eski çizime dönülmez).
static func look(speaker_key: String) -> Dictionary:
	if DEVICES.has(speaker_key):
		return {"kind": DEVICES[speaker_key], "p": {}, "sig": speaker_key}
	if speaker_key == "SPK_SINERJI":
		return {"kind": "chicken", "p": {}, "sig": speaker_key}
	if speaker_key == "SPK_HIKMET":
		return {"kind": "hikmet", "p": {}, "sig": speaker_key}
	if speaker_key == "SPK_TOLGA":
		return _tolga()
	var p: Dictionary
	if LOOKS.has(speaker_key):
		p = (LOOKS[speaker_key] as Dictionary).duplicate()
	elif SIDED.has(speaker_key):
		p = ((SIDED[speaker_key] as Array)[1 if ottoman_here() else 0] as Dictionary).duplicate()
	else:
		p = _generic(speaker_key)
	if speaker_key == "SPK_HUSEYIN":
		p["hat"] = Soldier.huseyin_hat()
	elif speaker_key == "SPK_NIHAT" and str(GameState.flags.get("nihat_fate", "")) == "N3":
		p["hat"] = "none"             # Yeni Model: fötr yok
	return {"kind": "person", "p": p, "sig": speaker_key + str(p.get("hat", ""))}


## Tolga: oyuncunun o anki hâli (fes, kaftan, is; Player._me_person ile aynı). Fes ve kaftan HUD'dan: 2026 sahnelerinde
## "fez" bayrağı açık olsa da başta fes yoktur, kaftan dolaptadır. Oynanan karakter Tolga değilse (Nihat'la oynanan
## bölümler) de aynı.
static func _tolga() -> Dictionary:
	var f := GameState.flags
	var tree := Engine.get_main_loop() as SceneTree
	var hud: Hud = tree.get_first_node_in_group("hud") as Hud if tree else null
	var fez: bool = hud.tolga_wears_fez() if hud else bool(f.get("fez", true))
	var kaftan: bool = hud.tolga_wears_kaftan() if hud else bool(f.get("has_kaftan", false))
	var p := {"face": "tolga", "coat": Color("7a3a2a") if kaftan else Color("23262d"), "pants": Color("23262d"),
		"skin": Color("e6ad88"), "hat": "fez" if fez else "none", "hair": Color("2a1e14")}
	if kaftan:
		p["robe"] = Color("8a3a2a")
	return {"kind": "person", "p": p, "sig": "SPK_TOLGA%s%s" % [p["hat"], "k" if kaftan else ""]}


## Sahne Osmanlı tarafında mı (genel asker ve denizcilerin giysisi): "...o" bölümleri, ordugâh bölümleri, 4a/6a/7a
## dalları; iki taraflı kuşatma bölümlerinde (23, 25, 27) tanığın tarafı.
static func ottoman_here() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	var sc := tree.current_scene if tree else null
	if sc == null:
		return false
	var nm := sc.scene_file_path.get_file().get_basename()
	if nm.ends_with("o") or nm in OTTOMAN_SCENES:
		return true
	var br = sc.get("branch")
	if br is String and (br as String).ends_with("a") and nm in ["chapter4", "chapter6", "chapter7"]:
		return true
	if nm in ["chapter23", "chapter25", "chapter27"]:
		return Siege.side() == "O"
	return false


## Tanımı olmayan konuşmacı: anahtarın tohumundan yüz ve giysi (sahnenin tarafına göre başlık)
static func _generic(speaker_key: String) -> Dictionary:
	var h := absi(hash(speaker_key))
	var coats := [Color("6a5040"), Color("4a5a6a"), Color("7a3a2e"), Color("5a6a4a"), Color("6a4a5a")]
	var p := {"face": CharKit.random_face(h), "coat": coats[h % coats.size()], "pants": Color("3a3028"),
		"mustache": h % 2 == 0, "beard": h % 3 == 0}
	p["hat"] = ["bork", "turban"][h % 2] if ottoman_here() else ["helm", "none", "hood"][h % 3]
	return p
