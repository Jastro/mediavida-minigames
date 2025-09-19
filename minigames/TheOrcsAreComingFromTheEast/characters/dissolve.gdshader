shader_type canvas_item;

uniform sampler2D noise;
uniform float percent;

void fragment() {
	vec4 noise_sample = (texture(noise, SCREEN_UV.xy)) * percent;

	if(noise_sample.x + noise_sample.y > 0.5) {
		COLOR = vec4(0,0,0,0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
