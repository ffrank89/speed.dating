extends Control
class_name InventoryUI

signal item_selected(item)

# Inventory panel settings
const INVENTORY_SIZE := Vector2(500, 600)
const ITEM_SIZE := Vector2(180, 180)
const ITEM_MARGIN := 10
const MAX_ITEMS_PER_ROW := 1

# Styling
const PANEL_STYLE := {
	"bg_color": Color(0.1, 0.1, 0.1, 0.7),
	"border_width": 2,
	"corner_radius": 8
}

var inventory_panel: Panel  # Declare as type Panel
var grid_container: GridContainer
var inventory_items = []

func _ready():
	anchor_right = 1.0
	anchor_bottom = 1.0
	_create_inventory_panel()
	
	# Connect to player manager global for updates
	var player_manager = get_node_or_null("/root/PlayerManager")
	if player_manager:
		pass
		# Add signals for inventory changes
		
func _update_position():
	# Position at lower left with 20px margin
	inventory_panel.position = Vector2(20, get_viewport_rect().size.y - INVENTORY_SIZE.y - 20)

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
	
	# Set the item icon if available
	if item.icon:
		button.icon = load(item.icon)
	else:
		# Use text if no icon
		button.text = item.name.substr(0, 2)  # First two letters as fallback
	
	# Add tooltip with item info
	button.tooltip_text = item.name
	
	# Connect button press
	button.pressed.connect(func(): emit_signal("item_selected", item))
	
	return button

func toggle_visibility():
	inventory_panel.visible = !inventory_panel.visible
