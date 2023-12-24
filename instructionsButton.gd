extends Button

var clicked = false


# when button is clicked, reveal instructions
func _reveal_instructions(toggled):
	if toggled:
		clicked = true
		get_child(0).show()
	else:
		clicked = false
		get_child(0).hide()
