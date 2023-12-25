extends Button
# const NUM_PARENTS_BACK = 2
@export var num_parents_back = 2


# when button is pressed, hide the grandparent container
func _on_Button_pressed():
	var parent = get_parent()
	for i in range(num_parents_back - 1):
		parent = parent.get_parent()

		parent.hide()
