extends Button


func on_button_toggle(toggle):
	if toggle == true:
		get_parent().get_node("TriDuplicator").visible = true
	else:
		get_parent().get_node("TriDuplicator").visible = false
