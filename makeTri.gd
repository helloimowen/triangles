extends Node2D

const MIN_TRI_SIZE = 500


func _input(event):
	# if "Q" is pressed, spawn a triangle SCENE
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		while true:
			var triangle = load("res://triangle.tscn").instantiate()
			# set triangle position to be centered on the mouse:
			triangle.init_tri()
			if triangle.get_tri_area() > MIN_TRI_SIZE:
				triangle.position = get_global_mouse_position() - triangle.get_tri_center()

				# if triangle is large enough to be visible, add it to the scene

				add_child(triangle)
				break

			else:
				print("triangle too small, try again buddy.")

	# if "R" is pressed, clear all triangles from the scene
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		for child in get_children():
			if child is Polygon2D:  # CAREFUL IF WE EVER ADD ANY OTHER POLY2Ds LOL
				child.queue_free()
