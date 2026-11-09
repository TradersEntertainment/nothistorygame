// =============================================================================
// ZAMAN BÜROSU - "Zamanın Dışındaki Manzara" (The view from an office outside time)
// Godot 4.4, GL Compatibility uyumlu. Tamamen prosedürel, doku yok, ekran dokusu yok.
//
// Fikir: Pencere bir QuadMesh. Fragment'te izleyicinin (kamera) quad'a göre konumundan
// bir bakış ışını kurulur; camın ARKASINDA sanal düzlemler (katmanlar) vardır ve
// ışın her düzlemle kesiştirilir. Böylece kafa oynatınca yakın katmanlar çok, uzak
// katmanlar az kayar (gerçek paralaks). Aşağıdaki gerçek-perspektifli "zaman nehri"
// ise sonsuz bir zemin düzlemiyle kesiştirilir.
//
// Katmanlar (arkadan öne):
//   1. Gökyüzü: alacakaranlık gradyanı, yıldızlar, aurora şeridi, devasa saat yüzü
//   2. Zaman nehri: aşağıdaki ışıklı şerit, üzerinde minik tarihler
//   3. Uzak Büro binaları: pencereleri yanan, yüzen özdeş binalar
//   4. Uzak çağ şeridi (sisli)
//   5. Ana çağ şeridi: Mısır > Roma > Konstantiniyye > 1453 surları > kalyon >
//      1970'ler apartmanı + TRT anteni > modern siluet > roket (soldan sağa tekrar)
//   6. Dev pirinç dişliler
//   7. Süzülen takvim yaprakları
//   8. Kayan "tarih" meteorları
//   9. Cam: yansıma, kir, buğu, çerçeve vinyeti
//
// QuadMesh: mesh.size = quad_size ile AYNI olmalı (düğümü scale ETME).
// Ön yüz: QuadMesh'in +Z yönü. +Z odanın içine baksın.
// =============================================================================
shader_type spatial;
render_mode unshaded, fog_disabled;

// ---------- Palet ----------
group_uniforms Palette;
uniform vec4 sky_top : source_color = vec4(0.05, 0.04, 0.17, 1.0);
uniform vec4 sky_mid : source_color = vec4(0.28, 0.12, 0.38, 1.0);
uniform vec4 sky_horizon : source_color = vec4(1.0, 0.42, 0.24, 1.0);
uniform vec4 void_deep : source_color = vec4(0.02, 0.015, 0.07, 1.0);
uniform vec4 silhouette_color : source_color = vec4(0.05, 0.035, 0.11, 1.0);
uniform vec4 brass_color : source_color = vec4(0.85, 0.58, 0.22, 1.0);
uniform vec4 river_color : source_color = vec4(0.30, 0.85, 1.0, 1.0);
uniform vec4 window_light : source_color = vec4(1.0, 0.76, 0.38, 1.0);
uniform vec4 glass_tint : source_color = vec4(0.55, 0.64, 0.78, 1.0);
group_uniforms;

// ---------- Hareket / derinlik ----------
group_uniforms Motion;
uniform float flow_speed : hint_range(0.0, 4.0) = 1.0;      // genel akış hızı (0 = donmuş)
uniform float parallax_depth : hint_range(0.0, 3.0) = 1.0;  // 0 = düz poster, 1 = normal, 2+ = abartılı
uniform float view_ref = 1.4;                                // izleyicinin tipik uzaklığı (pencere yüksekliği birimiyle)
uniform float horizon_lower : hint_range(-0.3, 0.4) = 0.10;  // ufku aşağı indirir (daha çok gökyüzü)
uniform float river_depth = 2.2;                             // nehrin gözün ne kadar altında aktığı
group_uniforms;

// ---------- Oyun kontrolü ----------
group_uniforms Game;
uniform float era_focus : hint_range(0.0, 1.0) = 0.0;       // 0..1, tween et: seçili çağ parlar
uniform int focus_era : hint_range(-1, 7) = 2;               // 0 Mısır 1 Roma 2 Konstantiniyye 3 1453 4 kalyon 5 1970s 6 modern 7 roket
group_uniforms;

// ---------- Cam ----------
group_uniforms Glass;
uniform vec2 quad_size = vec2(1.6, 1.2);                     // QuadMesh.size ile aynı!
uniform float dirt_amount : hint_range(0.0, 1.0) = 0.35;
uniform float reflection_strength : hint_range(0.0, 2.0) = 0.6;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.55;
uniform vec2 reflect_pos = vec2(0.22, 0.30);                 // odadaki lambanın cam üzerindeki yansıma noktası
group_uniforms;

varying vec2 v_q;    // pencere koordinatı: y yüksekliği 1 birim, merkez (0,0)
varying vec3 v_cam;  // kamera, quad yerel uzayında, aynı birimde

void vertex() {
	v_q = VERTEX.xy / quad_size.y;
	vec3 cam_local = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz;
	v_cam = cam_local / quad_size.y;
}

// =============================================================================
// Yardımcılar
// =============================================================================
float hash11(float n) {
	return fract(sin(n * 127.1 + 11.7) * 43758.5453);
}

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

mat2 rot2(float a) {
	float c = cos(a);
	float s = sin(a);
	return mat2(vec2(c, s), vec2(-s, c));
}

float sd_box(vec2 p, vec2 b) {
	vec2 d = abs(p) - b;
	return length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0);
}

float sd_circle(vec2 p, float r) {
	return length(p) - r;
}

// Tabanı y=0'da, yarı genişliği w, yüksekliği h olan ikizkenar üçgen
float sd_tri(vec2 p, float w, float h) {
	return max(-p.y, (abs(p.x) * h + p.y * w - w * h) / length(vec2(h, w)));
}

float sd_seg(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return length(pa - ba * h);
}

// Cam arkasındaki sanal düzlem (derinlik D, pencere-yüksekliği biriminde).
// Nötr bakışta (göz ekseni üzerinde, view_ref uzaklığında) sonuç = q olur;
// göz kayınca yakın katmanlar çok, uzaklar az kayar.
vec2 layer_uv(vec2 q, vec3 ro, float depth) {
	float s = 1.0 + depth / ro.z;
	vec2 hit = ro.xy + (q - ro.xy) * s;
	return hit / (1.0 + depth / view_ref);
}

// Çağ renkleri
vec3 era_color(int id) {
	if (id == 0) {
		return vec3(1.0, 0.78, 0.35);   // Mısır: kum altını
	}
	if (id == 1) {
		return vec3(0.95, 0.50, 0.32);  // Roma: terrakota
	}
	if (id == 2) {
		return vec3(1.0, 0.55, 0.62);   // Konstantiniyye: gül-altın
	}
	if (id == 3) {
		return vec3(1.0, 0.42, 0.10);   // 1453: ateş turuncusu
	}
	if (id == 4) {
		return vec3(0.30, 0.85, 0.80);  // kalyon: deniz yeşili
	}
	if (id == 5) {
		return vec3(1.0, 0.72, 0.30);   // 1970'ler: kehribar
	}
	if (id == 6) {
		return vec3(0.35, 0.85, 1.0);   // modern: camgöbeği
	}
	return vec3(0.80, 0.88, 1.0);       // roket: beyaz-mavi
}

// Pencere ızgarası: 0..1 yanan pencere maskesi (bina içi maskesini çağıran uygular)
float win_grid(vec2 p, vec2 freq, float seed, float t) {
	vec2 g = p * freq;
	vec2 id = floor(g);
	vec2 f = fract(g) - 0.5;
	float inside = step(abs(f.x), 0.26) * step(abs(f.y), 0.24);
	float on = step(hash21(id + seed), 0.45);
	float tw = 0.85 + 0.15 * sin(t * 0.7 + hash21(id) * 30.0);
	return inside * on * tw;
}

// =============================================================================
// Çağ siluetleri. p: hücre yerel uzayı, x in [-0.5, 0.5], y=0 tabandır, yukarı pozitif.
// d: işaretli mesafe (negatif = içeride), lit: içeride parlayan alan (pencere/ateş/alev)
// =============================================================================
void era_shape(int id, vec2 p, float t, out float d, out float lit) {
	d = 1.0;
	lit = 0.0;
	if (id == 0) {
		// Mısır: üç piramit + dikilitaş
		d = sd_tri(p - vec2(-0.20, 0.0), 0.22, 0.22);
		d = min(d, sd_tri(p - vec2(0.16, 0.0), 0.30, 0.30));
		d = min(d, sd_tri(p - vec2(0.40, 0.0), 0.08, 0.08));
		d = min(d, sd_box(p - vec2(-0.43, 0.09), vec2(0.012, 0.09)));
		d = min(d, sd_tri(p - vec2(-0.43, 0.18), 0.012, 0.03));
	} else if (id == 1) {
		// Roma: su kemeri + tapınak alınlığı
		float c = clamp(floor(p.x / 0.28 + 0.5), -1.0, 1.0);
		vec2 pr = vec2(p.x - c * 0.28, p.y);
		float wall = sd_box(p - vec2(0.0, 0.13), vec2(0.43, 0.13));
		float op = min(sd_box(pr - vec2(0.0, 0.07), vec2(0.075, 0.07)), sd_circle(pr - vec2(0.0, 0.14), 0.075));
		d = max(wall, -op);
		d = min(d, sd_box(p - vec2(0.0, 0.29), vec2(0.20, 0.03)));
		d = min(d, sd_tri(p - vec2(0.0, 0.32), 0.22, 0.09));
	} else if (id == 2) {
		// Konstantiniyye: ana kubbe, yarım kubbeler, minareler
		float ax = abs(p.x);
		float body = sd_box(p - vec2(0.0, 0.10), vec2(0.30, 0.10));
		float dome = max(sd_circle(p - vec2(0.0, 0.20), 0.19), -(p.y - 0.20));
		float semi = max(sd_circle(vec2(ax - 0.27, p.y - 0.20), 0.10), -(p.y - 0.20));
		float mina = sd_box(vec2(ax - 0.43, p.y - 0.25), vec2(0.014, 0.25));
		mina = min(mina, sd_box(vec2(ax - 0.43, p.y - 0.36), vec2(0.026, 0.007)));
		mina = min(mina, sd_tri(vec2(ax - 0.43, p.y - 0.49), 0.022, 0.09));
		float fin_ = sd_tri(p - vec2(0.0, 0.38), 0.012, 0.06);
		d = min(min(body, dome), min(semi, min(mina, fin_)));
		float lw = step(abs(fract(p.x * 11.0) - 0.5), 0.2) * step(abs(p.y - 0.09), 0.04);
		lit = lw * step(body, -0.01) * 0.75;
	} else if (id == 3) {
		// 1453: Theodosius surları, kuleler, bayrak, gedikte yangın
		float wall = sd_box(p - vec2(0.0, 0.10), vec2(0.48, 0.10));
		float px = (fract(p.x * 9.0) - 0.5) / 9.0;
		float mer = sd_box(vec2(px, p.y - 0.225), vec2(0.03, 0.025));
		mer = max(mer, abs(p.x) - 0.47);
		float tower = sd_box(vec2(abs(p.x) - 0.30, p.y - 0.19), vec2(0.07, 0.19));
		float tcap = sd_box(vec2(abs(p.x) - 0.30, p.y - 0.385), vec2(0.085, 0.02));
		float pole = sd_box(p - vec2(-0.30, 0.47), vec2(0.004, 0.07));
		vec2 fp = p - vec2(-0.258, 0.50);
		fp.y += 0.012 * sin(fp.x * 60.0 - t * 5.0);
		float flag = sd_box(fp, vec2(0.04, 0.02));
		d = min(min(wall, mer), min(min(tower, tcap), min(pole, flag)));
		float breach = sd_box(p - vec2(0.0, 0.07), vec2(0.055, 0.06));
		float fl = 0.7 + 0.3 * sin(t * 9.0 + p.x * 40.0) * sin(t * 5.3);
		lit = step(breach, 0.0) * fl;
	} else if (id == 4) {
		// Osmanlı kalyonu: gövde, kaleler, direkler, şişkin yelkenler, hafif sallanma
		vec2 pg = rot2(0.04 * sin(t * 0.6)) * (p - vec2(0.0, 0.15)) + vec2(0.0, 0.15);
		float hull = max(sd_circle(pg - vec2(0.0, 0.34), 0.36), pg.y - 0.20);
		float castle = sd_box(pg - vec2(0.24, 0.235), vec2(0.09, 0.04));
		float m1 = sd_box(pg - vec2(-0.12, 0.40), vec2(0.007, 0.20));
		float m2 = sd_box(pg - vec2(0.06, 0.43), vec2(0.007, 0.23));
		vec2 s1 = pg - vec2(-0.12, 0.38);
		s1.x += 0.025 * sin(s1.y * 18.0 + t * 0.8);
		float sail1 = sd_box(s1, vec2(0.085, 0.09));
		vec2 s1b = pg - vec2(-0.12, 0.54);
		s1b.x += 0.02 * sin(s1b.y * 20.0 + t * 0.9);
		float sail1b = sd_box(s1b, vec2(0.06, 0.045));
		vec2 s2 = pg - vec2(0.06, 0.41);
		s2.x += 0.025 * sin(s2.y * 18.0 + t * 0.7 + 1.0);
		float sail2 = sd_box(s2, vec2(0.085, 0.10));
		vec2 s2b = pg - vec2(0.06, 0.58);
		s2b.x += 0.02 * sin(s2b.y * 20.0 + t * 0.8);
		float sail2b = sd_box(s2b, vec2(0.06, 0.05));
		d = min(min(hull, castle), min(min(m1, m2), min(min(sail1, sail1b), min(sail2, sail2b))));
		lit = step(sd_circle(pg - vec2(0.26, 0.236), 0.014), 0.0);
	} else if (id == 5) {
		// 1970'ler İstanbul apartmanı + TRT TV anteni + balkonlar + yanıp sönen kırmızı lamba
		float b1 = sd_box(p - vec2(-0.14, 0.20), vec2(0.15, 0.20));
		float b2 = sd_box(p - vec2(0.20, 0.13), vec2(0.14, 0.13));
		float tank = sd_box(p - vec2(-0.20, 0.425), vec2(0.04, 0.025));
		float pole = sd_box(p - vec2(-0.08, 0.50), vec2(0.004, 0.10));
		float bar1 = sd_box(p - vec2(-0.08, 0.53), vec2(0.045, 0.003));
		float bar2 = sd_box(p - vec2(-0.08, 0.565), vec2(0.035, 0.003));
		float bar3 = sd_box(p - vec2(-0.08, 0.60), vec2(0.025, 0.003));
		float led = sd_circle(p - vec2(-0.08, 0.605), 0.009);
		float by = (fract(p.y * 9.0) - 0.5) / 9.0;
		float bal = max(sd_box(vec2(p.x + 0.14, by), vec2(0.17, 0.004)), abs(p.y - 0.20) - 0.19);
		float body = min(b1, b2);
		d = min(min(body, tank), min(min(pole, bar1), min(min(bar2, bar3), min(led, bal))));
		lit = win_grid(p, vec2(15.0, 17.0), 1.0, t) * step(body, -0.014);
		lit = max(lit, step(0.0, sin(t * 3.0)) * step(led, 0.0));
	} else if (id == 6) {
		// Modern siluet: değişken yükseklikte kuleler, gözlem güvertesi, gökdelen çubuğu
		float ci = clamp(floor((p.x + 0.5) * 6.0), 0.0, 5.0);
		float cx = (ci + 0.5) / 6.0 - 0.5;
		float hh = 0.14 + 0.30 * hash11(ci * 7.31 + 3.0);
		float tw = sd_box(vec2(p.x - cx, p.y - hh), vec2(0.072, hh));
		float needle = sd_box(vec2(p.x + 0.0833, p.y - 0.52), vec2(0.004, 0.10));
		float deck = sd_box(vec2(p.x + 0.0833, p.y - 0.46), vec2(0.032, 0.012));
		d = min(tw, min(needle, deck));
		lit = win_grid(vec2(p.x - cx, p.y), vec2(18.0, 20.0), 2.0 + ci, t) * step(tw, -0.012);
	} else {
		// Roket: gövde, burun, kanatçıklar, fırlatma kulesi, alev
		float body = sd_box(p - vec2(0.0, 0.26), vec2(0.045, 0.16));
		float nose = sd_tri(p - vec2(0.0, 0.42), 0.045, 0.12);
		float finr = sd_box(vec2(abs(p.x) - 0.065, p.y - 0.14), vec2(0.018, 0.06));
		float nozzle = sd_box(p - vec2(0.0, 0.08), vec2(0.03, 0.02));
		float g = sd_box(p - vec2(-0.16, 0.25), vec2(0.03, 0.25));
		float hole = sd_box(vec2(p.x + 0.16, (fract(p.y * 14.0) - 0.5) / 14.0), vec2(0.018, 0.02));
		g = max(g, -hole);
		float arm = sd_box(p - vec2(-0.09, 0.33), vec2(0.06, 0.006));
		float flame = sd_tri(vec2(p.x, -(p.y - 0.06)), 0.04 + 0.01 * sin(t * 30.0), 0.12 + 0.03 * sin(t * 23.0));
		d = min(min(body, nose), min(min(finr, nozzle), min(min(g, arm), flame)));
		float port = sd_circle(p - vec2(0.0, 0.30), 0.016);
		lit = max(step(flame, 0.0), step(port, 0.0));
	}
}

// =============================================================================
// Katman: gökyüzü (+ saat yüzü, aurora, yıldızlar)
// =============================================================================
vec3 sky_layer(vec2 Ls, float t, vec3 sky_h) {
	float h = Ls.y;
	vec3 c = mix(sky_h, sky_mid.rgb, smoothstep(0.0, 0.32, h));
	c = mix(c, sky_top.rgb, smoothstep(0.2, 0.95, h));
	// ufkun altı: boşluğa doğru kararır
	c = mix(c, mix(sky_h, void_deep.rgb, 0.65), 1.0 - smoothstep(-0.45, 0.0, h));
	c += sky_h * exp(-abs(h) * 7.0) * 0.45;

	// aurora şeridi
	float ab = 0.42 + 0.08 * sin(Ls.x * 2.3 + t * 0.05) + 0.03 * sin(Ls.x * 6.0 - t * 0.1);
	float ad = (h - ab) * 9.0;
	float aur = exp(-ad * ad);
	vec3 ac = mix(river_color.rgb, sky_h, 0.5 + 0.5 * sin(Ls.x * 1.7 + t * 0.04));
	c += ac * aur * 0.22 * (0.6 + 0.4 * sin(Ls.x * 13.0 + t * 0.3));

	// yıldızlar
	float sm = smoothstep(0.02, 0.35, h);
	vec2 g = Ls * 48.0;
	vec2 sid = floor(g);
	vec2 sf = fract(g) - 0.5;
	float sh = hash21(sid);
	vec2 so = (vec2(hash21(sid + 7.7), hash21(sid + 3.3)) - 0.5) * 0.6;
	float sdist = length(sf - so);
	float star = step(0.965, sh) * (1.0 - smoothstep(0.0, 0.14, sdist)) * (0.55 + 0.45 * sin(t * (1.0 + sh * 3.0) + sh * 80.0));
	c += vec3(0.9, 0.92, 1.0) * star * sm;

	// devasa saat yüzü (zamanın ay'ı)
	vec2 ck = Ls - vec2(0.55, 0.38);
	float r = length(ck);
	float R = 0.26;
	float disc = 1.0 - smoothstep(R - 0.004, R, r);
	float ring = 1.0 - smoothstep(0.0, 0.006, abs(r - R));
	float a = atan(ck.y, ck.x);
	float ta = abs(fract(a * 12.0 / TAU) - 0.5) * (TAU / 12.0) * r;
	float tick = (1.0 - smoothstep(0.002, 0.005, ta)) * step(R * 0.84, r) * step(r, R * 0.96);
	float am = -t * 0.010;
	float ah = -t * 0.0008;
	float hand_m = 1.0 - smoothstep(0.0, 0.005, sd_seg(ck, vec2(0.0), vec2(sin(am), cos(am)) * R * 0.82));
	float hand_h = 1.0 - smoothstep(0.0, 0.007, sd_seg(ck, vec2(0.0), vec2(sin(ah), cos(ah)) * R * 0.55));
	vec3 clk = mix(sky_h, vec3(1.0, 0.85, 0.6), 0.5);
	c += clk * (disc * 0.05 + ring * 0.35 + tick * 0.40 + (hand_m + hand_h) * 0.45);
	return c;
}

// =============================================================================
// Katman: Zaman nehri (gerçek perspektifli zemin düzlemi, ışıklı şerit + minik tarihler)
// =============================================================================
vec3 river_layer(vec3 col, vec2 qs, vec3 ro, float t) {
	vec3 dir = vec3(qs - ro.xy, -ro.z);
	if (dir.y > -0.01) {
		return col;
	}
	float tt = (-river_depth - ro.y) / dir.y;
	vec3 g = ro + dir * tt;
	float gz = -g.z;
	float gx = g.x;
	float zf = gz + t * 0.45;                       // nehir bize doğru akar
	float xc = 1.1 * sin(zf * 0.22 + 1.3) + 0.5 * sin(zf * 0.53);
	float dist = abs(gx - xc);
	float w = 0.55;
	float body = 1.0 - smoothstep(w * 0.25, w, dist);
	float glow = exp(-dist * 1.2);
	float flow = 0.5 + 0.5 * sin(zf * 2.6 + dist * 3.0);
	float fog = exp(-gz * 0.09);
	vec3 rc = river_color.rgb;
	vec3 rv = rc * (0.25 + 0.75 * flow) * body * 1.2 + rc * glow * 0.18;

	// tarih işaretleri + etiketler
	float zk = zf * 0.8;
	float k = floor(zk);
	float tz = fract(zk);
	float tick = (1.0 - smoothstep(0.0, 0.05, abs(tz - 0.5))) * step(dist, w * 1.25);
	rv += vec3(1.0) * tick * 0.9;
	float side = mod(k, 2.0) * 2.0 - 1.0;
	float u = (gx - xc - side * w * 1.7) / 0.5 + 0.5;
	float v = (tz - 0.5) / 0.32 + 0.5;
	if (u > 0.0 && u < 1.0 && v > 0.0 && v < 1.0) {
		float ci = floor(u * 4.0);
		float cu = fract(u * 4.0);
		float row = floor(v * 5.0);
		float rv_ = fract(v * 5.0);
		float on = step(0.45, hash21(vec2(k * 3.0 + ci, row)));
		on *= step(0.15, cu) * step(cu, 0.85) * step(0.15, rv_) * step(rv_, 0.85);
		rv += mix(rc, vec3(1.0), 0.6) * on * 1.1;
	}
	float edge_fade = smoothstep(0.01, 0.12, -dir.y);
	return col + rv * fog * edge_fade;
}

// =============================================================================
// Katman: uzak, özdeş Zaman Bürosu binaları (yüzen, pencereleri yanan)
// =============================================================================
vec3 bureau_layer(vec3 col, vec2 L, vec3 haze_col, float t) {
	float W = 0.9;
	float aa = max((fwidth(L.x) + fwidth(L.y)) / W, 0.0001);
	vec2 pp = vec2(L.x / W + t * 0.004, (L.y - 0.10) / W);
	float cid = floor(pp.x + 0.5);
	float h = hash11(cid * 5.7 + 1.3);
	if (h < 0.5) {
		return col;
	}
	vec2 p = vec2(pp.x - cid, pp.y);
	p.x -= (hash11(cid * 2.3 + 9.0) - 0.5) * 0.3;
	p.y -= 0.12 + 0.35 * hash11(cid * 2.9 + 7.0) + 0.02 * sin(t * 0.3 + cid * 2.0);
	float main_b = sd_box(p, vec2(0.15, 0.10));
	float tier = sd_box(p - vec2(0.0, 0.15), vec2(0.09, 0.05));
	float roof = sd_tri(p - vec2(0.0, 0.20), 0.10, 0.07);
	float rock = sd_tri(vec2(p.x, -p.y - 0.10), 0.14, 0.14);
	float d = min(min(main_b, tier), min(roof, rock));
	float mask = 1.0 - smoothstep(-aa, aa, d);
	if (mask < 0.003) {
		return col;
	}
	float lit = win_grid(p, vec2(12.0, 11.0), cid, t) * step(main_b, -0.01);
	lit = max(lit, step(length(p - vec2(0.0, 0.15)), 0.03));
	vec3 s = silhouette_color.rgb * 1.2 + river_color.rgb * 0.12;
	s = mix(s, window_light.rgb * 1.4, clamp(lit, 0.0, 1.0));
	s = mix(s, haze_col, 0.5);
	return mix(col, s, mask);
}

// =============================================================================
// Katman: çağ şeridi (tarih nehri; hücre başına bir çağ, sırayla, soldan sağa tekrar)
// =============================================================================
vec3 era_strip(vec3 col, vec2 L, float W, float base, float scroll, float id_off, float haze_amt, vec3 haze_col, float t, bool allow_focus) {
	float aa = max((fwidth(L.x) + fwidth(L.y)) / W * 0.75, 0.0001);
	vec2 pp = vec2(L.x / W + scroll, (L.y - base) / W);
	float cid = floor(pp.x + 0.5);
	vec2 p = vec2(pp.x - cid, pp.y);
	float hh = hash11(cid + id_off * 3.1);
	p.y -= 0.05 * sin(t * 0.35 + cid * 1.9 + hh * 6.0);   // yüzen adalar hafifçe süzülür
	int id = int(mod(cid + id_off, 8.0));
	float d;
	float lit;
	era_shape(id, p, t, d, lit);
	float rock = sd_tri(vec2(p.x, -p.y), 0.44, 0.30) + 0.012 * sin(p.x * 41.0 + cid * 2.0) + 0.010 * sin(p.x * 17.0 - cid);
	float dm = min(d, rock);
	float mask = 1.0 - smoothstep(-aa, aa, dm);

	vec3 ec = era_color(id);
	float foc = 0.0;
	if (allow_focus && id == focus_era) {
		foc = era_focus;
	}
	if (foc > 0.001) {
		float halo = exp(-max(dm, 0.0) * 6.0) * foc;
		float aura = exp(-length(p - vec2(0.0, 0.2)) * 2.5) * (1.0 - smoothstep(0.3, 0.5, abs(p.x))) * foc;
		col += ec * (halo * 0.5 * (1.0 - mask) + aura * 0.22);
	}
	if (mask > 0.002) {
		vec3 sil = silhouette_color.rgb + river_color.rgb * 0.30 * (1.0 - smoothstep(-0.35, 0.30, p.y));
		float rim = 1.0 - smoothstep(0.0, 0.04, -dm);
		sil += sky_horizon.rgb * rim * 0.5;
		sil = mix(sil, ec * 1.1, foc * 0.55 * (0.5 + 0.5 * rim));
		vec3 wc = window_light.rgb;
		if (id == 3) {
			wc = vec3(1.0, 0.45, 0.12);
		} else if (id >= 6) {
			wc = river_color.rgb * 1.2 + vec3(0.2);
		}
		sil = mix(sil, wc * 1.6, clamp(lit, 0.0, 1.0));
		sil = mix(sil, haze_col, haze_amt);
		col = mix(col, sil, mask);
	}
	return col;
}

// =============================================================================
// Katman: dev dişliler
// =============================================================================
float gear_sdf(vec2 p, float R, float n, float rot) {
	float r = length(p);
	float a = atan(p.y, p.x) + rot;
	float tooth = clamp(sin(a * n) * 2.5, -1.0, 1.0);
	float outer = r - R * (0.95 + 0.055 * tooth);
	float ring = max(outer, -(r - 0.78 * R));
	float sp = r * abs(fract(a * 3.0 / PI + 0.5) - 0.5) * (PI / 3.0) - 0.045 * R;
	float spokes = max(sp, r - 0.80 * R);
	float hub = r - 0.16 * R;
	float d = min(ring, min(spokes, hub));
	return max(d, -(r - 0.06 * R));
}

vec3 shade_gear(vec3 col, float d, vec2 p, float R, float aa) {
	float mask = 1.0 - smoothstep(-aa, aa, d);
	if (mask < 0.003) {
		return col;
	}
	float band = 1.0 - smoothstep(0.0, 0.045, -d);
	float lt = clamp(dot(normalize(p + vec2(0.0001)), vec2(-0.55, 0.83)), 0.0, 1.0);
	vec3 base = brass_color.rgb * 0.13 + vec3(0.02, 0.015, 0.03);
	float eng = 1.0 - smoothstep(0.0, 0.012, abs(length(p) - 0.68 * R));
	vec3 g = base + brass_color.rgb * (band * (0.2 + 0.9 * lt) + eng * 0.10);
	g += sky_horizon.rgb * band * 0.12;
	return mix(col, g, mask);
}

vec3 gear_layer(vec3 col, vec2 L, float t) {
	float aa = max((fwidth(L.x) + fwidth(L.y)) * 0.9, 0.0001);
	// G1 + G2: birbirine geçmiş (karşıt yönde döner)
	vec2 c1 = vec2(-0.80, -0.42) + 0.015 * vec2(sin(t * 0.07), cos(t * 0.05));
	float R1 = 0.55;
	float n1 = 20.0;
	float r1 = t * 0.045;
	col = shade_gear(col, gear_sdf(L - c1, R1, n1, r1), L - c1, R1, aa);
	float th = 1.2;
	float R2 = 0.30;
	float n2 = 11.0;
	vec2 c2 = c1 + (R1 + R2) * 0.96 * vec2(cos(th), sin(th));
	float r2 = -n1 * (th + r1) / n2 - th - PI;
	col = shade_gear(col, gear_sdf(L - c2, R2, n2, r2), L - c2, R2, aa);
	// G3: sağ üstte bağımsız dev dişli
	vec2 c3 = vec2(0.85, 0.55) + 0.015 * vec2(cos(t * 0.06), sin(t * 0.08));
	float R3 = 0.42;
	col = shade_gear(col, gear_sdf(L - c3, R3, 16.0, -t * 0.04), L - c3, R3, aa);
	return col;
}

// =============================================================================
// Katman: süzülen takvim yaprakları
// =============================================================================
vec3 page_layer(vec3 col, vec2 L, float t) {
	float cs = 1.35;
	float aa = max((fwidth(L.x) + fwidth(L.y)) / cs, 0.0001);
	vec2 u = L / cs + vec2(t * 0.012, t * 0.025);
	vec2 id = floor(u);
	vec2 f = fract(u) - 0.5;
	float h = hash21(id + 4.2);
	if (h < 0.55) {
		return col;
	}
	vec2 off = (vec2(hash21(id + 1.7), hash21(id + 5.3)) - 0.5) * 0.4;
	f -= off;
	f = rot2(h * 12.0 + t * 0.25 * (h - 0.8) * 4.0) * f;
	float flip = cos(t * 0.5 + h * 40.0);
	f.x /= max(abs(flip), 0.25);
	float d = sd_box(f, vec2(0.085, 0.11));
	float mask = 1.0 - smoothstep(-aa, aa, d);
	if (mask < 0.003) {
		return col;
	}
	float lightness = 0.22 + 0.25 * (0.5 + 0.5 * flip);
	vec3 paper = vec3(0.95, 0.88, 0.72) * lightness + sky_horizon.rgb * 0.05;
	vec3 red = vec3(0.70, 0.12, 0.10) * lightness;
	vec3 pc = mix(paper, red, step(0.05, f.y));
	float lines = step(0.55, fract(f.y * 70.0)) * step(f.y, 0.0) * step(abs(f.x), 0.06) * step(-0.09, f.y);
	pc *= 1.0 - lines * 0.45;
	float digit = 1.0 - smoothstep(0.0, 0.006, abs(length(f - vec2(0.0, 0.02)) - 0.022) - 0.003);
	pc *= 1.0 - digit * 0.6 * step(f.y, 0.05);
	return mix(col, pc, mask * 0.96);
}

// =============================================================================
// Katman: kayan "tarih" meteorları (toplanan, additive)
// =============================================================================
vec3 streak_layer(vec2 L, float t) {
	vec3 acc = vec3(0.0);
	for (int i = 0; i < 2; i++) {
		float fi = float(i);
		float T = 5.5 + fi * 2.3;
		float ts = t / T + fi * 0.41;
		float k = floor(ts);
		float ph = fract(ts);
		float h = hash11(k * 1.7 + fi * 19.0);
		if (h > 0.4) {
			vec2 s0 = vec2(mix(-0.2, 1.0, hash11(k * 3.3 + fi)), 0.62);
			vec2 dv = normalize(vec2(-0.75 - 0.3 * h, -0.55));
			float len = 0.45;
			vec2 head = s0 + dv * ph * 1.9;
			vec2 pa = L - head;
			float along = clamp(dot(pa, -dv), 0.0, len);
			float dd = length(pa + dv * along);
			float tail = 1.0 - along / len;
			float fade = smoothstep(0.0, 0.1, ph) * (1.0 - smoothstep(0.8, 1.0, ph));
			float core = exp(-dd * dd * 9000.0);
			float glow = exp(-dd * dd * 350.0) * 0.25;
			acc += (core + glow) * tail * tail * fade * mix(vec3(1.0, 0.9, 0.7), river_color.rgb, 0.4);
		}
	}
	return acc;
}

// =============================================================================
void fragment() {
	vec2 q = v_q;
	vec3 ro = v_cam;
	ro.z = max(ro.z, 0.25);               // kamera camın arkasına geçmesin
	float pd = parallax_depth;
	float t = TIME * flow_speed;
	vec2 qs = q + vec2(0.0, horizon_lower);

	vec3 foc_col = era_color(focus_era);
	vec3 sky_h = mix(sky_horizon.rgb, foc_col * 1.1, era_focus * 0.30);
	vec3 haze = mix(sky_mid.rgb, sky_h, 0.55);

	// 1-2) gökyüzü + nehir
	vec3 col = sky_layer(layer_uv(qs, ro, 150.0 * pd), t, sky_h);
	col = river_layer(col, qs, ro, t);
	// 3) uzak Büro binaları
	col = bureau_layer(col, layer_uv(qs, ro, 45.0 * pd), haze, t);
	// 4) uzak çağ şeridi (sisli, odak almaz)
	col = era_strip(col, layer_uv(qs, ro, 18.0 * pd), 0.42, 0.02, t * 0.020, 3.0, 0.62, haze, t, false);
	// 5) ana çağ şeridi
	col = era_strip(col, layer_uv(qs, ro, 6.0 * pd), 0.72, -0.12, t * 0.035, 0.0, 0.12, haze, t, true);
	// 6) dişliler, 7) takvim yaprakları, 8) meteorlar
	col = gear_layer(col, layer_uv(qs, ro, 2.2 * pd), t);
	col = page_layer(col, layer_uv(qs, ro, 1.0 * pd), t);
	col += streak_layer(layer_uv(qs, ro, 0.35 * pd), t);

	// 9) cam
	float aspect = quad_size.x / quad_size.y;
	vec2 e = vec2(abs(q.x) / (0.5 * aspect), abs(q.y) / 0.5);
	float edge = max(e.x, e.y);
	float vig = smoothstep(0.6, 1.02, edge);

	float n1 = vnoise(q * vec2(5.0, 7.0) + 3.1);
	float n2 = vnoise(q * 21.0 + 11.7);
	float streaks = smoothstep(0.55, 0.95, vnoise(vec2(q.x * 38.0, q.y * 1.6 + 2.0)));
	float dirt = n1 * 0.6 + n2 * 0.4;
	dirt = (dirt * dirt * dirt_amount) + streaks * 0.5 * dirt_amount * (0.3 + vig);
	float cond = vig * (0.4 + 0.6 * n1);
	col = mix(col, glass_tint.rgb * 0.5 + col * 0.3, clamp(dirt * 0.3 + cond * 0.22, 0.0, 0.6));

	float dust = step(0.997, hash21(floor(q * 220.0)));
	col += glass_tint.rgb * dust * 0.12;

	float cosv = ro.z / length(ro);
	float fres = 0.04 + 0.75 * pow(1.0 - cosv, 3.0);
	vec2 rc = q - (reflect_pos - ro.xy * 0.7);
	vec2 rce = rc * vec2(1.3, 2.2);
	float lamp = exp(-dot(rce, rce) * 18.0);
	float band = 1.0 - smoothstep(0.0, 0.10, abs(q.x * 0.8 + q.y + 0.1 - ro.x * 0.4));
	col += glass_tint.rgb * (lamp * 0.6 + band * 0.10) * reflection_strength * (0.5 + fres * 2.0);

	col *= 1.0 - vig * vignette_strength;
	ALBEDO = max(col, vec3(0.0));
}
