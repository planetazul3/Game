shader_type spatial;
render_mode unshaded, blend_mix, depth_test_disabled;

uniform sampler2D visibility_texture : hint_default_black;
uniform sampler2D exploration_texture : hint_default_black;
uniform vec4 fog_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float explored_dimming : hint_range(0.0, 1.0) = 0.5;
uniform vec2 map_size = vec2(100.0, 100.0);
uniform vec2 map_offset = vec2(-50.0, -50.0);

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Map world position to texture coordinates
	vec2 uv = (world_pos.xz - map_offset) / map_size;
	
	float visibility = texture(visibility_texture, uv).r;
	float explored = texture(exploration_texture, uv).r;
	
	// Visibility: 1.0 = Clear, 0.0 = Fog
	// Explored: 1.0 = Seen before, 0.0 = Shroud
	
	vec4 col = fog_color;
	
	if (visibility > 0.01) {
		// Fully visible area
		float alpha = clamp(1.0 - visibility, 0.0, 1.0);
		ALBEDO = col.rgb;
		ALPHA = col.a * alpha;
	} else if (explored > 0.01) {
		// Explored but not visible (Grey fog)
		ALBEDO = col.rgb;
		ALPHA = col.a * explored_dimming;
	} else {
		// Unexplored (Shroud)
		ALBEDO = col.rgb;
		ALPHA = col.a;
	}
}
