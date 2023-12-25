extends Area2D

const LERP_SPEED = 10

var selected = false


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass


func _input_event(_viewport, event, _shape_idx):
	# If the triangle is clicked, set selected
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			selected = true
		else:
			selected = false

	# on right click, delete triangle
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			get_parent().queue_free()


func _physics_process(delta):
	# If the triangle is selected, move it
	if selected:
		var tri_parent = get_parent()
		var new_pos = lerp(
			tri_parent.position,
			get_global_mouse_position() - tri_parent.get_tri_center(),
			LERP_SPEED * delta
		)
		tri_parent.set("position", new_pos)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
