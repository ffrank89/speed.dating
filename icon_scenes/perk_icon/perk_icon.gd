extends AnimatedSprite2D
class_name PerkIcon

# Perk data
var perk_data = null

# Visual elements
@onready var tooltip = $ToolTip
var target_size = Vector2(64, 64)
var mouse_over = false

func _ready():
	if tooltip:
		tooltip.visible = false
	
	set_process_input(true)

func _input(event):
	# Check for mouse movement events
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		var rect = Rect2(global_position - (target_size/2), target_size)
		
		# Check if mouse is hovering over the icon
		var is_hovering = rect.has_point(mouse_pos)
		
		# Handle hover enter
		if is_hovering and not mouse_over:
			mouse_over = true
			_on_mouse_enter()
		
		# Handle hover exit
		elif not is_hovering and mouse_over:
			mouse_over = false
			_on_mouse_exit()

func setup(data):
	perk_data = data
	# Set the animation based on perk type
	if sprite_frames.has_animation(data.type):
		print("PerkIcon setup. yes has_animation. data: ", data)
		play(data.type)
	else:
		# Default animation if type-specific one isn't available
		play("default")
	
	# Set tooltip text
	if tooltip:
		print("Yes tooltip")
		tooltip.text = data.name + "\n" + data.description

func _on_mouse_enter():
	# Show tooltip on hover
	if tooltip:
		tooltip.visible = true
		
func _on_mouse_exit():
	# Hide tooltip
	if tooltip:
		tooltip.visible = false
