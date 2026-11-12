// İstanbul v2: martı ve güvercin sürüleri (MultiMesh). Örnek dönüşümü = sürü merkezi (ölçek 1 ya da kuş boyu);
// özel veri: x = yarıçap, y = yükseklik (merkezden), z = açısal hız (rad/sn, işaretli), w = evre.
shader_type spatial;
render_mode cull_disabled, unshaded;

varying vec3 v_col;

void vertex() {
	vec4 cd = INSTANCE_CUSTOM;
	float ang = TIME * cd.z + cd.w;
	float sg = cd.z >= 0.0 ? 1.0 : -1.0;
	vec3 p = vec3(cos(ang) * cd.x, cd.y + sin(ang * 1.7 + cd.w) * 1.5, sin(ang) * cd.x);
	vec3 d = vec3(-sin(ang), 0.0, cos(ang)) * sg;
	vec3 v = VERTEX;
	float flap = sin(TIME * 6.5 + cd.w * 5.0) * (0.5 + 0.5 * sin(TIME * 0.5 + cd.w * 3.0));
	v.y += flap * abs(v.x) * 0.55;
	// başı hareket yönüne çevir (−z → d), hafif yatış
	float yaw = atan(-d.x, -d.z);
	float roll = -sg * 0.28;
	float cr = cos(roll);
	float sr = sin(roll);
	v.xy = vec2(v.x * cr - v.y * sr, v.x * sr + v.y * cr);
	float cy = cos(yaw);
	float sy = sin(yaw);
	v.xz = vec2(v.x * cy + v.z * sy, -v.x * sy + v.z * cy);
	VERTEX = v + p;
	NORMAL = vec3(0.0, 1.0, 0.0);
	v_col = COLOR.rgb;
}

void fragment() {
	ALBEDO = v_col;
	ROUGHNESS = 1.0;
}
