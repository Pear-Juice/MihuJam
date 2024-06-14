shader_type spatial;

uniform sampler2D albedo_tex;
uniform vec4 color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = texture(albedo_tex, UV).rgb * color.rgb;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	ALPHA = 1.0;
}

void light() {
	// Called for every pixel for every light affecting the material.
}
