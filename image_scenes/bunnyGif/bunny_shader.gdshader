shader_type canvas_item;
uniform sampler2D texture_albedo;
uniform float parallax_amount = 0.02;
void fragment() {
    vec2 offset = vec2(0.0, 0.0);
    offset.x = sin(TIME * 0.5) * parallax_amount;
    offset.y = cos(TIME * 0.3) * parallax_amount;
    COLOR = texture(texture_albedo, UV + offset);
}
//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
