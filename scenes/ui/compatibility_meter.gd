extends ProgressBar

func _ready():
   # Basic settings
   min_value = 0
   max_value = 100
   custom_minimum_size = Vector2(200, 30)
   position = Vector2(500, 20)
   
   # Style
   var style = StyleBoxFlat.new()
   style.bg_color = Color("#333333")  # Dark background
   add_theme_stylebox_override("background", style)
   
   var fill_style = StyleBoxFlat.new()
   fill_style.bg_color = Color("#4CAF50")  # Green fill
   add_theme_stylebox_override("fill", fill_style)

func update_compatibility(value: float):
   self.value = value * 100  # Convert 0-1 to percentage
   modulate = Color.GREEN.lerp(Color.RED, 1 - value)  # Color changes with value
