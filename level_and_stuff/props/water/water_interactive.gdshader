shader_type canvas_item;

uniform sampler2D sim_tex;
uniform sampler2D col_tex;

uniform float phase = 0.2;
uniform float attenuation = 0.999;
uniform float deltaUV = 3;

void fragment() {
	vec2 uv = vec2(UV.x, 1.0 - UV.y);

	float dv = 1.0 / 512.0; // screen size
	float du = 1.0 / 512.0;

	vec3 duv = vec3(du, dv, 0) * deltaUV;

	vec3 c = texture(sim_tex, UV).rgb;

	float p = (2.0 * c.r - c.g + phase * (
		texture(sim_tex, UV - duv.zy).r +
		texture(sim_tex, UV + duv.zy).r +
		texture(sim_tex, UV - duv.xz).r +
		texture(sim_tex, UV + duv.xz).r - 4.0 * c.r)) * attenuation;

	// collision
	vec2 col_uv = vec2(UV.x, 1.0 - UV.y);

	float col = texture(col_tex, col_uv).r;
	float prev_col = texture(sim_tex, UV).b;

	// idk collision do collision stuff
	if ( col > 0.0 && prev_col == 0.0){
		// if there is a new collision which wasnt there previously, raise the water
		p += col * 0.5;
	}

	if ( prev_col > 0.0 && col == 0.0){
		// if there was a prev collision which isnt now, lower the water
		p -= col * 0.5;
	}

	COLOR = vec4(p, c.r, col, 1);
}
