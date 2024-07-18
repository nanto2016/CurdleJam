shader_type canvas_item;

uniform vec2 direction = vec2(0.0, 1.0);

void fragment() {
	COLOR = texture(TEXTURE, UV + direction * TIME);
	COLOR.r *= 2.0;
	COLOR.g /= 1.25;
	COLOR.b /= 2.0;
}