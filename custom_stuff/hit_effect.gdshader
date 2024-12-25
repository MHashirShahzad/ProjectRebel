shader_type spatial;

uniform bool active = true;
uniform sampler2D tex : source_color;


void fragment() {
	vec4 previous_color = texture(tex, UV);
	vec4 white_color = vec4(1.0, 1.0, 1.0, previous_color.a);
	vec4 new_color = previous_color;
	if (active == true) {
		new_color = white_color;
	}
	ALBEDO = vec3(new_color.r, new_color.b, new_color.g);
	ALPHA = new_color.a;
}