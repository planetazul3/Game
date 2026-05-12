shader_type spatial;
render_mode unshaded, blend_mix, depth_test_disabled;

uniform sampler2D visibility_texture : hint_default_black;
uniform sampler2D exploration_texture : hint_default_black;
uniform vec4 fog_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float explored_dimming : hint_range(0.0, 1.0) = 0.5;
uniform vec2 map_size = vec2(100.0, 100.0);
uniform vec2 map_offset = vec2(-50.0, -50.0);

void fragment() {
	// Map world position to texture coordinates
	vec2 uv = (vec2(VERTEX.x, VERTEX.z) - map_offset) / map_size;
	
	float visibility = texture(visibility_texture, uv).r;
	float explored = texture(exploration_texture, uv).r;
	
	vec4 final_color = fog_color;
	
	if (visibility > 0.1) {
		// Visible area: Fully transparent
		discard;
	} else if (explored > 0.1) {
		// Explored area: Dimmed fog
		ALBEDO = fog_color.rgb;
		ALPHA = fog_color.a * explored_dimming;
	} else {
		// Unexplored area: Full fog
		ALBEDO = fog_color.rgb;
		ALPHA = fog_color.a;
	}
}
