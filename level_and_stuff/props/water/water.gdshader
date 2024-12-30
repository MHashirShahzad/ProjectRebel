shader_type spatial;

uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform sampler2D wave;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform vec2 wave_direction = vec2(2.0, 0.0);
uniform vec2 wave_direction2 = vec2(0.0, 1.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;

uniform vec4 color_deep : source_color;
uniform vec4 color_shallow : source_color;
uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;

uniform float edge_scale = 0.1;
uniform float near = 1.0;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;

varying vec3 world_pos;

float linearize_depth(float z) {
    return near * far / (far - (z * (far - near) + near));
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    float height = texture(wave, world_pos.xz / noise_scale + TIME * time_scale).r;
    VERTEX.y += height * height_scale;
}

void fragment() {
    // Linearize depth
    float z_linear = linearize_depth(FRAGCOORD.z);

    // Depth blending
    float depth_blend = exp(-abs(z_linear - depth_offset) * beers_law);
    float depth_blend_power = clamp(depth_blend * depth_blend, 0.0, 1.0);
    vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend_power);

    // Screen-space edge detection
    float depth_dx = dFdx(FRAGCOORD.z);
    float depth_dy = dFdy(FRAGCOORD.z);
    float edge_strength = length(vec2(depth_dx, depth_dy));
    vec3 edge_effect = mix(vec3(0.0), edge_color, smoothstep(0.0, edge_scale, edge_strength));

    // Normal map blending
    vec2 time_offset1 = wave_direction * time_scale * TIME;
    vec2 time_offset2 = wave_direction2 * time_scale * TIME;
    vec3 normal1 = texture(texture_normal, (world_pos.xz + time_offset1) / noise_scale).rgb;
    vec3 normal2 = texture(texture_normal2, (world_pos.xz + time_offset2) / noise_scale).rgb;
    vec3 blended_normal = mix(normal1, normal2, 0.5);

    // Fresnel effect
    float fresnel_factor = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 5.0);
    vec3 surface_color = mix(albedo, albedo2, fresnel_factor);

    // Combine effects
    vec3 final_color = surface_color * depth_color + edge_effect;

    ALBEDO = clamp(final_color, vec3(0.0), vec3(1.0));
    METALLIC = metallic;
    ROUGHNESS = roughness;
    NORMAL_MAP = blended_normal;
}
