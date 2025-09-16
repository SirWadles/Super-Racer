extends CanvasLayer

@onready var car_preview = $CarPreview
@onready var sub_viewport = $CarPreview/SubViewport
@onready var preview_camera = $CarPreview/SubViewport/Camera3D
@onready var primary_color_picker = $MarginContainer/VBoxContainer/CustomizationPanel/VBoxContainer/ColorGrid/PrimaryColorPicker
@onready var secondary_color_picker = $MarginContainer/VBoxContainer/CustomizationPanel/VBoxContainer/ColorGrid/SecondaryColorPicker
@onready var accent_color_picker = $MarginContainer/VBoxContainer/CustomizationPanel/VBoxContainer/ColorGrid/AccentColorPicker
@onready var randomize_button = $MarginContainer/VBoxContainer/CustomizationPanel/VBoxContainer/RandomizeButton
@onready var confirm_button = $MarginContainer/VBoxContainer/ActionButtons/ConfirmButton
@onready var back_button = $MarginContainer/VBoxContainer/ActionButtons/BackButton
@onready var hover_sound_player = $HoverSoundPlayer
@onready var click_sound_player = $ClickSoundPlayer

var car_instance: Node3D
var car_materials: Array = []
var primary_materials: Array = []
var secondary_materials: Array = []
var accent_materials: Array = []

var camera_rotation_speed: float = 0.5
var current_camera_angle: float = 0.0

func _ready():
	var car_scene = Global.get_selected_car()
	if car_scene:
		car_instance = car_scene.instantiate()
		sub_viewport.add_child(car_instance)
		car_instance.set_physics_process(false)
		car_instance.set_process(false)
		car_instance.set_process_input(false)
		disable_physics_recursive(car_instance)
		car_instance.position = Vector3(0, 0, 0)
		extract_car_materials(car_instance)
		categorize_materials()
		connect_signals()
		apply_ui_theme()
		setup_container_sizes()
		if not load_customization():
			randomize_all_colors()
	else:
		push_error("Failed to load car scene")

func _process(delta):
	current_camera_angle += camera_rotation_speed * delta
	preview_camera.position = Vector3(
		sin(current_camera_angle) * 5.0,
		2.0,
		cos(current_camera_angle) * 5.0
	)
	preview_camera.look_at(Vector3(0, 0.5, 0))

func connect_signals():
	primary_color_picker.color_changed.connect(_on_primary_color_changed)
	secondary_color_picker.color_changed.connect(_on_secondary_color_changed)
	accent_color_picker.color_changed.connect(_on_accent_color_changed)
	
	randomize_button.pressed.connect(_on_randomize_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	
	randomize_button.mouse_entered.connect(_on_button_mouse_hover)
	back_button.mouse_entered.connect(_on_button_mouse_hover)
	confirm_button.mouse_entered.connect(_on_button_mouse_hover)
	primary_color_picker.mouse_entered.connect(_on_button_mouse_hover)
	secondary_color_picker.mouse_entered.connect(_on_button_mouse_hover)
	accent_color_picker.mouse_entered.connect(_on_button_mouse_hover)

func extract_car_materials(node: Node):
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		for i in range(mesh_instance.get_surface_override_material_count()):
			var material = mesh_instance.get_surface_override_material(i)
			if material and material not in car_materials:
				car_materials.append(material)
		if mesh_instance.material_override and mesh_instance.material_override not in car_materials:
			car_materials.append(mesh_instance.material_override)
	for child in node.get_children():
		extract_car_materials(child)

func categorize_materials():
	primary_materials.clear()
	secondary_materials.clear()
	accent_materials.clear()
	for material in car_materials:
		var material_name = ""
		if material.resource_path:
			material_name = material.resource_path.get_file().to_lower()
		else:
			material_name = str(material).to_lower()
		if "body" in material_name or "primary" in material_name or "main" in material_name:
			primary_materials.append(material)
		elif "trim" in material_name or "secondary" in material_name or "window" in material_name:
			secondary_materials.append(material)
		elif "accent" in material_name or "detail" in material_name or "light" in material_name or "glass" in material_name:
			accent_materials.append(material)
		else:
			primary_materials.append(material)
	if primary_materials.is_empty() and not car_materials.is_empty():
		primary_materials = car_materials.duplicate()

func _on_primary_color_changed(color: Color):
	apply_color_to_materials(primary_materials, color)

func _on_secondary_color_changed(color: Color):
	apply_color_to_materials(secondary_materials, color)

func _on_accent_color_changed(color: Color):
	apply_color_to_materials(accent_materials, color)

func apply_color_to_materials(materials: Array, color: Color):
	for material in materials:
		if material is StandardMaterial3D:
			var standart_material = material as StandardMaterial3D
			standart_material.albedo_color = color
		elif material is BaseMaterial3D:
			if material.has_method("set_albedo"):
				material.set_albedo(color)

func randomize_all_colors():
	var primary_color = generate_random_color()
	var secondary_color = generate_random_color()
	var accent_color = generate_complementary_color(primary_color)
	
	primary_color_picker.color = primary_color
	secondary_color_picker.color = secondary_color
	accent_color_picker.color = accent_color
	_on_primary_color_changed(primary_color)
	_on_secondary_color_changed(secondary_color)
	_on_accent_color_changed(accent_color)

func generate_random_color() -> Color:
	var hue = randf()
	var saturation = randf_range(0.6, 0.9)
	var value = randf_range(0.6, 0.9)
	return Color.from_hsv(hue, saturation, value)

func generate_complementary_color(base_color: Color) -> Color:
	var hue = fmod(base_color.h + 0.5, 1.0)
	var saturation = clamp(base_color.s + randf_range(-0.2, 0.2), 0.4, 1.0)
	var value = clamp(base_color.v + randf_range(-0.2, 0.2), 0.4, 1.0)
	return Color.from_hsv(hue, saturation, value)

func _on_randomize_button_pressed():
	play_click_sound()
	randomize_all_colors()

func _on_confirm_button_pressed():
	play_click_sound()
	save_customization()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_back_button_pressed():
	play_click_sound()
	save_customization()
	get_tree().change_scene_to_file("res://scenes/car_selection.tscn")

func _on_button_mouse_hover():
	if hover_sound_player and hover_sound_player.stream:
		pass
	elif 1 == 0:
		hover_sound_player.play()

func play_click_sound():
	if click_sound_player and click_sound_player.stream:
		click_sound_player.play()

func save_customization() -> bool:
	Global.set_value("car_primary_color", primary_color_picker.color)
	Global.set_value("car_secondary_color", secondary_color_picker.color)
	Global.set_value("car_accent_color", accent_color_picker.color)
	
	var config = ConfigFile.new()
	config.set_value("car_customization", "primary_color", primary_color_picker.color)
	config.set_value("car_customization", "secondary_color", secondary_color_picker.color)
	config.set_value("car_customization", "accent_color", accent_color_picker.color)
	var error = config.save("user://car_customization.cfg")
	if error != OK:
		push_error("Failed to save" + str(error))
		return false
	return true

func load_customization() -> bool:
	var config = ConfigFile.new()
	var error = config.load("user://car_customization.cfg")
	if error == OK:
		if config.has_section_key("car_customization", "primary_color"):
			var primary_color = config.get_value("car_customization", "primary_color")
			primary_color_picker.color = primary_color
			_on_primary_color_changed(primary_color)
		if config.has_section_key("car_customization", "secondary_color"):
			var secondary_color = config.get_value("car_customization", "secondary_color")
			secondary_color_picker.color = secondary_color
			_on_secondary_color_changed(secondary_color)
		if config.has_section_key("car_customization", "accent_color"):
			var accent_color = config.get_value("car_customization", "accent_color")
			accent_color_picker.color = accent_color
			_on_accent_color_changed(accent_color)
		return true
	return false

func apply_ui_theme():
	var theme = Theme.new()
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	button_style.border_color = Color(0.5, 0.5, 0.5)
	button_style.border_width_left = 2
	button_style.border_width_top = 2
	button_style.border_width_right = 2
	button_style.border_width_bottom = 2
	button_style.corner_radius_top_left = 2
	button_style.corner_radius_top_right = 2
	button_style.corner_radius_bottom_left = 2
	button_style.corner_radius_bottom_right = 2
	theme.set_stylebox("normal", "Button", button_style)
	var font = ThemeDB.fallback_font
	var font_size = 18
	theme.set_font("font", "Label", font)
	theme.set_font_size("font_size", "Label", 20)
	randomize_button.theme = theme
	confirm_button.theme = theme
	back_button.theme = theme

func setup_container_sizes():
	var customization_panel = $MarginContainer/VBoxContainer/CustomizationPanel
	customization_panel.custom_minimum_size = Vector2(200, 200)
	var color_grid = $MarginContainer/VBoxContainer/CustomizationPanel/VBoxContainer/ColorGrid
	color_grid.columns = 2
	var action_buttons = $MarginContainer/VBoxContainer/ActionButtons
	action_buttons.add_theme_constant_override("separation", 20)
	var vbox_container = $MarginContainer/VBoxContainer
	vbox_container.add_theme_constant_override("separation", 30)
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox_container.add_child(spacer)
	vbox_container.move_child(spacer, vbox_container.get_child_count() - 2)
	randomize_button.custom_minimum_size = Vector2(200, 40)
	back_button.custom_minimum_size = Vector2(150, 50)
	confirm_button.custom_minimum_size = Vector2(150, 50)
	
	primary_color_picker.custom_minimum_size = Vector2(40, 40)
	secondary_color_picker.custom_minimum_size = Vector2(40, 40)
	accent_color_picker.custom_minimum_size = Vector2(40, 40)

func disable_physics_recursive(node: Node):
	if node is CharacterBody3D:
		node.set_physics_process(false)
		node.set_process(false)
		node.set_process_input(false)
	if node.has_method("set_physics_process"):
		node.set_physics_process(false)
	if node.has_method("set_process"):
		node.set_process(false)
	for child in node.get_children():
		disable_physics_recursive(child)
