shader_type canvas_item;

uniform vec4 new_color: source_color = vec4(1.0);

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec4 initial_color = color; // Store initial green to then adjust the new color brightness accordingly
    // Using the range of all pure greens (red and blue equal to 0) so simulate having colors with different brightness
    if (color.b > .01 && color.r == 0. && color.g == 0.) {
        color = new_color;
        // Correct color for brightness
        color.rgb = color.rgb * initial_color.g;
        color.a = initial_color.a;
    }
    COLOR = color;
}