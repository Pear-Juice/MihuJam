shader_type canvas_item;

uniform sampler2D noise;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(noise, UV) * vec4(1,0,0,1);
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
