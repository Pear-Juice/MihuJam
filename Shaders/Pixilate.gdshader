shader_type canvas_item;

uniform int amount = 40;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment()
{
	vec2 grid_uv = round(SCREEN_UV * float(amount)) / float(amount);
	
	vec4 text = texture(TEXTURE, grid_uv);
	
	COLOR = textureLod(screen_texture, grid_uv, 0.0);
}