shader_type canvas_item;

uniform float outerRadius : hint_range(0.0, 5.0) = 1.0;
uniform float mainAlpha : hint_range(0.0, 1.0) = 1.0;
uniform vec4 vignetteColor: source_color;

void fragment() {
	float x = abs(UV.x-.5)*2.0;
	float y = abs(UV.y-.5)*2.0;
	float v = (sqrt((x*x)+(y*y))/outerRadius);
	COLOR = vec4(vignetteColor.rgb,v*mainAlpha);
}
