shader_type spatial;
// GİYSİ KUMAŞI dış hattı (CharKit._outline ile aynı: ışıksız, ön yüz ayıklanır, normal boyunca büyür, derinlik yazmaz);
// köşeler kumaşla aynı bükülür (giysi_kumas.gdshaderinc).
render_mode unshaded, cull_front, depth_draw_never;
#include "res://assets/shaders/giysi_kumas.gdshaderinc"

uniform vec4 renk : source_color = vec4(0.0784, 0.0941, 0.1294, 1.0);
uniform float buyume = 0.0084;

void vertex() {
	VERTEX = kumas_buk(VERTEX, UV, TIME) + NORMAL * buyume;
}

void fragment() {
	ALBEDO = renk.rgb;
}
