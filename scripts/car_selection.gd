extends CanvasLayer

@onready var margin_container = $MarginContainer
@onready var vbox_container = $MarginContainer/VBoxContainer
@onready var hbox_container = $MarginContainer/VBoxContainer/HBoxContainer
@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var back_button = $MarginContainer/VBoxContainer/BackButton

@onready var hover_sound_player = $HoverSoundPlayer
@onready var click_sound_player = $ClickSoundPlayer
@onready var invalid_sound_player = $InvalidSoundPlayer

var scene_ready = false
var last_focused_button: Button = null
var mouse_click_in_progress = false

var car_options = [
	{
		"name": "Default Car",
		"scene": "res://scenes/car.tscn",
		"texture": "res://assets/car_1.png"
	},
	{
		"name": "Sports Car",
		"scene": "res://scenes/car.tscn",
		"texture": "res://assets/car_1.png"
	},
	{
		"name": "DeLorean Car",
		"scene": "res://scenes/car.tscn",
		"texture": "res://assets/car_teaser.png"
	}
]

func _ready():
	format_layout()
	setup_car_options()
	setup_navigation()
	
	back_button.pressed.connect(_on_back_button_pressed)
	
	await get_tree().create_timer(0.1).timeout
	scene_ready = true

func format_layout():
	margin_container.add_theme_constant_override("margin_top", 50)
	margin_container.add_theme_constant_override("margin_bottom", 50)
	margin_container.add_theme_constant_override("margin_left", 50)
	margin_container.add_theme_constant_override("margin_right", 50)
	
	vbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox_container.add_theme_constant_override("separation", 40)
	
	hbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox_container.add_theme_constant_override("separation", 30)
	
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.text = "SELECT YOUR CAR"

func setup_car_options():
	for i in range(hbox_container.get_child_count()):
		var button = hbox_container.get_child(i)
		if button is Button and i < car_options.size():
			var car_data = car_options[i]
			format_car_button_with_image(button, car_data["name"],car_data["texture"])
			button.pressed.connect(_on_car_button_pressed_with_click.bind(car_data["scene"], button))
			button.mouse_entered.connect(_on_button_mouse_hover)
			button.focus_entered.connect(_on_button_keyboard_focus.bind(button))

func format_car_button_with_image(button: Button, car_name: String, texture_path: String):
	button.custom_minimum_size = Vector2(200, 250)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.WHITE)
	for child in button.get_children():
		child.queue_free()
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.add_child(vbox)
	var label = Label.new()
	label.text = car_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	var texture_rect = TextureRect.new()
	# The line below here is so fucking dumb. That x value does jack shit
	texture_rect.custom_minimum_size = Vector2(0, 130)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(texture_path):
		var loaded_texture = load(texture_path)
		print("Loading texture for ", car_name, ": ", texture_path)
		print("Texture loaded: ", loaded_texture != null)
		if loaded_texture:
			print("Texture size: ", loaded_texture.get_size())
		texture_rect.texture = loaded_texture
	else:
		print("Texture NOT found for ", car_name, ": ", texture_path)
		texture_rect.modulate = Color(0.5, 0.5, 0.8)
		texture_rect.texture = create_fallback_texture()
	vbox.add_child(texture_rect)
	vbox.add_theme_constant_override("separation", 10)
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	margin.add_theme_constant_override("margin_left", 5)
	margin.add_theme_constant_override("margin_right", 5)
	
	button.remove_child(vbox)
	margin.add_child(vbox)
	button.add_child(margin)
	print("Button size: ", button.size)
	print("VBox size: ", vbox.size)
	print("TextureRect size: ", texture_rect.size)

func create_fallback_texture() -> ImageTexture:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.5, 0.5, 0.8, 1.0))
	return ImageTexture.create_from_image(image)

func setup_navigation():
	if hbox_container.get_child_count() > 0:
		hbox_container.get_child(0).grab_focus()

func _on_car_button_pressed_with_click(car_scene_path: String, button: Button):
	mouse_click_in_progress = true
	if click_sound_player and click_sound_player.stream:
		click_sound_player.play()
		await get_tree().create_timer(click_sound_player.stream.get_length() * 0.8).timeout
	else:
		await get_tree().create_timer(0.1)
	mouse_click_in_progress = false
	Global.set_selected_car(car_scene_path)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_button_pressed():
	mouse_click_in_progress = true
	if click_sound_player and click_sound_player.stream:
		click_sound_player.play()
		await get_tree().create_timer(click_sound_player.stream.get_length()).timeout
	else:
		await get_tree().create_timer(0.1).timeout
	mouse_click_in_progress = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_button_mouse_hover():
	if scene_ready and not mouse_click_in_progress and hover_sound_player and hover_sound_player.stream:
		hover_sound_player.play()

func _on_button_keyboard_focus(button: Button):
	if scene_ready and not mouse_click_in_progress and hover_sound_player and hover_sound_player.stream:
		hover_sound_player.play()
	last_focused_button = button

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()
