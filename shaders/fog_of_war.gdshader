shader_type spatial;
render_mode unshaded, blend_mix, depth_test_disabled;

uniform sampler2D visibility_texture : hint_default_black;
uniform sampler2D exploration_texture : hint_default_black;
uniform sampler2D noise_texture;
uniform vec4 shroud_color : source_color = vec4(0.02, 0.02, 0.05, 1.0);
uniform vec4 fog_color : source_color = vec4(0.1, 0.1, 0.15, 0.8);
uniform float explored_dimming : hint_range(0.0, 1.0) = 0.4;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.2;
uniform vec2 map_size = vec2(100.0, 100.0);
uniform vec2 map_offset = vec2(-50.0, -50.0);

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv = (world_pos.xz - map_offset) / map_size;
	
	float visibility = texture(visibility_texture, uv).r;
	float explored = texture(exploration_texture, uv).r;
	float noise = texture(noise_texture, uv + TIME * 0.01).r;
	
	vec4 col = shroud_color;
	float alpha = 1.0;
	
	if (visibility > 0.01) {
		// Visible area: fade out shroud
		alpha = clamp(1.0 - (visibility * 1.5), 0.0, 1.0);
		col = shroud_color;
	} else if (explored > 0.01) {
		// Explored: persistent fog
		col = fog_color;
		alpha = explored_dimming + (noise * noise_strength);
	} else {
		// Shroud: thick dark fog with noise
		col = shroud_color;
		alpha = 0.9 + (noise * noise_strength);
	}
	
	ALBEDO = col.rgb;
	ALPHA = alpha;
}
