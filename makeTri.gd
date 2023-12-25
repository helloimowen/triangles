extends Node2D

const MIN_TRI_SIZE = 500
const PREVIEW_SCALE = .25
const AUTOSAVE_FRAMES = 1800
const TIMER_DURATION = 3

@onready var triangle_scene = preload("res://triangle.tscn")


func _ready():
	#make dir saves if it doesn't exist

	var saves_dir = DirAccess.open("user://")
	if not saves_dir.dir_exists("saves"):
		saves_dir.make_dir("saves")


# each frame, check and see if timer is done on the saved dialogue
func _process(_delta):
	var saved_dialogue = get_node("/root/Node2D/ColorRect/ImageSaved")
	saved_dialogue.get_node("Timer").set(
		"time_left", saved_dialogue.get_node("Timer").time_left - _delta
	)
	if saved_dialogue.get_node("Timer").time_left <= 0:
		saved_dialogue.hide()

	# autosave
	if (
		Engine.get_frames_drawn() > AUTOSAVE_FRAMES
		and Engine.get_frames_drawn() % AUTOSAVE_FRAMES == 0
	):
		save_all_tris("1_autosave")


func _input(event):
	# if "Q" is pressed, spawn a triangle SCENE
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		make_tri()

	# if "R" is pressed, clear all triangles from the scene
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		clear_tris()

	# if "E" is pressed, save the scene as a .png
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		take_screenshot()

	# if "S" is pressed, save the scene as a bin file containing the a godot packed binary array
	if event is InputEventKey and event.pressed and event.keycode == KEY_S:
		save_all_tris()

	# if "L" is pressed, load the scene from the godot binary format.
	if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		load_tri_files()


func make_tri(tri_min_size = MIN_TRI_SIZE):
	while true:
		# set triangle position to be centered on the mouse:
		var triangle = triangle_scene.instantiate()
		triangle.init_tri()
		if triangle.get_tri_area() > tri_min_size:
			triangle.position = get_global_mouse_position() - triangle.get_tri_center()

			# if triangle is large enough to be visible, add it to the scene

			add_child(triangle)
			break

		else:
			print("triangle too small, try again buddy.")


func save_all_tris(filename_override = null):
	var tri_list = []
	for child in get_children():
		if child is Polygon2D:
			var poly_dict = {
				"poly_points": child.polygon, "color": child.color, "position": child.position
			}
			tri_list.append(poly_dict)

	var packed_tri_list = var_to_bytes(tri_list)
	var current_iso_time = Time.get_datetime_string_from_system()

	var file_name = "user://saves/" + current_iso_time + "_triangles.bin"
	if filename_override != null:
		file_name = "user://saves/" + filename_override + "_triangles.bin"

	var write_file = FileAccess.open(file_name, FileAccess.WRITE)

	# write packed tri list to file
	write_file.store_buffer(packed_tri_list)
	write_file.close()

	var screenshot_name = "saves/" + current_iso_time
	if filename_override != null:
		screenshot_name = "saves/" + filename_override

	take_screenshot("_preview", screenshot_name, PREVIEW_SCALE)  # save thumbnail of scene

	var saved_dialogue = get_node("/root/Node2D/ColorRect/ImageSaved")

	await get_tree().create_timer(1.0 / 30).timeout  # hack, timeout to beat the screenshot above...

	saved_dialogue.set_text("Saved triangle data to " + file_name)
	saved_dialogue.show()
	saved_dialogue.get_node("Timer").start(TIMER_DURATION)

	print("Saved triangle data to " + file_name)


func load_tri_files():
	var file_list = []
	var photo_list = []
	# sort lists:

	var user_files = DirAccess.open("user://saves")
	if user_files:
		user_files.list_dir_begin()
		while true:
			var filename = user_files.get_next()

			if "_triangles.bin" in filename:
				file_list.append(filename)
				photo_list.append(filename.replace("_triangles.bin", "_preview.png"))
			elif filename == "":
				break
	else:
		print("no files found!")

	file_list.sort()  # uhhh, both paths start with iso dates, so should sort correctly.
	photo_list.sort()

	# user_files.free() # uhh maybe I need this?

	var list_of_saves = get_node("/root/Node2D/ColorRect/SaveFiles/List")
	for each in list_of_saves.get_children():
		if not each.name == "Close":
			each.queue_free()

	for i in range(file_list.size()):
		print(file_list[i])
		# load image in photo_list[i] and set as tooltip

		var preview_image = ImageTexture.new()
		var image = Image.load_from_file("user://saves/" + photo_list[i])
		preview_image.set_image(image)

		var save_button = Button.new()
		save_button.set_text(file_list[i])
		save_button.icon = preview_image
		save_button.pressed.connect(self.load_triangles.bind(file_list[i]))
		list_of_saves.add_child(save_button)

	list_of_saves.get_parent().show()


func load_triangles(file_name):
	clear_tris()
	var read_file = FileAccess.open("user://saves/" + file_name, FileAccess.READ)
	var packed_tri_list = read_file.get_buffer(read_file.get_length())
	read_file.close()
	var tri_list = bytes_to_var(packed_tri_list)

	for tri in tri_list:
		var triangle = triangle_scene.instantiate()
		triangle.polygon = tri["poly_points"]
		triangle.color = tri["color"]
		triangle.position = tri["position"]
		triangle.set_mod_color(false)

		# add collision to existing collisionPolygon2D

		triangle.get_child(0).get_child(0).set("polygon", tri["poly_points"])

		add_child(triangle)
	var list_of_saves = get_node("/root/Node2D/ColorRect/SaveFiles/List")
	list_of_saves.get_parent().hide()

	print("Loaded triangles from " + file_name)


func clear_tris():
	for child in get_children():
		if child is Polygon2D:  # CAREFUL IF WE EVER ADD ANY OTHER POLY2Ds LOL
			child.queue_free()


func take_screenshot(tag = "_screenshot", override_filename = null, resolution = 1.0):
	var saved_dialogue = get_node("/root/Node2D/ColorRect/ImageSaved")
	saved_dialogue.hide()
	# use await to wait so that the saved dialogue can hide
	await get_tree().create_timer(1.0 / 30).timeout
	var img = get_viewport().get_texture().get_image()
	img.resize(img.get_width() * resolution, img.get_height() * resolution)
	var current_iso_time = Time.get_datetime_string_from_system()
	var img_name = "user://" + current_iso_time + tag + ".png"

	if override_filename != null:
		img_name = "user://" + override_filename + tag + ".png"

	# if running the web build, save to local filesystem using JavaScript:
	if OS.get_name() == "HTML5" and tag == "_screenshot":
		var img_buf = img.save_png_to_buffer()
		JavaScriptBridge.download_buffer(img_buf, img_name, "image/png")

	img.save_png(img_name)

	var save_msg = "Saved " + img_name + " :^)"

	saved_dialogue.set_text(save_msg)
	saved_dialogue.show()
	saved_dialogue.get_node("Timer").start(TIMER_DURATION)
