extends Control

# Fixed grid parameters - adjust these values directly
var grid_start_position = Vector2(1920/2, 1080/2)  # Top-left corner of grid
var grid_size = Vector2(560, 350)            # Total size of grid
var cell_size = Vector2(80, 70)              # Size of each calendar cell
var grid_columns = 7                         # Days per week
var grid_rows = 5                            # Weeks per month (5 to fit 31 days)

# Day button containers
var day_containers = []

# Grid layout definition
var first_day_column = 0  # Column of the first day (0=Sunday or Monday depending on calendar)

# Debug visuals
var debug_mode = true  # Set to true to see grid lines

func _ready():
	print("GridContainer _ready")

	# Find and configure all day containers
	for i in range(1, 31):  # 30 days in a month
		var container = get_node_or_null("Day_" + str(i))
		if container:
			day_containers.append(container)
	
	print("GridContainer found", day_containers.size(), "day containers")
	
	# Set the position of the grid container itself
	position = grid_start_position
	
	# Create debug visuals and position days
	if debug_mode:
		print("GridContainer creating debug visuals")
		create_debug_visuals(grid_size)
	
	# Position all day containers
	position_day_containers()
	
	# Handle viewport resizing - now just repositions days without recalculating
	get_tree().root.size_changed.connect(position_day_containers)

func create_debug_visuals(grid_size):
	# Clear any existing debug visuals
	remove_debug_visuals()
	
	# Create a ColorRect to show the entire grid area
	var grid_rect = ColorRect.new()
	grid_rect.name = "DebugGridRect"
	grid_rect.color = Color(1, 0, 0, 0.1)  # Transparent red
	grid_rect.position = Vector2.ZERO
	grid_rect.size = grid_size
	add_child(grid_rect)
	
	# Create grid lines for each cell
	for r in range(grid_rows + 1):  # Horizontal lines
		var line = Line2D.new()
		line.name = "DebugHLine_" + str(r)
		line.default_color = Color(0, 0, 1, 0.5)  # Blue
		line.width = 1
		line.add_point(Vector2(0, r * cell_size.y))
		line.add_point(Vector2(grid_size.x, r * cell_size.y))
		grid_rect.add_child(line)
	
	for c in range(grid_columns + 1):  # Vertical lines
		var line = Line2D.new()
		line.name = "DebugVLine_" + str(c)
		line.default_color = Color(0, 0, 1, 0.5)  # Blue
		line.width = 1
		line.add_point(Vector2(c * cell_size.x, 0))
		line.add_point(Vector2(c * cell_size.x, grid_size.y))
		grid_rect.add_child(line)

func remove_debug_visuals():
	var debug_rect = get_node_or_null("DebugGridRect")
	if debug_rect:
		debug_rect.queue_free()

func position_day_containers():
	# Position each day container in the grid
	for container in day_containers:
		# Get the day number from the container name
		var day_number = 0
		
		if container.has_method("get_day_number"):
			day_number = container.get_day_number()
		else:
			# Extract from name if no method available
			var name_parts = container.name.split("_")
			if name_parts.size() <= 1 or not name_parts[1].is_valid_int():
				continue
			day_number = int(name_parts[1])
		
		# Calculate row and column
		var grid_pos = get_grid_position_for_day(day_number)
		var pos_x = grid_pos.x * cell_size.x
		var pos_y = grid_pos.y * cell_size.y
		
		# Set the container's grid position
		if container.has_method("set_grid_position"):
			container.set_grid_position(pos_x, pos_y, cell_size)
		else:
			# Fall back to direct positioning
			container.position = Vector2(pos_x, pos_y)
			container.custom_minimum_size = cell_size
			container.size = cell_size
		
		# Enable debug mode on container if needed
		if debug_mode and container.has_method("set_debug_mode"):
			container.set_debug_mode(true)
		
		print("Positioned Day", day_number, "at grid", grid_pos, "screen position:", Vector2(pos_x, pos_y))

func get_grid_position_for_day(day_number):
	# Calculate position in the grid based on day number
	# This assumes day 1 starts at first_day_column
	var adjusted_day = day_number - 1  # 0-based
	var column = (adjusted_day + first_day_column) % grid_columns
	var row = (adjusted_day + first_day_column) / grid_columns
	
	return Vector2(column, row)

func _draw():
	if debug_mode:
		# Draw outer border for the entire grid container 
		draw_rect(Rect2(Vector2.ZERO, grid_size), Color.GREEN, false, 2.0)
