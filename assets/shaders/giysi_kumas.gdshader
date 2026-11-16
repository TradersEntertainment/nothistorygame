shader_type spatial;
// GİYSİ KUMAŞI (scripts/npc/kumas.gd; açıklama giysi_kumas.gdshaderinc). Işık modeli CharKit.vc_mat ile aynı.
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert_wrap, specular_schlick_ggx, shadows_disabled;
#include "res://assets/shaders/giysi_kumas.gdshaderinc"

void vertex() {
	// CharKit.vc_mat: köşe rengi sRGB
	COLOR.rgb = mix(pow((COLOR.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)), COLOR.rgb * (1.0 / 12.92), lessThan(COLOR.rgb, vec3(0.04045)));
	VERTEX = kumas_buk(VERTEX, UV, TIME);
}

void fragment() {
	ALBEDO = COLOR.rgb;
	ROUGHNESS = 0.78;
	SPECULAR = 0.25;
	METALLIC = 0.0;
	RIM = 0.22;
	RIM_TINT = 0.5;
}
