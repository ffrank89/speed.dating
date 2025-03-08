class_name Accessory
extends Jawn


static func create_random() -> Accessory:
	var random_color = ColorType.new(ColorType.Colors.values()[randi() % ColorType.Colors.values().size()], randf())
	var random_style = Style.new(Style.Styles.values()[randi() % Style.Styles.values().size()], randf())
	var random_expensive = Expensive.new(Expensive.Expensives.values()[randi() % Expensive.Expensives.values().size()], randf())
	

	return Accessory.new(random_color, random_style, random_expensive)
