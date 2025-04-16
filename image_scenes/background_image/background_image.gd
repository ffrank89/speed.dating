extends ColorRect

var background_texture: Texture2D

func _ready():
	## Load the background texture
	
	#
	# Create a shader material to display the texture
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://image_scenes/background_image/background_shader.gdshader")
	shader_material.set_shader_parameter("texture_albedo", background_texture)
	
	# Apply the material
	material = shader_material
	
	# Set size to match viewport
	size = get_viewport_rect().size
	
	# Connect to resize signals
	get_tree().root.size_changed.connect(_on_size_changed)
	

func set_background_texture(path):
	background_texture = load(path)
	if not background_texture:
		push_error("Failed to load background texture")
		return
func _on_size_changed():
	size = get_viewport_rect().size
