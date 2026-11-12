extends Node3D
## Yerebatan Sarnıcı, 1453 (Bölüm 44). docs/BOLUM_YEREBATAN.md.
## Gerçek boyda: iç ölçü ~137,8 × 65 m; 12 sıra × 28 = 336 sütun (aralık 4,75 × 5,0 m), sütun tepesi (yastık taşı) 8,8 m,
## tuğla çapraz tonozların tepesi 11,4 m. Su 2,2 m (Gyllius: "sütunlar suda çok derin duruyordu"). Batı −x, kuzey −z.
## Çizim bütçesi: sütun gövdeleri/başlıklar MultiMesh (gerçek + suyun altında ters kopya = sahte yansıma), tonoz ve
## kemerler tek ağ (yansımasıyla iki), duvarlar tek ağ. Işık huzmeleri ışık değil, toplamsal ağ + toz; yakındaki iki
## huzmenin dibinde birer zayıf OmniLight (oyuncuya en yakın olanlar). Su: saydam, dalgacıklı, parlak yüzey.
## 1453'te Medusa başları çamurun ve suyun altındadır (1985–87 temizliğine dek görünmez): ışık tutulunca seçilir.

const SX := 4.75
const SZ := 5.0
const NX := 28
const NZ := 12
const HALF_X := 68.875          # (NX + 1) * SX / 2
const HALF_Z := 32.5            # (NZ + 1) * SZ / 2
const WATER_Y := 2.2
const CAP_Y := 7.75             # gövdenin tepesi (başlığın altı)
const IMPOST_Y := 8.8           # yastık taşının üstü: kemerler buradan kalkar
const VAULT_H := 2.6
const SHAFT_R := 0.34
## Medusa sütunları (kuzeybatı köşe): [sütun i, sütun j, "side" | "inv"]
const MEDUSA := [[1, 1, "side"], [2, 1, "inv"]]
## Tavus gözü ("gözyaşı") sütunu
const HEN_EYE := [9, 6]
## Kuyular (tonoz gözü bx, bz): ilk ikisi oyunun kuyuları: Eudokia'nın kuyusu (düşüş), Yakovos'un evinin kuyusu (çıkış;
## gözün kuzey köşelerindeki iki sütun Medusa'lı)
const WELLS := [[22, 8], [2, 2], [17, 4], [12, 9], [6, 3], [26, 3], [9, 11], [14, 2]]

var _t := 0.0
var water: MeshInstance3D
var beams: Array[Dictionary] = []      # {pos: Vector3 (su yüzündeki merkez), mesh, pool, dust, light}
var medusa: Array[Node3D] = []
var hen_eye: MeshInstance3D
var fall_well := Vector3.ZERO           # Eudokia'nın kuyusunun su yüzündeki merkezi
var exit_well := Vector3.ZERO           # Yakovos'un kuyusu (Medusa köşesi)
var _fish_mm: MultiMesh
var _fish: Array[Dictionary] = []
var _beam_lights: Array[OmniLight3D] = []
var _rings: Array[MeshInstance3D] = []
var _ring_i := 0
var _drip_t := 1.0
var body: StaticBody3D
var focus := Vector3.ZERO               # balıkların ve damlaların toplandığı yer (oyuncu)
var daylight := 1.0                     # kuyu ağızlarının parlaklığı (0: gece)
var _caustic_mats: Array[ShaderMaterial] = []
var _beam_mat: ShaderMaterial
var _pool_mat: ShaderMaterial
var _dust_mat: StandardMaterial3D


static func col_x(i: int) -> float:
	return -HALF_X + (i + 1) * SX


static func col_z(j: int) -> float:
	return -HALF_Z + (j + 1) * SZ


static func column(i: int, j: int) -> Vector3:
	return Vector3(col_x(i), 0.0, col_z(j))


## Tonoz gözünün (iki sütun sırasının arası) su yüzündeki merkezi
static func bay(bx: int, bz: int) -> Vector3:
	return Vector3(-HALF_X + (bx + 0.5) * SX, WATER_Y, -HALF_Z + (bz + 0.5) * SZ)


## Noktaya en yakın sütun (x, z düzleminde) ve uzaklığı
static func nearest_column(p: Vector3) -> Array:
	var i := clampi(roundi((p.x + HALF_X) / SX) - 1, 0, NX - 1)
	var j := clampi(roundi((p.z + HALF_Z) / SZ) - 1, 0, NZ - 1)
	var c := column(i, j)
	return [c, Vector2(p.x - c.x, p.z - c.z).length()]


func _ready() -> void:
	name = "Cistern"
	fall_well = bay(WELLS[0][0], WELLS[0][1])
	exit_well = bay(WELLS[1][0], WELLS[1][1])
	_build_env()
	_build_columns()
	_build_vaults()
	_build_walls()
	_build_water()
	_build_wells()
	_build_medusa()
	_build_hen_eye()
	_build_fish()
	_build_rings()
	_build_collision()


# ================================================================ ortam

func _build_env() -> void:
	var we := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("020304")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("1a2226")
	e.ambient_light_energy = 0.35
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.15
	# Uzaklaşan karanlık: sıralar 25-45 m'de karanlığa gömülür
	e.fog_enabled = true
	e.fog_light_color = Color("05080a")
	e.fog_light_energy = 1.0
	e.fog_density = 0.055
	e.fog_sky_affect = 0.0
	e.glow_enabled = true
	e.glow_intensity = 0.6
	e.glow_bloom = 0.08
	e.glow_hdr_threshold = 0.9
	we.environment = e
	we.name = "CisternEnv"
	add_child(we)


# ================================================================ sütunlar

func _marble_shader(reflected: bool) -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode %s;
uniform float water_y = %f;
uniform float reflected = %f;
varying vec3 wp;
varying vec3 lp;
varying vec3 tint;
float h(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float n2(vec2 p) { vec2 i = floor(p); vec2 f = fract(p); vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(h(i), h(i + vec2(1, 0)), u.x), mix(h(i + vec2(0, 1)), h(i + vec2(1, 1)), u.x), u.y); }
void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	lp = VERTEX;
	tint = INSTANCE_CUSTOM.rgb;
}
void fragment() {
	float y = reflected > 0.5 ? 2.0 * water_y - wp.y : wp.y;
	float a = atan(lp.x, lp.z) + tint.r * 17.0;
	// Mermer: yumuşak bulut ve ince, soluk damar
	float cloud = n2(vec2(a * 2.0, y * 0.8)) * 0.6 + n2(vec2(a * 5.0 + 3.0, y * 2.1)) * 0.4;
	float vein = abs(n2(vec2(a * 3.0 + y * 0.45, y * 0.9)) - 0.5);
	vein = 1.0 - smoothstep(0.0, 0.035, vein);
	vec3 base = tint * (0.9 + 0.16 * (cloud - 0.5));
	base = mix(base, base * 0.78, vein * 0.35);
	// Su çizgisi: yosun bandı, üstünde kışın yükselen suyun bıraktığı kireç bantları, dipte koyu
	float wl = water_y;
	float algae = 1.0 - smoothstep(wl + 0.05, wl + 0.55, y);
	base = mix(base, vec3(0.16, 0.22, 0.14), algae * 0.85);
	float lime = smoothstep(wl + 1.6, wl + 1.75, y) * (1.0 - smoothstep(wl + 2.6, wl + 3.4, y));
	lime *= 0.55 + 0.45 * n2(vec2(a * 8.0, y * 0.5));
	base = mix(base, vec3(0.86, 0.85, 0.78), lime * 0.35);
	float drip = smoothstep(0.7, 0.95, n2(vec2(a * 6.0, y * 0.12))) * smoothstep(wl + 3.0, wl + 0.8, y);
	base = mix(base, base * vec3(0.72, 0.7, 0.62), drip * 0.5);
	if (reflected > 0.5) {
		base *= vec3(0.62, 0.72, 0.70);
		if (!FRONT_FACING) { NORMAL = -NORMAL; }
	}
	ALBEDO = base;
	ROUGHNESS = 0.55 - 0.3 * algae;
	SPECULAR = 0.35;
}
""" % ["cull_front" if reflected else "cull_back", WATER_Y, 1.0 if reflected else 0.0]
	var m := ShaderMaterial.new()
	m.shader = sh
	return m


## Gövde: hafif konik, 12 yüzlü; altta kaide halkası, üstte boyun halkası
func _shaft_mesh() -> Mesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var y0 := WATER_Y - 0.05
	var rings := [[y0, SHAFT_R + 0.01], [CAP_Y - 0.35, SHAFT_R - 0.035], [CAP_Y - 0.3, SHAFT_R + 0.025], [CAP_Y - 0.15, SHAFT_R + 0.025], [CAP_Y - 0.1, SHAFT_R - 0.03], [CAP_Y, SHAFT_R - 0.03]]
	_lathe(st, rings, 12)
	st.generate_normals()
	return st.commit()


## Dönel yüzey: [y, r] halkaları arasında n yüzlü şeritler (yüzeyler dışa bakar)
func _lathe(st: SurfaceTool, rings: Array, n: int, off := Vector3.ZERO) -> void:
	for k in rings.size() - 1:
		var ya: float = rings[k][0]
		var ra: float = rings[k][1]
		var yb: float = rings[k + 1][0]
		var rb: float = rings[k + 1][1]
		for s in n:
			var a0 := TAU * s / n
			var a1 := TAU * (s + 1) / n
			var p00 := off + Vector3(sin(a0) * ra, ya, cos(a0) * ra)
			var p01 := off + Vector3(sin(a1) * ra, ya, cos(a1) * ra)
			var p10 := off + Vector3(sin(a0) * rb, yb, cos(a0) * rb)
			var p11 := off + Vector3(sin(a1) * rb, yb, cos(a1) * rb)
			st.add_vertex(p00)
			st.add_vertex(p01)
			st.add_vertex(p11)
			st.add_vertex(p00)
			st.add_vertex(p11)
			st.add_vertex(p10)


func _box(st: SurfaceTool, c: Vector3, s: Vector3) -> void:
	var h := s * 0.5
	var v := [Vector3(-h.x, -h.y, -h.z), Vector3(h.x, -h.y, -h.z), Vector3(h.x, h.y, -h.z), Vector3(-h.x, h.y, -h.z),
		Vector3(-h.x, -h.y, h.z), Vector3(h.x, -h.y, h.z), Vector3(h.x, h.y, h.z), Vector3(-h.x, h.y, h.z)]
	for f: Array in [[0, 3, 2, 1], [4, 5, 6, 7], [0, 4, 7, 3], [1, 2, 6, 5], [3, 7, 6, 2], [0, 1, 5, 4]]:
		st.add_vertex(c + v[f[0]])
		st.add_vertex(c + v[f[1]])
		st.add_vertex(c + v[f[2]])
		st.add_vertex(c + v[f[0]])
		st.add_vertex(c + v[f[2]])
		st.add_vertex(c + v[f[3]])


## Başlık türleri (devşirme: her sütun başka binadan): 0 Korint (yaprak sıralı çan), 1 İon (iki salyangoz), 2 yalın
## (kesik koni; Gyllius: "bir kısmı işlenmemiş"). Hepsinin üstünde ikinci yastık taşı (Gyllius: "ikinci bir abaküs").
func _capital_mesh(kind: int) -> Mesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	match kind:
		0:
			_lathe(st, [[CAP_Y, 0.32], [CAP_Y + 0.25, 0.36], [CAP_Y + 0.5, 0.44], [CAP_Y + 0.62, 0.5]], 12)
			# İki sıra akantus yaprağı: dışa kıvrık uçlar
			for row in 2:
				for k in 8:
					var a := TAU * (k + 0.5 * row) / 8.0
					var r := 0.36 + 0.06 * row
					var y := CAP_Y + 0.12 + 0.22 * row
					var d := Vector3(sin(a), 0.0, cos(a))
					_leaf(st, d * r + Vector3(0, y, 0), d, 0.13, 0.26)
			_box(st, Vector3(0, CAP_Y + 0.7, 0), Vector3(1.0, 0.16, 1.0))
		1:
			_lathe(st, [[CAP_Y, 0.32], [CAP_Y + 0.12, 0.36], [CAP_Y + 0.22, 0.4]], 12)
			_box(st, Vector3(0, CAP_Y + 0.33, 0), Vector3(0.95, 0.2, 0.62))
			for sx: float in [-0.44, 0.44]:
				_lathe_x(st, Vector3(sx, CAP_Y + 0.27, 0), 0.15, 0.62)
			_box(st, Vector3(0, CAP_Y + 0.5, 0), Vector3(0.95, 0.12, 0.95))
		_:
			_lathe(st, [[CAP_Y, 0.31], [CAP_Y + 0.45, 0.47], [CAP_Y + 0.5, 0.47]], 8)
			_box(st, Vector3(0, CAP_Y + 0.57, 0), Vector3(0.98, 0.14, 0.98))
	# Yastık taşı (impost): başlığın üstünde, dört kemeri taşır
	_box(st, Vector3(0, IMPOST_Y - 0.19, 0), Vector3(1.18, 0.38, 1.18))
	st.generate_normals()
	return st.commit()


func _leaf(st: SurfaceTool, base: Vector3, out: Vector3, w: float, h: float) -> void:
	var side := Vector3(out.z, 0.0, -out.x) * w * 0.5
	var tip := base + Vector3(0, h, 0) + out * 0.12
	var mid := base + Vector3(0, h * 0.5, 0) + out * 0.03
	for t in [[base - side, base + side, mid + side * 1.2], [base - side, mid + side * 1.2, mid - side * 1.2],
			[mid - side * 1.2, mid + side * 1.2, tip]]:
		st.add_vertex(t[0])
		st.add_vertex(t[1])
		st.add_vertex(t[2])
		st.add_vertex(t[0])
		st.add_vertex(t[2])
		st.add_vertex(t[1])


## İon salyangozu: cephe boyunca (z) uzanan yatık rulo, kesiti x-y düzleminde (c merkezli, r yarıçap)
func _lathe_x(st: SurfaceTool, c: Vector3, r: float, length: float) -> void:
	var n := 8
	for s in n:
		var a0 := TAU * s / n
		var a1 := TAU * (s + 1) / n
		var e0 := Vector3(cos(a0) * r, sin(a0) * r, 0)
		var e1 := Vector3(cos(a1) * r, sin(a1) * r, 0)
		var h := Vector3(0, 0, length * 0.5)
		st.add_vertex(c + e0 - h)
		st.add_vertex(c + e1 + h)
		st.add_vertex(c + e1 - h)
		st.add_vertex(c + e0 - h)
		st.add_vertex(c + e0 + h)
		st.add_vertex(c + e1 + h)


func _build_columns() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 532
	var shaft := _shaft_mesh()
	var caps: Array[Mesh] = [_capital_mesh(0), _capital_mesh(1), _capital_mesh(2)]
	var slots: Array = [[], [], []]
	var shaft_xf: Array[Transform3D] = []
	var shaft_col: Array[Color] = []
	var skip := {}
	for m: Array in MEDUSA:
		skip[Vector2i(m[0], m[1])] = true
	skip[Vector2i(HEN_EYE[0], HEN_EYE[1])] = true
	for i in NX:
		for j in NZ:
			var p := column(i, j)
			# Devşirme: tonu ve damarı her sütunda başka (beyaz Prokonnesos, gri, pembemsi, yeşilimsi)
			var tone := [Color("d8d4c8"), Color("c4c2bc"), Color("d6c4b8"), Color("b8beb4"), Color("cfc8b4")][rng.randi() % 5] as Color
			tone = tone.darkened(rng.randf_range(0.0, 0.12))
			var yaw := rng.randf() * TAU
			var xf := Transform3D(Basis(Vector3.UP, yaw), p)
			if not skip.has(Vector2i(i, j)):
				shaft_xf.append(xf)
				shaft_col.append(tone)
			var r := rng.randf()
			var kind := 0 if r < 0.55 else (1 if r < 0.8 else 2)
			(slots[kind] as Array).append([Transform3D(Basis(Vector3.UP, roundf(yaw / (PI * 0.5)) * PI * 0.5), p), tone.lightened(0.04)])
	_mm(shaft, shaft_xf, shaft_col, _marble_shader(false), false, "Shafts")
	_mm(shaft, shaft_xf, shaft_col, _marble_shader(true), true, "ShaftsReflected")
	for k in 3:
		var xs: Array[Transform3D] = []
		var cs: Array[Color] = []
		for s: Array in slots[k]:
			xs.append(s[0])
			cs.append(s[1])
		_mm(caps[k], xs, cs, _marble_shader(false), false, "Capitals%d" % k)
		_mm(caps[k], xs, cs, _marble_shader(true), true, "CapitalsReflected%d" % k)


## Su yüzeyine göre ters kopya: y → 2·WATER_Y − y
func _mirror(xf: Transform3D) -> Transform3D:
	var flip := Transform3D(Basis.from_scale(Vector3(1, -1, 1)), Vector3(0, 2.0 * WATER_Y, 0))
	return flip * xf


func _mm(mesh: Mesh, xfs: Array[Transform3D], cols: Array[Color], mat: Material, reflected: bool, nm: String) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = mesh
	mm.instance_count = xfs.size()
	for k in xfs.size():
		mm.set_instance_transform(k, _mirror(xfs[k]) if reflected else xfs[k])
		mm.set_instance_custom_data(k, cols[k])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = mat
	mi.name = nm
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if reflected else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)
	return mi


# ================================================================ tonozlar

func _brick_shader(reflected: bool, vault: bool) -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode %s;
uniform float water_y = %f;
uniform float reflected = %f;
uniform float vault = %f;
uniform float caustic = 1.0;
varying vec3 wp;
varying vec3 wn;
float h(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float n2(vec2 p) { vec2 i = floor(p); vec2 f = fract(p); vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(h(i), h(i + vec2(1, 0)), u.x), mix(h(i + vec2(0, 1)), h(i + vec2(1, 1)), u.x), u.y); }
void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}
float bricks(vec2 p) {
	// İnce Bizans tuğlası (~4,5 cm) ve kalın harç: sıra yüksekliği 0,085 m, tuğla boyu 0,36 m
	float row = floor(p.y / 0.085);
	float x = p.x / 0.36 + (mod(row, 2.0) * 0.5);
	vec2 f = vec2(fract(x), fract(p.y / 0.085));
	float m = step(0.06, f.x) * step(0.44, f.y);
	return m;
}
void fragment() {
	float y = reflected > 0.5 ? 2.0 * water_y - wp.y : wp.y;
	vec2 uv;
	if (vault > 0.5) {
		uv = vec2(wp.x + wp.z * 0.02, wp.z * 0.9 + y * 0.6);
	} else {
		uv = abs(wn.x) > 0.5 ? vec2(wp.z, y) : vec2(wp.x, y);
	}
	float aa = clamp(length(fwidth(uv)) * 9.0, 0.0, 1.0);
	float b = mix(bricks(uv), 0.82, aa);
	vec2 cell = vec2(floor(uv.x / 0.36 + 0.5 * mod(floor(uv.y / 0.085), 2.0)), floor(uv.y / 0.085));
	vec3 brick = mix(vec3(0.46, 0.25, 0.17), vec3(0.58, 0.36, 0.24), h(cell));
	brick *= 0.8 + 0.25 * n2(wp.xz * 0.7 + vec2(y));
	vec3 mortar = vec3(0.62, 0.58, 0.50);
	vec3 col = mix(mortar, brick, b);
	// Nem lekeleri, kireç sızıntısı (tonozun tepesinden aşağı)
	float damp = smoothstep(0.55, 0.85, n2(wp.xz * 0.25 + vec2(3.1)));
	col = mix(col, col * vec3(0.45, 0.5, 0.42), damp * 0.6);
	float salt = smoothstep(0.7, 0.95, n2(vec2(wp.x * 1.3, wp.z * 1.3 + y * 0.2)));
	col = mix(col, vec3(0.82, 0.82, 0.76), salt * 0.3);
	// Duvar dibi: su çizgisi ve yosun
	float algae = 1.0 - smoothstep(water_y + 0.05, water_y + 0.7, y);
	col = mix(col, vec3(0.14, 0.2, 0.13), algae * 0.85);
	// Suyun tavana vuran kıpırtılı yansıması (kostik): ışığın vurduğu yerde dalgalanır
	if (vault > 0.5 && reflected < 0.5) {
		vec2 q = wp.xz * 1.1;
		float c1 = n2(q + vec2(TIME * 0.35, TIME * 0.21));
		float c2 = n2(q * 1.7 - vec2(TIME * 0.27, -TIME * 0.31));
		float c = 1.0 - abs(c1 - c2) * 3.0;
		c = pow(clamp(c, 0.0, 1.0), 5.0);
		col *= 1.0 + c * 0.8 * caustic;
	}
	if (reflected > 0.5) {
		col *= vec3(0.55, 0.66, 0.64);
		if (!FRONT_FACING) { NORMAL = -NORMAL; }
	}
	ALBEDO = col;
	ROUGHNESS = 0.9;
	SPECULAR = 0.2;
}
""" % ["cull_front" if reflected else "cull_back", WATER_Y, 1.0 if reflected else 0.0, 1.0 if vault else 0.0]
	var m := ShaderMaterial.new()
	m.shader = sh
	if vault and not reflected:
		_caustic_mats.append(m)
	return m


func _vault_h(u: float, v: float) -> float:
	return VAULT_H * minf(sqrt(maxf(0.0, 1.0 - u * u)), sqrt(maxf(0.0, 1.0 - v * v)))


## Çapraz tonoz: iki beşik tonozun kesişimi; her göz 10 × 10 ızgara. Kuyu gözlerinde tepede delik (kuyu bacası).
## Göz kenarlarında kemer bantları (tuğla kuşak). Normaller aşağı (içeriden görünür).
func _vault_mesh() -> Mesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var holes := {}
	for w: Array in WELLS:
		holes[Vector2i(w[0], w[1])] = true
	var n := 10
	for bx in NX + 1:
		for bz in NZ + 1:
			var cx := -HALF_X + (bx + 0.5) * SX
			var cz := -HALF_Z + (bz + 0.5) * SZ
			var hole := holes.has(Vector2i(bx, bz))
			for a in n:
				for b in n:
					var u0 := -1.0 + 2.0 * a / n
					var u1 := -1.0 + 2.0 * (a + 1) / n
					var v0 := -1.0 + 2.0 * b / n
					var v1 := -1.0 + 2.0 * (b + 1) / n
					if hole and absf((u0 + u1) * 0.5) < 0.3 and absf((v0 + v1) * 0.5) < 0.3:
						continue
					var p := func(u: float, v: float) -> Vector3:
						return Vector3(cx + u * SX * 0.5, IMPOST_Y + _vault_h(u, v), cz + v * SZ * 0.5)
					var q00: Vector3 = p.call(u0, v0)
					var q10: Vector3 = p.call(u1, v0)
					var q01: Vector3 = p.call(u0, v1)
					var q11: Vector3 = p.call(u1, v1)
					# Aşağıdan görünür sarılım
					st.add_vertex(q00)
					st.add_vertex(q10)
					st.add_vertex(q11)
					st.add_vertex(q00)
					st.add_vertex(q11)
					st.add_vertex(q01)
	# Kemer bantları: sütun sıraları boyunca (x yönünde ve z yönünde) her aralıkta bir yarım daire şerit
	var seg := 12
	for j in range(-1, NZ + 1):
		var z := -HALF_Z + (j + 1) * SZ
		for bx in NX + 1:
			var x0 := -HALF_X + bx * SX
			_arch(st, Vector3(x0, 0, z), Vector3(x0 + SX, 0, z), Vector3(0, 0, 1), seg)
	for i in range(-1, NX + 1):
		var x := -HALF_X + (i + 1) * SX
		for bz in NZ + 1:
			var z0 := -HALF_Z + bz * SZ
			_arch(st, Vector3(x, 0, z0), Vector3(x, 0, z0 + SZ), Vector3(1, 0, 0), seg)
	st.generate_normals()
	return st.commit()


func _arch(st: SurfaceTool, a: Vector3, b: Vector3, side: Vector3, seg: int) -> void:
	var w := 0.26
	var drop := 0.16
	var prev_l := Vector3.ZERO
	var prev_r := Vector3.ZERO
	var prev_lo_l := Vector3.ZERO
	var prev_lo_r := Vector3.ZERO
	for k in seg + 1:
		var u := -1.0 + 2.0 * k / seg
		var c := a.lerp(b, (u + 1.0) * 0.5)
		var hgt := IMPOST_Y + VAULT_H * sqrt(maxf(0.0, 1.0 - u * u)) * 0.985
		var l := c + side * w + Vector3(0, hgt, 0)
		var r := c - side * w + Vector3(0, hgt, 0)
		var lo_l := l - Vector3(0, drop, 0)
		var lo_r := r - Vector3(0, drop, 0)
		if k > 0:
			for quad: Array in [[prev_lo_l, lo_l, lo_r, prev_lo_r], [prev_l, l, lo_l, prev_lo_l], [prev_lo_r, lo_r, r, prev_r]]:
				st.add_vertex(quad[0])
				st.add_vertex(quad[1])
				st.add_vertex(quad[2])
				st.add_vertex(quad[0])
				st.add_vertex(quad[2])
				st.add_vertex(quad[3])
				st.add_vertex(quad[0])
				st.add_vertex(quad[2])
				st.add_vertex(quad[1])
				st.add_vertex(quad[0])
				st.add_vertex(quad[3])
				st.add_vertex(quad[2])
		prev_l = l
		prev_r = r
		prev_lo_l = lo_l
		prev_lo_r = lo_r


func _build_vaults() -> void:
	var mesh := _vault_mesh()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.name = "Vaults"
	mi.material_override = _brick_shader(false, true)
	add_child(mi)
	var rf := MeshInstance3D.new()
	rf.mesh = mesh
	rf.name = "VaultsReflected"
	rf.transform = _mirror(Transform3D.IDENTITY)
	rf.material_override = _brick_shader(true, true)
	rf.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(rf)


# ================================================================ duvarlar

func _build_walls() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var top := IMPOST_Y + VAULT_H + 0.4
	var y0 := WATER_Y - 0.1
	# İç yüzler (içeri bakar): kuzey, güney, batı, doğu
	var quads := [
		[Vector3(-HALF_X, y0, -HALF_Z), Vector3(HALF_X, y0, -HALF_Z), Vector3(HALF_X, top, -HALF_Z), Vector3(-HALF_X, top, -HALF_Z)],
		[Vector3(HALF_X, y0, HALF_Z), Vector3(-HALF_X, y0, HALF_Z), Vector3(-HALF_X, top, HALF_Z), Vector3(HALF_X, top, HALF_Z)],
		[Vector3(-HALF_X, y0, HALF_Z), Vector3(-HALF_X, y0, -HALF_Z), Vector3(-HALF_X, top, -HALF_Z), Vector3(-HALF_X, top, HALF_Z)],
		[Vector3(HALF_X, y0, -HALF_Z), Vector3(HALF_X, y0, HALF_Z), Vector3(HALF_X, top, HALF_Z), Vector3(HALF_X, top, -HALF_Z)],
	]
	for q: Array in quads:
		st.add_vertex(q[0])
		st.add_vertex(q[2])
		st.add_vertex(q[1])
		st.add_vertex(q[0])
		st.add_vertex(q[3])
		st.add_vertex(q[2])
	# Duvar payeleri: her sütun sırasının duvara vardığı yerde yarım paye (kemerler buraya iner)
	for i in NX:
		for zs: float in [-HALF_Z, HALF_Z]:
			_box(st, Vector3(col_x(i), (y0 + IMPOST_Y) * 0.5, zs - signf(zs) * 0.2), Vector3(0.9, IMPOST_Y - y0, 0.4))
	for j in NZ:
		for xs: float in [-HALF_X, HALF_X]:
			_box(st, Vector3(xs - signf(xs) * 0.2, (y0 + IMPOST_Y) * 0.5, col_z(j)), Vector3(0.4, IMPOST_Y - y0, 0.9))
	st.generate_normals()
	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.name = "Walls"
	mi.material_override = _brick_shader(false, false)
	add_child(mi)
	var rf := MeshInstance3D.new()
	rf.mesh = mesh
	rf.name = "WallsReflected"
	rf.transform = _mirror(Transform3D.IDENTITY)
	rf.material_override = _brick_shader(true, false)
	rf.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(rf)


# ================================================================ su

func _build_water() -> void:
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, specular_schlick_ggx;
uniform vec4 deep : source_color = vec4(0.012, 0.03, 0.03, 1.0);
uniform vec4 murk : source_color = vec4(0.05, 0.11, 0.09, 1.0);
uniform float calm = 1.0;
varying vec3 wp;
float h(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float n2(vec2 p) { vec2 i = floor(p); vec2 f = fract(p); vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(h(i), h(i + vec2(1, 0)), u.x), mix(h(i + vec2(0, 1)), h(i + vec2(1, 1)), u.x), u.y); }
void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	vec2 p = wp.xz;
	float e = 0.05;
	float t = TIME * 0.4;
	float a = n2(p * 2.2 + vec2(t, t * 0.6)) + 0.5 * n2(p * 5.3 - vec2(t * 0.7, -t));
	float ax = n2((p + vec2(e, 0.0)) * 2.2 + vec2(t, t * 0.6)) + 0.5 * n2((p + vec2(e, 0.0)) * 5.3 - vec2(t * 0.7, -t));
	float az = n2((p + vec2(0.0, e)) * 2.2 + vec2(t, t * 0.6)) + 0.5 * n2((p + vec2(0.0, e)) * 5.3 - vec2(t * 0.7, -t));
	vec3 nrm = normalize(vec3(-(ax - a) * 0.6 * calm, 1.0, -(az - a) * 0.6 * calm));
	NORMAL = normalize((VIEW_MATRIX * vec4(nrm, 0.0)).xyz);
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	ALBEDO = mix(murk.rgb, deep.rgb, 0.5 + 0.5 * fres);
	// Yukarıdan bakınca bulanık su (dipteki taşlar ışıkla seçilir), yatay bakışta yansıma (alttaki ters sütunlar) baskın
	ALPHA = mix(0.62, 0.16, smoothstep(0.0, 0.85, fres));
	ROUGHNESS = 0.06;
	SPECULAR = 0.9;
	METALLIC = 0.0;
}
"""
	var m := ShaderMaterial.new()
	m.shader = sh
	var pm := PlaneMesh.new()
	pm.size = Vector2(HALF_X * 2.0, HALF_Z * 2.0)
	pm.subdivide_width = 0
	pm.subdivide_depth = 0
	water = MeshInstance3D.new()
	water.mesh = pm
	water.material_override = m
	water.position = Vector3(0, WATER_Y, 0)
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	water.name = "Water"
	add_child(water)
	# Suyun altındaki koyu dip (yansımanın ardında boşluk görünmesin): çok derinde düz siyah
	var floor_mi := MeshInstance3D.new()
	var fm := PlaneMesh.new()
	fm.size = Vector2(HALF_X * 2.0, HALF_Z * 2.0)
	floor_mi.mesh = fm
	floor_mi.position = Vector3(0, 2.0 * WATER_Y - IMPOST_Y - VAULT_H - 0.5, 0)
	floor_mi.material_override = Props.mat(Color("030505"), 0.0, false, "", false)
	floor_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(floor_mi)


# ================================================================ kuyular ve ışık huzmeleri

func _build_wells() -> void:
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
uniform vec4 col : source_color = vec4(1.0, 0.92, 0.75, 1.0);
uniform float strength = 0.45;
uniform float top_y = 11.4;
uniform float bot_y = 2.2;
varying vec3 wp;
void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	float edge = pow(abs(dot(NORMAL, VIEW)), 2.0);
	// Uzaktaki huzme sise gömülmez ama söner (gerçek havada toz ışığı tutar)
	float dist = length(wp - (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz);
	edge *= 1.0 / (1.0 + dist * 0.035);
	float k = clamp((wp.y - bot_y) / (top_y - bot_y), 0.0, 1.0);
	float fade = smoothstep(0.0, 0.18, k) * (0.45 + 0.55 * k);
	float flick = 0.9 + 0.1 * sin(TIME * 0.7 + wp.x);
	ALBEDO = col.rgb * strength * edge * fade * flick;
}
"""
	_beam_mat = ShaderMaterial.new()
	_beam_mat.shader = sh
	_beam_mat.set_shader_parameter("top_y", IMPOST_Y + VAULT_H)
	_beam_mat.set_shader_parameter("bot_y", WATER_Y)
	var ps := Shader.new()
	ps.code = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
uniform vec4 col : source_color = vec4(1.0, 0.9, 0.7, 1.0);
uniform float strength = 0.6;
void fragment() {
	vec2 c = UV - vec2(0.5);
	float r = length(c) * 2.0;
	float ring = 0.5 + 0.5 * sin(r * 22.0 - TIME * 2.0);
	float a = (1.0 - smoothstep(0.0, 1.0, r)) * (0.75 + 0.25 * ring);
	ALBEDO = col.rgb * strength * a;
}
"""
	_pool_mat = ShaderMaterial.new()
	_pool_mat.shader = ps
	_dust_mat = StandardMaterial3D.new()
	_dust_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_dust_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_dust_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_dust_mat.albedo_color = Color(1.0, 0.92, 0.75, 0.6)
	_dust_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	var stone := Props.mat(Color("4a463e"), 0.0, false, "", false)
	var crown := IMPOST_Y + VAULT_H
	for w: Array in WELLS:
		var c := bay(w[0], w[1])
		# Baca: tonozun tepesinden 5 m yukarı, içi taş; ağzında gün ışığı
		var shaft := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.62
		cm.bottom_radius = 0.62
		cm.height = 5.0
		cm.radial_segments = 10
		cm.cap_top = false
		cm.cap_bottom = false
		shaft.mesh = cm
		shaft.position = Vector3(c.x, crown - 0.4 + 2.5, c.z)
		var sm := stone.duplicate() as StandardMaterial3D
		sm.cull_mode = BaseMaterial3D.CULL_DISABLED
		shaft.material_override = sm
		add_child(shaft)
		var sky := MeshInstance3D.new()
		var dm := CylinderMesh.new()
		dm.top_radius = 0.6
		dm.bottom_radius = 0.6
		dm.height = 0.02
		dm.radial_segments = 12
		sky.mesh = dm
		sky.position = Vector3(c.x, crown + 4.6, c.z)
		sky.material_override = Props.mat(Color("fff2d8"), 3.0, false, "", false)
		sky.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(sky)
		# Huzme: kuyu ağzından suya eğik inen koni (gün eğik vurur)
		var beam := MeshInstance3D.new()
		var bm := CylinderMesh.new()
		bm.top_radius = 0.5
		bm.bottom_radius = 1.45
		bm.height = crown + 4.6 - WATER_Y
		bm.radial_segments = 16
		bm.cap_top = false
		bm.cap_bottom = false
		beam.mesh = bm
		# Gün eğik vurur: huzme suya kuyunun ağzının ~1,6 m doğusuna/güneyine iner
		var tilt := Vector3(0.11, 0.0, 0.045)
		var top_p := Vector3(c.x, crown + 4.6, c.z)
		var bot_p := Vector3(c.x, WATER_Y, c.z) + tilt * (crown + 4.6 - WATER_Y)
		beam.basis = _align_y(top_p - bot_p)
		beam.position = (top_p + bot_p) * 0.5
		beam.material_override = _beam_mat
		beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		beam.name = "Beam"
		add_child(beam)
		var pool := MeshInstance3D.new()
		var qm := QuadMesh.new()
		qm.size = Vector2(3.2, 3.2)
		pool.mesh = qm
		pool.rotation_degrees = Vector3(-90, 0, 0)
		pool.position = bot_p + Vector3(0, 0.02, 0)
		pool.material_override = _pool_mat
		pool.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(pool)
		var dust := CPUParticles3D.new()
		dust.amount = 36
		dust.lifetime = 9.0
		dust.preprocess = 9.0
		dust.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		dust.emission_box_extents = Vector3(0.55, (crown - WATER_Y) * 0.45, 0.55)
		dust.visibility_aabb = AABB(Vector3(-2, -6, -2), Vector3(4, 12, 4))
		dust.direction = Vector3(0.2, -1, 0.1)
		dust.spread = 60.0
		dust.gravity = Vector3(0, -0.01, 0)
		dust.initial_velocity_min = 0.02
		dust.initial_velocity_max = 0.08
		dust.scale_amount_min = 0.6
		dust.scale_amount_max = 1.4
		var qd := QuadMesh.new()
		qd.size = Vector2(0.018, 0.018)
		qd.material = _dust_mat
		dust.mesh = qd
		dust.position = (top_p + bot_p) * 0.5 + Vector3(0, -1.0, 0)
		add_child(dust)
		beams.append({"pos": bot_p, "beam": beam, "pool": pool, "dust": dust, "sky": sky, "well": Vector2i(w[0], w[1])})
	for k in 2:
		var l := OmniLight3D.new()
		l.light_color = Color("ffe0b0")
		l.light_energy = 0.9
		l.omni_range = 10.0
		l.omni_attenuation = 1.2
		l.shadow_enabled = false
		l.name = "BeamLight%d" % k
		add_child(l)
		_beam_lights.append(l)
	# Ip ve kova: üç kuyudan suya sarkan halat (biri kopuk: Eudokia'nın)
	var rope_mat := Props.mat(Color("8a7450"), 0.0, false, "", false)
	for k in [2, 3, 6]:
		var c := bay(WELLS[k][0], WELLS[k][1])
		var len := crown + 4.0 - WATER_Y - 0.8
		var r := MeshInstance3D.new()
		var rm := CylinderMesh.new()
		rm.top_radius = 0.018
		rm.bottom_radius = 0.018
		rm.height = len
		rm.radial_segments = 5
		r.mesh = rm
		r.material_override = rope_mat
		r.position = Vector3(c.x + 0.2, WATER_Y + 0.8 + len * 0.5, c.z)
		add_child(r)
		_bucket(Vector3(c.x + 0.2, WATER_Y + 0.55, c.z))
	# Eudokia'nın kuyusu: kopuk ip ucu tepede sallanır
	var fc := bay(WELLS[0][0], WELLS[0][1])
	var stub := MeshInstance3D.new()
	var sm2 := CylinderMesh.new()
	sm2.top_radius = 0.018
	sm2.bottom_radius = 0.012
	sm2.height = 4.2
	sm2.radial_segments = 5
	stub.mesh = sm2
	stub.material_override = rope_mat
	stub.position = Vector3(fc.x + 0.15, crown + 2.6, fc.z)
	stub.name = "BrokenRope"
	add_child(stub)


func _align_y(dir: Vector3) -> Basis:
	var y := dir.normalized()
	var x := y.cross(Vector3.FORWARD)
	if x.length() < 0.01:
		x = Vector3.RIGHT
	x = x.normalized()
	var z := x.cross(y).normalized()
	return Basis(x, y, z)


func _bucket(p: Vector3) -> Node3D:
	var b := Node3D.new()
	b.position = p
	add_child(b)
	Props.cyl(b, 0.16, 0.3, Vector3.ZERO, Color("6a4a2c"), Vector3.ZERO, 10, 0.19)
	Props.ring(b, 0.15, 0.17, Vector3(0, 0.1, 0), Color("4a4a4a"), Vector3(90, 0, 0))
	Props.ring(b, 0.16, 0.18, Vector3(0, -0.08, 0), Color("4a4a4a"), Vector3(90, 0, 0))
	return b


# ================================================================ Medusa başları ve tavus gözü sütunu

## Taş Medusa yüzü: kaide bloğu, cephesinde kabartma yüz (yükseklik alanından normal: ışıkla kabartma seçilir):
## yanaklar, göz çukurları ve göz kapakları, kaşlar, burun, dudaklar, saçta kıvrılan yılanlar; altta yosun.
## "side": yüz yan yatık, "inv": baş aşağı. (Gerçekte iki yüz de bloğun ortasında, kaba işçilikte; köken bilinmiyor.)
static var _medusa_shader: Shader


func _medusa_mat() -> ShaderMaterial:
	if _medusa_shader == null:
		_medusa_shader = Shader.new()
		_medusa_shader.code = """
shader_type spatial;
uniform vec4 stone : source_color = vec4(0.42, 0.45, 0.38, 1.0);
float h(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float n2(vec2 p) { vec2 i = floor(p); vec2 f = fract(p); vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(h(i), h(i + vec2(1, 0)), u.x), mix(h(i + vec2(0, 1)), h(i + vec2(1, 1)), u.x), u.y); }
float bump(vec2 p, vec2 c, vec2 r) { vec2 d = (p - c) / r; return max(0.0, 1.0 - dot(d, d)); }
float relief(vec2 uv) {
	vec2 p = uv * 2.0 - 1.0;
	p.y = -p.y;
	float f = 0.0;
	// Yüz: geniş oval kubbe
	f += 0.55 * sqrt(bump(p, vec2(0.0, -0.02), vec2(0.5, 0.64)));
	// Göz çukurları ve iri, bebeksiz gözler
	for (int k = 0; k < 2; k++) {
		float sx = k == 0 ? -0.2 : 0.2;
		f -= 0.22 * bump(p, vec2(sx, 0.14), vec2(0.16, 0.1));
		f += 0.14 * sqrt(bump(p, vec2(sx, 0.13), vec2(0.1, 0.065)));
		// Kaş: kalın kemer
		float bx = (p.x - sx) / 0.17;
		float by = p.y - (0.27 - 0.06 * bx * bx);
		f += 0.12 * max(0.0, 1.0 - abs(bx)) * max(0.0, 1.0 - abs(by) / 0.035);
		// Yanak
		f += 0.08 * bump(p, vec2(sx * 1.4, -0.12), vec2(0.17, 0.16));
	}
	// Burun: dikey sırt, ucu yuvarlak
	f += 0.18 * max(0.0, 1.0 - abs(p.x) / (0.045 + 0.05 * clamp(0.18 - p.y, 0.0, 0.3))) * step(-0.12, p.y) * step(p.y, 0.22);
	f += 0.1 * bump(p, vec2(0.0, -0.1), vec2(0.08, 0.05));
	// Dudaklar ve ağız yarığı
	f += 0.1 * bump(p, vec2(0.0, -0.25), vec2(0.15, 0.045));
	f -= 0.08 * max(0.0, 1.0 - abs(p.y + 0.29) / 0.012) * max(0.0, 1.0 - abs(p.x) / 0.14);
	f += 0.08 * bump(p, vec2(0.0, -0.34), vec2(0.12, 0.045));
	// Çene
	f += 0.06 * bump(p, vec2(0.0, -0.48), vec2(0.18, 0.1));
	// Yılan saçlar: yüzün çevresinde halka biçiminde kıvrılan kalın şeritler
	float r = length(p * vec2(1.0, 0.85));
	float a = atan(p.y, p.x);
	float ring = smoothstep(0.52, 0.6, r) * (1.0 - smoothstep(0.86, 0.95, r));
	float coil = 0.5 + 0.5 * sin(a * 9.0 + r * 18.0);
	float coil2 = 0.5 + 0.5 * sin(a * 9.0 - r * 14.0 + 1.3);
	float snake = ring * max(coil, coil2 * 0.8) * step(-0.35, p.y + 0.0 * a);
	f += 0.2 * snake * snake;
	// İki yılan başı çenenin altında düğümlenir
	f += 0.1 * bump(p, vec2(-0.22, -0.62), vec2(0.09, 0.06)) + 0.1 * bump(p, vec2(0.22, -0.62), vec2(0.09, 0.06));
	// Aşınma: kaba yüzey
	f += 0.025 * n2(uv * 40.0) + 0.04 * n2(uv * 9.0);
	return f;
}
void fragment() {
	float e = 0.004;
	float c = relief(UV);
	float dx = relief(UV + vec2(e, 0.0)) - c;
	float dy = relief(UV + vec2(0.0, e)) - c;
	vec3 n = normalize(vec3(-dx * 120.0, dy * 120.0, 1.0));
	NORMAL_MAP = n * 0.5 + 0.5;
	NORMAL_MAP_DEPTH = 1.0;
	vec3 col = stone.rgb * (0.75 + 0.5 * c);
	float algae = smoothstep(0.55, 0.85, n2(UV * 5.0 + vec2(2.0, 7.0))) * (0.4 + 0.6 * (1.0 - UV.y));
	col = mix(col, vec3(0.13, 0.2, 0.12), algae * 0.6);
	// Oyukların dibi koyu (kir, çamur)
	col *= 0.6 + 0.4 * smoothstep(0.0, 0.35, c);
	ALBEDO = col;
	ROUGHNESS = 0.8;
	SPECULAR = 0.3;
}
"""
	var m := ShaderMaterial.new()
	m.shader = _medusa_shader
	return m


func _medusa_head(kind: String) -> Node3D:
	var root := Node3D.new()
	var stone := Color("4a5044")
	var blk := Props.box(root, Vector3(1.25, 1.25, 1.1), Vector3.ZERO, stone.darkened(0.2))
	blk.name = "Block"
	# Yüz cephesi (+z) ve yan cephe (+x): kabartma
	for spec: Array in [[Vector3(0, 0, 0.556), Vector3.ZERO], [Vector3(0.63, 0, 0), Vector3(0, 90, 0)]]:
		var q := MeshInstance3D.new()
		var qm := QuadMesh.new()
		qm.size = Vector2(1.2, 1.2)
		q.mesh = qm
		q.position = spec[0]
		q.rotation_degrees = spec[1] + Vector3(0, 0, 90.0 if kind == "side" else 180.0)
		q.material_override = _medusa_mat()
		q.name = "Face"
		root.add_child(q)
	return root


func _build_medusa() -> void:
	var shaft := _shaft_mesh_from(1.25)
	for m: Array in MEDUSA:
		var c := column(m[0], m[1])
		var head := _medusa_head(m[2])
		# Kaide bloğu çamurun içinde: yüzün tepesi suyun ~0,6 m altında; yüz güneye (oyuncunun geleceği yöne) bakar
		head.position = Vector3(c.x, 0.85, c.z)
		head.rotation_degrees = Vector3(0, 0 if m[2] == "side" else 20, 0)
		head.name = "Medusa_" + String(m[2])
		add_child(head)
		# Nişan noktası: yüzün ortası (tespit karesi bu düğümü hedefler; kare denetimi başı özne sayar)
		var aim := Node3D.new()
		aim.name = "Aim"
		aim.position = Vector3(0, 0, 0.6)
		head.add_child(aim)
		medusa.append(head)
		var mi := MeshInstance3D.new()
		mi.mesh = shaft
		mi.position = Vector3(c.x, 0, c.z)
		mi.material_override = _marble_single(Color("c8c4b8"))
		add_child(mi)
		# Çevresinde çamur tümseği (suyun altında, ışıkla seçilir)
		var mud := Props.ball(self, 1.05, Vector3(c.x, 0.1, c.z), Color("1e1e16"), Vector3(1.0, 0.22, 1.0), 10)
		mud.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _marble_single(col: Color) -> ShaderMaterial:
	var m := _marble_shader(false)
	# Tek ağ: INSTANCE_CUSTOM yok; renk uniformla değil, varsayılan beyaz yerine sabit ton
	m.shader.code = m.shader.code.replace("tint = INSTANCE_CUSTOM.rgb;", "tint = vec3(%f, %f, %f);" % [col.r, col.g, col.b])
	return m


func _shaft_mesh_from(y0: float) -> Mesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_lathe(st, [[y0, SHAFT_R + 0.02], [CAP_Y - 0.35, SHAFT_R - 0.035], [CAP_Y - 0.3, SHAFT_R + 0.025], [CAP_Y - 0.15, SHAFT_R + 0.025], [CAP_Y - 0.1, SHAFT_R - 0.03], [CAP_Y, SHAFT_R - 0.03]], 12)
	st.generate_normals()
	return st.commit()


## Tavus gözü (gözyaşı) sütunu: gövdede eğik dallar ve gözyaşı damlası biçimli göz kabartmaları; dipte ıslak
func _build_hen_eye() -> void:
	var c := column(HEN_EYE[0], HEN_EYE[1])
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
varying vec3 lp;
void vertex() { lp = VERTEX; }
void fragment() {
	float a = atan(lp.x, lp.z) / 6.2831853 + 0.5;
	vec2 g = vec2(a * 9.0, lp.y * 1.6 + a * 1.5);
	vec2 f = fract(g) - vec2(0.5);
	// Gözyaşı damlası: altı sivri oval
	float d = length(vec2(f.x * 1.6, (f.y + 0.1) * (f.y < 0.0 ? 0.8 : 1.4)));
	float eye = 1.0 - smoothstep(0.26, 0.31, d);
	float rim = smoothstep(0.24, 0.27, d) * (1.0 - smoothstep(0.31, 0.35, d));
	float branch = 1.0 - smoothstep(0.02, 0.05, abs(fract(a * 9.0 + lp.y * 0.55) - 0.5) - 0.42);
	vec3 col = vec3(0.70, 0.71, 0.66);
	col = mix(col, vec3(0.52, 0.53, 0.48), eye * 0.7);
	col = mix(col, vec3(0.86, 0.86, 0.8), rim * 0.8);
	col = mix(col, vec3(0.55, 0.56, 0.5), branch * 0.4);
	// Islak: gözlerden aşağı süzülen koyu iz (ağlıyor denmesinin sebebi)
	float wet = smoothstep(0.2, 0.0, abs(fract(a * 9.0) - 0.5)) * smoothstep(4.5, 2.2, lp.y);
	col *= 1.0 - wet * 0.35;
	float algae = 1.0 - smoothstep(2.25, 2.75, lp.y);
	col = mix(col, vec3(0.16, 0.22, 0.14), algae * 0.85);
	ALBEDO = col;
	ROUGHNESS = 0.35 + 0.4 * (1.0 - wet);
	SPECULAR = 0.5;
}
"""
	var m := ShaderMaterial.new()
	m.shader = sh
	hen_eye = MeshInstance3D.new()
	hen_eye.mesh = _shaft_mesh()
	hen_eye.position = c
	hen_eye.material_override = m
	hen_eye.name = "HenEye"
	add_child(hen_eye)
	var rf := MeshInstance3D.new()
	rf.mesh = hen_eye.mesh
	rf.transform = _mirror(Transform3D(Basis(), c))
	var rsh := Shader.new()
	rsh.code = sh.code.replace("shader_type spatial;", "shader_type spatial;\nrender_mode cull_front;").replace("ALBEDO = col;", "ALBEDO = col * vec3(0.62, 0.72, 0.7);\n\tif (!FRONT_FACING) { NORMAL = -NORMAL; }")
	var rm := ShaderMaterial.new()
	rm.shader = rsh
	rf.material_override = rm
	rf.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(rf)


# ================================================================ balıklar, damlalar, halkalar

func _build_fish() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Yassı gövde (iki üçgen yelpaze) ve kuyruk: 22 cm sazan
	var pts := [Vector3(0, 0, 0.12), Vector3(0.035, 0.0, 0.0), Vector3(0, 0, -0.1), Vector3(-0.035, 0.0, 0.0)]
	for t: Array in [[0, 1, 2], [0, 2, 3]]:
		for k: int in t:
			st.add_vertex(pts[k])
		st.add_vertex(pts[t[0]])
		st.add_vertex(pts[t[2]])
		st.add_vertex(pts[t[1]])
	for v: Vector3 in [Vector3(0, 0, -0.1), Vector3(0.05, 0.0, -0.17), Vector3(-0.05, 0.0, -0.17)]:
		st.add_vertex(v)
	for v: Vector3 in [Vector3(0, 0, -0.1), Vector3(-0.05, 0.0, -0.17), Vector3(0.05, 0.0, -0.17)]:
		st.add_vertex(v)
	st.generate_normals()
	_fish_mm = MultiMesh.new()
	_fish_mm.transform_format = MultiMesh.TRANSFORM_3D
	_fish_mm.mesh = st.commit()
	_fish_mm.instance_count = 48
	var rng := RandomNumberGenerator.new()
	rng.seed = 1545
	for k in 48:
		# Balıklar kuyu ağızlarının ışığında toplanır (Gyllius: "balıklar hava almaya oraya gelir")
		var home: Vector3 = (beams[k % beams.size()]["pos"] as Vector3) if k < 32 else Vector3(rng.randf_range(-60, 60), 0, rng.randf_range(-28, 28))
		_fish.append({"home": Vector3(home.x, WATER_Y - rng.randf_range(0.18, 0.7), home.z), "r": rng.randf_range(0.6, 2.4),
			"w": rng.randf_range(0.2, 0.5) * (1.0 if rng.randf() < 0.5 else -1.0), "a": rng.randf() * TAU, "s": rng.randf_range(0.8, 1.3)})
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = _fish_mm
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color("8a7a4a")
	fm.metallic = 0.3
	fm.roughness = 0.3
	fm.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = fm
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.name = "Fish"
	add_child(mi)


func _build_rings() -> void:
	var rm := StandardMaterial3D.new()
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rm.albedo_color = Color(0.8, 0.85, 0.8, 0.5)
	rm.cull_mode = BaseMaterial3D.CULL_DISABLED
	for k in 14:
		var tm := TorusMesh.new()
		tm.inner_radius = 0.92
		tm.outer_radius = 1.0
		tm.rings = 24
		tm.ring_segments = 3
		var mi := MeshInstance3D.new()
		mi.mesh = tm
		mi.material_override = rm.duplicate()
		mi.visible = false
		mi.scale = Vector3(0.1, 0.02, 0.1)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mi)
		_rings.append(mi)


## Su yüzünde genişleyen halka (damla, kürek, düşen taş). size: son yarıçap (m)
func ring(at: Vector3, size := 0.6, secs := 1.4) -> void:
	var mi := _rings[_ring_i % _rings.size()]
	_ring_i += 1
	mi.visible = true
	mi.position = Vector3(at.x, WATER_Y + 0.01, at.z)
	mi.scale = Vector3(0.05, 0.02, 0.05)
	var mat := mi.material_override as StandardMaterial3D
	mat.albedo_color.a = 0.55
	var tw := mi.create_tween().set_parallel()
	tw.tween_property(mi, "scale", Vector3(size, 0.02, size), secs).set_ease(Tween.EASE_OUT)
	tw.tween_property(mat, "albedo_color:a", 0.0, secs)
	tw.chain().tween_callback(func(): mi.visible = false)


func _process(delta: float) -> void:
	_t += delta
	# Balıklar: evlerinin çevresinde dolanır; ışığın yakınındakiler hızlanır
	for k in _fish.size():
		var f: Dictionary = _fish[k]
		f["a"] = float(f["a"]) + float(f["w"]) * delta * float(f["s"])
		var a: float = f["a"]
		var r: float = f["r"]
		var home: Vector3 = f["home"]
		var p := home + Vector3(cos(a) * r, sin(_t * 0.7 + k) * 0.05, sin(a) * r)
		var dir := Vector3(-sin(a), 0, cos(a)) * signf(float(f["w"]))
		var b := Basis.looking_at(dir, Vector3.UP).rotated(Vector3.UP, PI)
		b = b.rotated(dir.normalized(), sin(_t * 9.0 + k) * 0.15)
		_fish_mm.set_instance_transform(k, Transform3D(b, p))
	# Damlalar: tavandan arada bir, oyuncunun yakınına
	_drip_t -= delta
	if _drip_t <= 0.0:
		_drip_t = randf_range(0.6, 1.8)
		var p := focus + Vector3(randf_range(-9, 9), 0, randf_range(-9, 9))
		ring(p, randf_range(0.25, 0.5), 1.2)
		if randf() < 0.35:
			Audio.sfx("splash", -34.0, randf_range(2.4, 3.2))
	# Huzmelerin dibindeki ışık: oyuncuya en yakın iki kuyu
	var order: Array = beams.duplicate()
	order.sort_custom(func(x: Dictionary, y: Dictionary) -> bool:
		return (x["pos"] as Vector3).distance_squared_to(focus) < (y["pos"] as Vector3).distance_squared_to(focus))
	for k in _beam_lights.size():
		var l := _beam_lights[k]
		if k < order.size():
			l.global_position = (order[k]["pos"] as Vector3) + Vector3(0, 3.4, 0)
			l.light_energy = 0.9 * daylight
		l.visible = daylight > 0.05
	_beam_mat.set_shader_parameter("strength", 1.1 * daylight)
	_pool_mat.set_shader_parameter("strength", 1.0 * daylight)


# ================================================================ çarpışma

func _build_collision() -> void:
	body = StaticBody3D.new()
	body.name = "CisternBody"
	add_child(body)
	for i in NX:
		for j in NZ:
			var cs := CollisionShape3D.new()
			var sh := CylinderShape3D.new()
			sh.radius = SHAFT_R + 0.04
			sh.height = IMPOST_Y
			cs.shape = sh
			cs.position = column(i, j) + Vector3(0, IMPOST_Y * 0.5, 0)
			body.add_child(cs)
	for spec: Array in [[Vector3(0, 6, -HALF_Z - 0.5), Vector3(HALF_X * 2 + 2, 14, 1)], [Vector3(0, 6, HALF_Z + 0.5), Vector3(HALF_X * 2 + 2, 14, 1)],
			[Vector3(-HALF_X - 0.5, 6, 0), Vector3(1, 14, HALF_Z * 2 + 2)], [Vector3(HALF_X + 0.5, 6, 0), Vector3(1, 14, HALF_Z * 2 + 2)],
			[Vector3(0, -0.5, 0), Vector3(HALF_X * 2, 1, HALF_Z * 2)]]:
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = spec[1]
		cs.shape = bs
		cs.position = spec[0]
		body.add_child(cs)


## Gemi/kayık için: p noktası (x, z) bir sütuna ya da duvara r'den yakın mı; yakınsa itme vektörü (yoksa ZERO)
func push_out(p: Vector3, r: float) -> Vector3:
	var out := Vector3.ZERO
	var nc: Array = nearest_column(p)
	var c: Vector3 = nc[0]
	var d: float = nc[1]
	var lim := SHAFT_R + r
	if d < lim:
		var dir := Vector3(p.x - c.x, 0, p.z - c.z)
		if dir.length() < 0.001:
			dir = Vector3.RIGHT
		out += dir.normalized() * (lim - d)
	var mx := HALF_X - 0.6 - r
	var mz := HALF_Z - 0.6 - r
	if p.x < -mx:
		out.x += -mx - p.x
	elif p.x > mx:
		out.x += mx - p.x
	if p.z < -mz:
		out.z += -mz - p.z
	elif p.z > mz:
		out.z += mz - p.z
	return out
