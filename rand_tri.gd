extends Polygon2D

const MAX_TRI_SIZE = 256
const TRI_STARTING_POINT = [Vector2(0, 0), Vector2(15, 25), Vector2(-15, 25)]
const LERP_SPEED = 0.9
const MUTE_COLORS = Color(0.9, 0.9, 0.9, 1)


# Called when the node enters the scene tree for the first time.
func _ready():
	set_color_from_color_picker()


func get_tri_area():
	var p1 = polygon[0]
	var p2 = polygon[1]
	var p3 = polygon[2]
	return abs((p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y)) / 2.0)


func init_tri():
	# Give triangle an initial random color
	var new_color = Color(randf(), randf(), randf(), 0.9)
	self.set("color", new_color)

	# Get a random three points
	var p1 = _make_rand_normalized_vec(MAX_TRI_SIZE)
	var p2 = _make_rand_normalized_vec(MAX_TRI_SIZE)
	var p3 = _make_rand_normalized_vec(MAX_TRI_SIZE)

	# Set the points
	self.set("polygon", [p1, p2, p3])

	# add collision to existing collisionPolygon2D

	get_child(0).get_child(0).set("polygon", [p1, p2, p3])


func get_color_picker_value():
	#find color picker in scene:
	var color_picker = get_node("/root/Node2D/ColorRect/ColorPickerButton")
	return color_picker.get("color")


func set_color_from_color_picker():
	# multiply current color by color picker value
	var mod_color = get_color_picker_value()
	var new_color = (self.get("color") * MUTE_COLORS) * mod_color
	self.set("color", new_color)


func get_tri_center():
	var p1 = polygon[0]
	var p2 = polygon[1]
	var p3 = polygon[2]
	return (p1 + p2 + p3) / 3.0


func _make_rand_normalized_vec(max_val, starting_point = Vector2(0, 0)):
	var new_x = randi() % max_val
	var new_y = randi() % max_val
	return starting_point + Vector2(new_x, new_y)
