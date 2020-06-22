shader_type canvas_item;

const vec4 white_col = vec4(203.0/255.0, 219.0/255.0f, 252.0/255.0, 1.0);
const vec4 black_col = vec4(34.0/255.0, 32.0/255.0f, 52.0/255.0, 1.0);

void fragment() {
	vec4 screen_col = texture(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	if (screen_col.r > 0.1)
   		COLOR.xyz = white_col.xyz;
	else
		COLOR.xyz = black_col.xyz;
}