shader_type canvas_item;

uniform float random_key = 123.45;
uniform float zoom = 12.0;
uniform float base_size = 0.07;
uniform float moving_size = 0.02;
uniform float frequency = 1.0;

uniform float alpha = 1.0;

mat2 rotation(float a) {
	float s = sin(a);
	float c = cos(a);
	return mat2(vec2(c, -s), vec2(s, c));
}

float star(vec2 uv, float flare, float strength) {
	float d = distance(uv, vec2(0.0));
	float m = strength / d;
	
	float cross_shape = max(0.0, 1.0 - abs(uv.x * uv.y * 1000.0));
	
	m += cross_shape * flare;
	
	vec2 uv_scaled_rotated = uv * rotation(3.1415 / 4.0);
	float cross_shape_rotated = max(0.0, 1.0 - abs(uv_scaled_rotated.x * uv_scaled_rotated.y * 500.0));
	
	m += cross_shape_rotated * flare * 0.5;
	
	return m;
}

float hash21(vec2 p) {
	p = fract(p * vec2(random_key * 1.34 + 45.1, random_key * 0.98 + 123.3));
	p += dot(p, p + random_key * 10.1234 + 123.2);
	
	return fract(p.x * p.y);
}

void fragment() {
	vec2 uv_scaled = (2.0 * UV - 1.0) * zoom;
	
	vec4 color = vec4(vec3(0.0), alpha);
	vec2 gv = fract(uv_scaled) - 0.5;
	vec2 id = floor(uv_scaled);
	
	for (int y = -1 ; y <= 1 ; y++) {
		for (int x = -1 ; x <= 1 ; x ++) {
			vec2 offs = vec2(float(x), float(y));
			float n = hash21(id + offs);
			float size = fract(n * random_key);
			
			float star = star(gv - offs - vec2(n, fract(n * random_key * 12.12)) + 0.5, smoothstep(0.9, 0.95, size), base_size + moving_size * sin(fract(n * random_key * 456.45) * 6.28 + TIME * frequency)) / 9.0;
			
			color += star * size;
		}
	}
	COLOR = vec4(color);
}