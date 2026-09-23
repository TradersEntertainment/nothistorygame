// Ekran kenarlarında hafif karartma.
shader_type canvas_item;

uniform float strength = 0.38;

void fragment() {
	float d = length((UV - vec2(0.5)) * vec2(1.25, 1.0));
	COLOR = vec4(0.0, 0.0, 0.0, smoothstep(0.45, 0.95, d) * strength);
}
