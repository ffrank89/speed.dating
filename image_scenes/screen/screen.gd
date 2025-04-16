extends ColorRect

var background_texture: Texture2D
const STATIC_AMOUNT := 0.80
const SCAN_LINE_INTENSITY := 0.5

func _ready():
	# Load the background texture
	background_texture = load("res://assets/blank_white_1920_1080.jpg")
	if not background_texture:
		push_error("Failed to load background texture")
		return
		
	# Create shader material
	var shader_material = ShaderMaterial.new()
	
	# Load shader
	var shader = load("res://image_scenes/split_ends_ui/static_filter.gdshader")
	if shader:
		shader_material.shader = shader
		
		# Set shader parameters
		shader_material.set_shader_parameter("static_amount", STATIC_AMOUNT)
		shader_material.set_shader_parameter("scan_line_intensity", SCAN_LINE_INTENSITY)
		material = shader_material
		# Apply material to the character image
		print("Shader applied to character image")
	else:
		print("Failed to load static filter shader")

	# Apply the material
	material = shader_material
	
	# Set size to match viewport
	size = get_viewport_rect().size
	
	# Connect to resize signals
	get_tree().root.size_changed.connect(_on_size_changed)
	

func _on_size_changed():
	size = get_viewport_rect().size
