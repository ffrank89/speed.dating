shader_type canvas_item;

uniform float static_amount : hint_range(0.0, 1.0) = 0.1;
uniform float scan_line_intensity : hint_range(0.0, 1.0) = 0.2;

// Random function for noise generation
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // Get the original image color
    vec4 original_color = texture(TEXTURE, UV);

    // Generate random noise
    float noise = rand(UV + vec2(TIME * 0.01, TIME * 0.01));

    // Apply scan lines
    float scan_line = sin(UV.y * 500.0) * 0.5 + 0.5;
    scan_line = mix(1.0, scan_line, scan_line_intensity);

    // Mix noise with original color
    vec4 final_color = original_color;
    final_color.rgb = mix(final_color.rgb, vec3(noise), static_amount);
    final_color.rgb *= scan_line;

    COLOR = final_color;
}
//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
