extends Node

class_name Calculations


static func character_outfit_bonus(character: Character) -> Dictionary:
	return calculate_outfit_bonus(character.pant, character.shirt, character.accessory)
	
static func calculate_outfit_bonus(pants: Jawn, shirt: Jawn, accessory: Jawn) -> Dictionary:
	var bonuses = {}
	# Color Bonuses
	if pants.color.color == shirt.color.color and shirt.color.color == accessory.color.color:
		match pants.color.color:
			ColorType.Colors.BLACK:
				bonuses["GOTH BONUS"] = 0.5
	
	# Expense Bonuses
	if (pants.expensive.expensive == Expensive.Expensives.CHEAP and 
		shirt.expensive.expensive == Expensive.Expensives.CHEAP and 
		accessory.expensive.expensive == Expensive.Expensives.CHEAP):
		bonuses["DISGUSTING STENCH"] = 0.4
	
	if (pants.expensive.expensive == Expensive.Expensives.LUXURY and 
		shirt.expensive.expensive == Expensive.Expensives.LUXURY and 
		accessory.expensive.expensive == Expensive.Expensives.LUXURY):
		bonuses["NEW MONEY BONUS"] = 0.5
	
	# Style Bonuses
	if pants.style.style == shirt.style.style and shirt.style.style == accessory.style.style:
		match pants.style.style:
			Style.Styles.PREP:
				bonuses["YACHT CLUB INCIDENT"] = 0.4
	
	# Intensity Bonuses
	var avg_intensity = (pants.color.intensity + shirt.color.intensity + accessory.color.intensity) / 3
	if avg_intensity > 0.85:
		bonuses["EYE CATCHING!!!"] = 0.3
	elif avg_intensity < 0.25:
		bonuses[".STEALTH BONUS."] = 0.2

	
	return bonuses
