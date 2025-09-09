extends CanvasLayer

@onready var margin_container = $MarginContainer
@onready var vbox_container = $MarginContainer/VBoxContainer
@onready var hbox_container = $MarginContainer/VBoxContainer/HBoxContainer
@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var back_button = $MarginContainer/VBoxContainer/BackButton

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
			button.pressed.connect(_on_car_button_pressed.bind(car_data["scene"]))

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
	var image_container = Control.new()
	image_container.custom_minimum_size = Vector2(180, 180)
	image_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	image_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(image_container)
	var texture_rect = TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if ResourceLoader.exists(texture_path):
		texture_rect.texture = load(texture_path)
	else:
		texture_rect.modulate = Color(0.5, 0.5, 0.8)
		texture_rect.texture = create_fallback_texture()
	image_container.add_child(texture_rect)
	vbox.add_theme_constant_override("separation", 10)
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_top", 10)
	margin_container.add_theme_constant_override("margin_bottom", 10)
	margin_container.add_theme_constant_override("margin_left", 10)
	margin_container.add_theme_constant_override("margin_right", 10)
	button.remove_child(vbox)
	margin_container.add_child(vbox)
	button.add_child(margin_container)

func create_fallback_texture() -> ImageTexture:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.5, 0.5, 0.8, 1.0))
	return ImageTexture.create_from_image(image)

func setup_navigation():
	if hbox_container.get_child_count() > 0:
		hbox_container.get_child(0).grab_focus()

func _on_car_button_pressed(car_scene_path):
	Global.selected_car_path = car_scene_path
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()
