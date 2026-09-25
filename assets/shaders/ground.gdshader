// Arazi: köşe rengi (yüz başına, low-poly) üstüne dünya koordinatında gürültüyle doku.
// Büyük lekeler (çimen/toprak adaları), orta ölçekte ton oynaması, ince kum/çakıl beneği.
// Yeşil yüzlerde çimen çizgileri, toprak yüzlerde çiğnenmiş koyu izler. Compatibility'de de çalışır.
shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform float patch_scale = 0.07;
uniform float detail_scale = 0.9;
uniform float speck_scale = 7.0;
uniform float strength = 1.0;

varying vec3 wpos;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 3; i++) {
		v += a * vnoise(p);
		p *= 2.03;
		a *= 0.5;
	}
	return v;
}

vec3 to_linear(vec3 c) {
	return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c));
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Compatibility çizicisi köşe rengini zaten doğrusal alır (StandardMaterial vertex_color_is_srgb ile aynı sonuç)
	vec3 base = COLOR.rgb;
	vec2 p = wpos.xz;
	float big = fbm(p * patch_scale);
	float mid = fbm(p * detail_scale + 7.1);
	float speck = vnoise(p * speck_scale);
	// Yeşillik: köşe renginde yeşil baskın mı
	float green = clamp((COLOR.g - max(COLOR.r, COLOR.b)) * 6.0, 0.0, 1.0);
	vec3 c = base;
	// Büyük adalar: çimende sarımsı/koyu yeşil, toprakta açık/koyu toprak
	// Toprakta açık/koyu toprak; çimende koyu zeytin ile kuru saman arası (doygunluğu artırmadan)
	vec3 warm = mix(base * vec3(1.12, 1.08, 0.86), mix(base, vec3(dot(base, vec3(0.33))) * vec3(1.15, 1.08, 0.75), 0.35), green);
	vec3 cool = mix(base * vec3(0.82, 0.9, 0.86), base * vec3(0.78, 0.84, 0.8), green);
	c = mix(cool, warm, smoothstep(0.3, 0.7, big));
	// Orta ölçek ton oynaması
	c *= 0.9 + 0.2 * mid;
	// Çimende ince sap çizgileri (hep koyulaştırır), toprakta çakıl beneği
	float blades = vnoise(vec2(p.x * 14.0, p.y * 3.0)) * vnoise(vec2(p.x * 3.0, p.y * 14.0));
	c *= mix(0.94 + 0.12 * speck, 0.84 + 0.16 * blades, green);
	// Toprakta seyrek koyu çakıl
	c *= 1.0 - (1.0 - green) * step(0.93, speck) * 0.25;
	ALBEDO = mix(base, c, strength);
	ROUGHNESS = 1.0;
}
