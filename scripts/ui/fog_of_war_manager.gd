extends Node
# FogOfWarManager: Handles shader-based fog rendering

@export var map_size := Vector2(200, 200)
@export var resolution := 512

var visibility_viewport: SubViewport
var exploration_viewport: SubViewport
var fog_material: ShaderMaterial

func _ready() -> void:
	_setup_viewports()
	_setup_fog_mesh()

func _setup_viewports() -> void:
	# Visibility Viewport (Clear every frame/update)
	visibility_viewport = SubViewport.new()
	visibility_viewport.size = Vector2i(resolution, resolution)
	visibility_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	visibility_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	visibility_viewport.transparent_bg = true
	add_child(visibility_viewport)
	
	# Exploration Viewport (Persistent)
	exploration_viewport = SubViewport.new()
	exploration_viewport.size = Vector2i(resolution, resolution)
	exploration_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	exploration_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	exploration_viewport.transparent_bg = true
	add_child(exploration_viewport)

func _setup_fog_mesh() -> void:
	# Create a large plane covering the world for the fog shader
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = map_size
	mesh_instance.mesh = plane_mesh
	mesh_instance.transform.origin.y = 5.0 # Just above ground
	
	fog_material = ShaderMaterial.new()
	fog_material.shader = load("res://shaders/fog_of_war.gdshader")
	fog_material.set_shader_parameter("map_size", map_size)
	fog_material.set_shader_parameter("map_offset", -map_size / 2.0)
	fog_material.set_shader_parameter("visibility_texture", visibility_viewport.get_texture())
	fog_material.set_shader_parameter("exploration_texture", exploration_viewport.get_texture())
	
	mesh_instance.material_override = fog_material
	add_child(mesh_instance)

var _sprite_pool: Array[Sprite2D] = []
var _active_sprites: Dictionary = {} # source_node -> Sprite2D

func update_vision(sources: Array[Node]) -> void:
	# 1. Reset active sprites visibility
	for source in _active_sprites.keys():
		if not is_instance_valid(source) or source not in sources:
			var sprite = _active_sprites[source]
			sprite.visible = false
			var peer = sprite.get_meta("exploration_peer")
			if is_instance_valid(peer): peer.visible = false
			_sprite_pool.append(sprite)
			_active_sprites.erase(source)

	# 2. Update/Create sprites for current sources
	for source in sources:
		var vis_comp = source.get("visibility_component")
		if not vis_comp: continue
		
		var sprite: Sprite2D
		if _active_sprites.has(source):
			sprite = _active_sprites[source]
		else:
			sprite = _get_sprite_from_pool()
			_active_sprites[source] = sprite
		
		var uv_pos = (Vector2(source.global_position.x, source.global_position.z) + map_size / 2.0) / map_size
		var screen_pos = uv_pos * float(resolution)
		var scale = Vector2.ONE * (vis_comp.vision_range / map_size.x) * (float(resolution) / 256.0) # 256 is texture size
		
		sprite.position = screen_pos
		sprite.scale = scale
		sprite.visible = true
		
		var peer = sprite.get_meta("exploration_peer")
		if is_instance_valid(peer):
			peer.position = screen_pos
			peer.scale = scale
			peer.visible = true

func _get_sprite_from_pool() -> Sprite2D:
	if _sprite_pool.size() > 0:
		return _sprite_pool.pop_back()
	
	var sprite = Sprite2D.new()
	
	# Create a radial gradient for vision
	var gradient = Gradient.new()
	gradient.offsets = [0.0, 1.0]
	gradient.colors = [Color.WHITE, Color(1, 1, 1, 0)]
	
	var texture = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(0.5, 0.0)
	texture.width = 128
	texture.height = 128
	
	sprite.texture = texture
	sprite.modulate = Color.WHITE
	visibility_viewport.add_child(sprite)
	
	# Persistent exploration sprite
	var exploration_sprite = Sprite2D.new()
	exploration_sprite.texture = sprite.texture
	exploration_sprite.modulate = Color.WHITE
	exploration_viewport.add_child(exploration_sprite)
	
	# Link them so they move together
	sprite.set_meta("exploration_peer", exploration_sprite)
	
	return sprite
