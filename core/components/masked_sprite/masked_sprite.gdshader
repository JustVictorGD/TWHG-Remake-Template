shader_type canvas_item;

uniform float opacity = 1.0;

// Textures for the fill and outline layers
uniform sampler2D outline_texture;
uniform sampler2D fill_texture;

// Colors for the fill and outline layers
uniform vec4 outline_color : source_color;
uniform vec4 fill_color : source_color;

uniform vec2 outline_scale = vec2(1.0, 1.0);
uniform vec2 fill_scale = vec2(1.0, 1.0);

void fragment() {
	// Sample the textures at the current fragment's UV coordinates
	vec4 outline_tex = texture(outline_texture, (UV - vec2(0.5, 0.5)) / outline_scale + vec2(0.5, 0.5));
	vec4 fill_tex = texture(fill_texture, (UV - vec2(0.5, 0.5)) / fill_scale + vec2(0.5, 0.5));

	// Can't assign values to uniforms so I have to make copies of them.
	vec4 outline_modulated = outline_color;
	vec4 fill_modulated = fill_color;

	outline_modulated.a *= outline_tex.a * opacity;
	fill_modulated.a *= outline_tex.a * opacity;

	// Blend the colors using the fill texture's alpha as "power"
	float fill_power = fill_tex.a;
	vec4 combined_color = mix(outline_modulated, fill_modulated, fill_power);

	COLOR = combined_color;
}