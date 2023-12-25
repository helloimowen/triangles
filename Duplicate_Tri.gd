extends Button

const DUPLICATOR_RATIO = 1.6


func get_parent_width():
	return get_parent().get_size().x


func duplicate_poly_on_press():
	var tris = get_parent().get_node("InSide").get_node("Area2D").get_overlapping_areas()
	var base = get_parent().get_parent()
	for tri in tris:
		var new_poly = tri.get_parent().duplicate()
		new_poly.position = (
			tri.get_parent().position + Vector2(get_parent_width() / DUPLICATOR_RATIO, 0)
		)
		new_poly.set_mod_color(false)
		base.add_child(new_poly)
