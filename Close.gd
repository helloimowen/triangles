extends Button

# when button is pressed, hide the grandparent container
func _on_Button_pressed():
	get_parent().get_parent().hide()
