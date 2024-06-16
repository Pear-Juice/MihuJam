shader_type spatial;

uniform sampler2D albedo;
uniform float metalic : hint_range(0.0, 1.0, 0.1) = 0;
uniform vec4 noise_color : source_color;
uniform float noise_alpha : hint_range(0.0, 1.0, 0.1) = 1;
uniform sampler2D noise;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	METALLIC = metalic;
	ALBEDO = texture(albedo, UV).rgb + (texture(noise, UV).x * noise_color * noise_alpha).rgb;
}

void light() {
	DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR;
}
