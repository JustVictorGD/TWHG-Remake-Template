shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D gradient_texture;
uniform float overlay_opacity = 0.5;

void fragment() {
	vec4 gradient = texture(gradient_texture, vec2(SCREEN_UV));
	vec4 mixed = mix(COLOR, gradient, vec4(overlay_opacity));
	COLOR.rgb = vec3(mixed.xyz);
}
