extends Control
class_name InventoryUI

signal item_selected(item)

# Inventory panel settings
const INVENTORY_SIZE := Vector2(500, 600)
const ITEM_WIDTH_SCALE := 1.6
const ITEM_HEIGHT_SCALE := 1.75
const ITEM_SIZE := Vector2(INVENTORY_SIZE.x/ITEM_WIDTH_SCALE, INVENTORY_SIZE.y/ITEM_HEIGHT_SCALE)
const ITEM_MARGIN := 10
const MAX_ITEMS_PER_ROW := 2

# Styling
const PANEL_STYLE := {
	"bg_color": Color(0.1, 0.1, 0.1, 0.7),
	"border_width": 2,
	"corner_radius": 8
}

var inventory_panel: Panel  # Declare as type Panel
var grid_container: GridContainer
var inventory_items = []
var animation_layer: CanvasLayer  # Canvas layer for animations
var animation_container: CenterContainer
var current_animation: AnimatedSprite2D  # Reference to the currently playing animation

func _ready():
	anchor_right = 1.0
	anchor_bottom = 1.0
	_create_inventory_panel()
	_create_animation_layer()
	
	# Connect to player manager global for updates
	var player_manager = get_node_or_null("/root/PlayerManager")
	if player_manager:
		pass
		# Add signals for inventory changes

func _create_animation_layer():
	# Create a CanvasLayer for animations (layer 100 ensures it's on top)
	animation_layer = CanvasLayer.new()
	animation_layer.layer = 100
	add_child(animation_layer)
	
	# Create a panel for blocking interactions
	var blocker = Panel.new()
	blocker.anchor_right = 1
	blocker.anchor_bottom = 1

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.5)
	blocker.add_theme_stylebox_override("panel", style)
	animation_layer.add_child(blocker)
	
	# Create a centered container for the animation
	animation_container = CenterContainer.new()
	animation_container.anchor_right = .5
	animation_container.anchor_bottom = .5
	animation_container.anchor_left = .5
	animation_container.anchor_top = .5
	animation_layer.add_child(animation_container)
	# Initially hide the animation layer
	animation_layer.visible = false

func _update_position():
	if inventory_panel:
		var viewport_size = get_viewport_rect().size
		var scale_factor_x = viewport_size.x / 1920.0
		var scale_factor_y = viewport_size.y / 1080.0
		
		# Reduce overall size - 70% of the scaled size
		var size_reduction_factor = 0.7
		
		# Scale inventory size
		var scaled_width = INVENTORY_SIZE.x * scale_factor_x * size_reduction_factor
		var scaled_height = INVENTORY_SIZE.y * scale_factor_y * size_reduction_factor
		
		# Scale item size
		var scaled_item_width = scaled_width / ITEM_WIDTH_SCALE * size_reduction_factor
		var scaled_item_height = scaled_height / ITEM_HEIGHT_SCALE * size_reduction_factor
		
		# Fixed bottom margin in pixels
		var bottom_margin = 20
		
		# Calculate position to maintain bottom margin
		var x_position = 20
		var y_position = viewport_size.y - scaled_height - bottom_margin
		
		# Set custom minimum size and position
		inventory_panel.custom_minimum_size = Vector2(scaled_width, scaled_height)
		inventory_panel.size = Vector2(scaled_width, scaled_height)
		inventory_panel.position = Vector2(x_position, y_position)
		
		# Update grid container
		grid_container.columns = MAX_ITEMS_PER_ROW
		grid_container.position = Vector2(ITEM_MARGIN, 35)
		grid_container.custom_minimum_size = Vector2(
			scaled_width - ITEM_MARGIN * 2,
			scaled_height - 45
		)
		
		# Update existing item buttons
		for child in grid_container.get_children():
			child.custom_minimum_size = Vector2(scaled_item_width, scaled_item_height)


func _process(_delta):
	# Check for viewport size changes and update position
	if inventory_panel:
		_update_position()

func _create_inventory_panel():
	inventory_panel = Panel.new()
	inventory_panel.anchor_top = 1.0
	inventory_panel.anchor_bottom = 1.0
	
	# Position relative to anchors with margin (20px from left, 20px from bottom)
	inventory_panel.position = Vector2(20, get_viewport_rect().size.y - INVENTORY_SIZE.y - 20)
	inventory_panel.custom_minimum_size = INVENTORY_SIZE

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = PANEL_STYLE.bg_color
	panel_style.set_border_width_all(PANEL_STYLE.border_width)
	panel_style.set_corner_radius_all(PANEL_STYLE.corner_radius)
	panel_style.border_color = Color.WHITE
	inventory_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Add a title
	var title_label = Label.new()
	title_label.text = "Inventory"
	title_label.position = Vector2(10, 5)
	title_label.add_theme_font_size_override("font_size", 18)
	inventory_panel.add_child(title_label)
	
	# Create a grid container for items
	grid_container = GridContainer.new()
	grid_container.columns = MAX_ITEMS_PER_ROW
	grid_container.position = Vector2(ITEM_MARGIN, 35)  # Below the title
	grid_container.custom_minimum_size = Vector2(
		INVENTORY_SIZE.x - ITEM_MARGIN * 2,
		INVENTORY_SIZE.y - 45
	)
	grid_container.add_theme_constant_override("h_separation", ITEM_MARGIN)
	grid_container.add_theme_constant_override("v_separation", ITEM_MARGIN)
	
	inventory_panel.add_child(grid_container)
	add_child(inventory_panel)
	
	# Initially hide the inventory
	inventory_panel.visible = true
	
func update_inventory(items):
	for child in grid_container.get_children():
		child.queue_free()
	
	inventory_items = items
	
	# Add each item to the grid
	for item in items:
		var item_button = _create_item_button(item)
		grid_container.add_child(item_button)
	
func _create_item_button(item):
	var button = Button.new()
	button.custom_minimum_size = ITEM_SIZE
	button.expand_icon = true
	
	if item.icon:
		button.icon = load(item.icon)
	else:
		# Use text if no icon
		button.text = item.name.substr(0, 2)

	# Add tooltip with item info
	button.tooltip_text = item.name
	
	# Connect button press
	button.pressed.connect(func(): 
		# Play animation if available
		if item.animation:
			_play_item_animation(item.ANIMATION_PATH)
		
		# Emit both local and global signals
		emit_signal("item_selected", item)  # Local signal for backward compatibility
		if get_node_or_null("/root/PlayerManager"):
			PlayerManager.select_item(item)  # Global signal through PlayerManager
	)
		
	return button

func _play_item_animation(animation_path: String):
	# Clear any existing animation
	if current_animation and is_instance_valid(current_animation):
		current_animation.queue_free()
		current_animation = null
	
	# Show the animation layer
	animation_layer.visible = true
	
	# Try to load and instance the animation scene
	var animation_scene = load(animation_path)
	if animation_scene:
		var scene_instance = animation_scene.instantiate()
		
		# Since AnimatedSprite2D is always at the root, we can directly cast it
		if scene_instance is AnimatedSprite2D:
			current_animation = scene_instance
			animation_container.add_child(current_animation)
			
			print("Current Animation: ", current_animation.name)
			# Make sure animation is centered
			current_animation.position = Vector2.ZERO
			
			# Slow down the animation
			current_animation.speed_scale = 0.25
			
			# Start the animation
			current_animation.play()
			
			# Set timer to automatically hide after 5 seconds
			var timer = Timer.new()
			timer.one_shot = true
			timer.wait_time = 2
			timer.timeout.connect(_stop_animation)
			add_child(timer)
			timer.start()
		else:
			print("Error: Root node is not an AnimatedSprite2D:", animation_path)
			if scene_instance:
				scene_instance.queue_free()
			_stop_animation()
	else:
		print("Failed to load animation: ", animation_path)
		_stop_animation()

func _stop_animation():
	# Hide the animation layer
	animation_layer.visible = false
	
	# Remove the current animation if it exists
	if current_animation and is_instance_valid(current_animation):
		current_animation.queue_free()
		current_animation = null

func toggle_visibility():
	inventory_panel.visible = !inventory_panel.visible
	
	# If we're hiding the inventory and an animation is playing, stop it
	if !inventory_panel.visible and animation_layer.visible:
		_stop_animation()
