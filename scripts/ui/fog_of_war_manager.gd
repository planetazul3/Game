extends Node
# FogOfWarManager: Handles shader-based fog rendering

@export var map_size := Vector2(100, 100)
@export var resolution := 512

var visibility_viewport: SubViewport
var exploration_viewport: SubViewport
var visibility_texture_rect: TextureRect
var exploration_texture_rect: TextureRect

var vision_texture: GradientTexture2D

func _ready() -> void:
	# 1. Setup Vision Texture (Blurred Circle)
	vision_texture = GradientTexture2D.new()
	vision_texture.gradient = Gradient.new()
	vision_texture.gradient.offsets = [0.0, 0.8, 1.0]
	vision_texture.gradient.colors = [Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0)]
	vision_texture.fill = GradientTexture2D.FILL_RADIAL
	vision_texture.fill_from = Vector2(0.5, 0.5)
	vision_texture.width = 128
	vision_texture.height = 128

	# 2. Setup Viewports
	visibility_viewport = SubViewport.new()
	visibility_viewport.size = Vector2i(resolution, resolution)
	visibility_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	visibility_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	visibility_viewport.transparent_bg = true
	add_child(visibility_viewport)

	exploration_viewport = SubViewport.new()
	exploration_viewport.size = Vector2i(resolution, resolution)
	exploration_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	exploration_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	exploration_viewport.transparent_bg = true
	add_child(exploration_viewport)

	# 3. Create Fog Plane Mesh
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = map_size
	mesh_instance.mesh = plane_mesh
	mesh_instance.position.y = 5.0 
	add_child(mesh_instance)

	var fog_material = ShaderMaterial.new()
	fog_material.shader = load("res://shaders/fog_of_war.gdshader")
	var noise_tex = load("res://assets/textures/fog_noise.png")
	if noise_tex:
		fog_material.set_shader_parameter("noise_texture", noise_tex)
	
	fog_material.set_shader_parameter("visibility_texture", visibility_viewport.get_texture())
	fog_material.set_shader_parameter("exploration_texture", exploration_viewport.get_texture())
	fog_material.set_shader_parameter("map_size", map_size)
	fog_material.set_shader_parameter("map_offset", -map_size / 2.0)
	mesh_instance.material_override = fog_material

func update_vision(sources: Array[Node]) -> void:
	# 1. Clear real-time visibility (every update)
	for child in visibility_viewport.get_children():
		child.queue_free()
	
	# 2. Process each vision source
	for source in sources:
		if not is_instance_valid(source):
			continue
			
		var uv_pos = (Vector2(source.global_position.x, source.global_position.z) + map_size / 2.0) / map_size
		var screen_pos = uv_pos * float(resolution)
		
		# Base vision radius from unit definition or default
		var vision_radius = source.get("vision_range") if "vision_range" in source else 15.0
		var sprite_scale = Vector2.ONE * (vision_radius / 10.0) * (float(resolution) / 512.0)

		# Real-time visibility sprite
		var sprite_vis = Sprite2D.new()
		sprite_vis.texture = vision_texture
		sprite_vis.position = screen_pos
		sprite_vis.scale = sprite_scale
		visibility_viewport.add_child(sprite_vis)
		
		# Persistent exploration sprite (Never cleared from exploration_viewport)
		var sprite_exp = Sprite2D.new()
		sprite_exp.texture = vision_texture
		sprite_exp.position = screen_pos
		sprite_exp.scale = sprite_scale
		exploration_viewport.add_child(sprite_exp)
		
		# We only need to render it once into the persistent buffer
		# (SubViewport will render it this frame before it's freed)
		get_tree().create_timer(0.1).timeout.connect(sprite_exp.queue_free)
