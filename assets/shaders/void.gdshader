// Zaman Bürosu penceresi: zamanın dışındaki hiçlik. Yavaşça dönen, mor-lacivert bir girdap.
shader_type spatial;
render_mode unshaded;

uniform vec4 color_a : source_color = vec4(0.10, 0.06, 0.22, 1.0);
uniform vec4 color_b : source_color = vec4(0.32, 0.20, 0.55, 1.0);
uniform vec4 color_c : source_color = vec4(0.55, 0.85, 0.95, 1.0);

void fragment() {
	vec2 p = UV - 0.5;
	float r = length(p);
	float a = atan(p.y, p.x);
	float swirl = sin(a * 5.0 + r * 18.0 - TIME * 0.8) * 0.5 + 0.5;
	float rings = sin(r * 40.0 - TIME * 1.5) * 0.5 + 0.5;
	vec3 col = mix(color_a.rgb, color_b.rgb, swirl);
	col = mix(col, color_c.rgb, smoothstep(0.35, 0.0, r) * rings * 0.6);
	ALBEDO = col;
}
