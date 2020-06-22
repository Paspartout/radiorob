shader_type canvas_item;

void fragment() {
	vec4 screen_col = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 tex_col = texture(TEXTURE, UV);
	vec4 col = tex_col - screen_col;
	// TODO: Proper pallete mapping
	// col.rgb = vec3(34.0f/255.0f, 32.0f/255.0f, 52.0f/255.0f);
	col.a = tex_col.a;
    COLOR = col;
}