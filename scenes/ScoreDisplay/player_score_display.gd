extends Label
signal tween_completed

# Tween parameters
@export var tween_duration = 1.0  # Duration in seconds
@export var step_time = 0.05      # Time between number updates

# Display options
@export var use_text_numbers = true  # Toggle between text and numeric display
@export var decimal_places = 2       # Number of decimal places for numeric display
@export var include_commas = true    # Add commas for thousands in numeric display
@export_category("Text Display Options")
@export var capitalize_first = true  # Capitalize first letter of text numbers

# Text number mapping
var number_words = {
	0: "zero", 1: "one", 2: "two", 3: "three", 4: "four", 
	5: "five", 6: "six", 7: "seven", 8: "eight", 9: "nine",
	10: "ten", 11: "eleven", 12: "twelve", 13: "thirteen", 14: "fourteen", 
	15: "fifteen", 16: "sixteen", 17: "seventeen", 18: "eighteen", 19: "nineteen",
	20: "twenty", 30: "thirty", 40: "forty", 50: "fifty", 
	60: "sixty", 70: "seventy", 80: "eighty", 90: "ninety"
}

var current_value = 0.0
var target_value = 0.0
var tween

# Call this function to start the tween
func count_to(value):
	target_value = float(value)
	current_value = 0.0
	
	# Create and start a tween for smooth animation
	tween = create_tween()
	tween.tween_property(self, "current_value", target_value, tween_duration)
	tween.set_trans(Tween.TRANS_LINEAR)
	
	# Connect the tween's finished signal
	tween.finished.connect(_on_tween_finished)
	
	# Start the step timer to update text
	_update_label()
	$StepTimer.wait_time = step_time
	$StepTimer.start()

# Set display mode (can be called anytime)
func set_display_mode(use_text):
	use_text_numbers = use_text
	_update_label()  # Update immediately

# Update the label text based on the current value
func _update_label():
	if use_text_numbers:
		var words = number_to_words(int(round(current_value)))
		if capitalize_first and words.length() > 0:
			words = words.substr(0, 1).to_upper() + words.substr(1)
		text = words
	else:
		text = format_number(current_value)

# Format a number with proper decimal places and thousands separators
func format_number(num):
	# First, format the number with the specified decimal places
	var formatted_num = "%.*f" % [decimal_places, num]
	
	if include_commas:
		# Split the number into integer and decimal parts
		var parts = formatted_num.split(".")
		var integer_part = parts[0]
		var decimal_part = ""
		if parts.size() > 1:
			decimal_part = "." + parts[1]		
		# Add commas to the integer part
		var with_commas = ""
		var pos = integer_part.length() % 3
		
		# Handle the first group (which might be less than 3 digits)
		if pos > 0:
			with_commas = integer_part.substr(0, pos)
			if integer_part.length() > pos:
				with_commas += ","
		
		# Handle the rest of the groups
		while pos < integer_part.length():
			with_commas += integer_part.substr(pos, 3)
			pos += 3
			if pos < integer_part.length():
				with_commas += ","
		
		return with_commas + decimal_part
	
	return formatted_num

# Enhanced number to words function that can handle larger numbers
func number_to_words(num):
	# Handle 0 specially
	if num == 0:
		return "zero"
	
	# Handle negative numbers
	if num < 0:
		return "negative " + number_to_words(-num)
	
	var words = ""
	
	# Handle billions
	if num >= 1000000000:
		words += number_to_words(num / 1000000000) + " billion"
		num %= 1000000000
		if num > 0:
			words += " "
	
	# Handle millions
	if num >= 1000000:
		words += number_to_words(num / 1000000) + " million"
		num %= 1000000
		if num > 0:
			words += " "
	
	# Handle thousands
	if num >= 1000:
		words += number_to_words(num / 1000) + " thousand"
		num %= 1000
		if num > 0:
			words += " "
	
	# Handle hundreds
	if num >= 100:
		words += number_to_words(num / 100) + " hundred"
		num %= 100
		if num > 0:
			words += " "
	
	# Handle tens and ones
	if num > 0:
		if num < 20:
			words += number_words[num]
		else:
			var tens = (num / 10) * 10
			var ones = num % 10
			
			words += number_words[tens]
			if ones > 0:
				words += "-" + number_words[ones]
	
	return words

# Called when the StepTimer times out
func _on_step_timer_timeout():
	_update_label()
	
	# Stop the timer if the tween is done
	if current_value >= target_value:
		$StepTimer.stop()

# Called when the tween is finished
func _on_tween_finished():
	current_value = target_value
	_update_label()
	$StepTimer.stop()
	tween_completed.emit()


# Called when the node enters the scene tree
func _ready():
	# Create a timer for updating the label
	var timer = Timer.new()
	timer.name = "StepTimer"
	timer.one_shot = false
	add_child(timer)
	
	# Connect the timer signal using Godot 4 syntax
	timer.timeout.connect(_on_step_timer_timeout)
