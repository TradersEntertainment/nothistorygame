shader_type spatial;
// GİYSİ KUMAŞI (scripts/npc/kumas.gd; açıklama giysi_kumas.gdshaderinc). Işık modeli CharKit.vc_mat ile aynı.
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert_wrap, specular_schlick_ggx, shadows_disabled;
#include "res://assets/shaders/giysi_kumas.gdshaderinc"

void vertex() {
	// Köşe rengi olduğu gibi: uyumluluk çizicisi vc_mat'ın sRGB dönüşümünü kendisi yapıyor (iki kez çevirince koyu çıkıyordu;
	// aynı köşe renginde ölçüldü: vc_mat 0,451/0,310/0,247, bu 0,451/0,314/0,251)
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
