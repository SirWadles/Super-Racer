extends CanvasLayer

@onready var car_preview = $CarPreview
@onready var sub_viewport = $CarPreview/SubViewport
@onready var preview_camera = $CarPreview/SubViewport/Camera3D
@onready var primary_color_picker = $PanelContainer/VBoxContainer/ColorGrid/PrimaryColorPicker
@onready var secondary_color_picker = $PanelContainer/VBoxContainer/ColorGrid/SecondaryColorPicker
@onready var accent_color_picker = $PanelContainer/VBoxContainer/ColorGrid/AccentColorPicker
@onready var randomize_button = $PanelContainer/VBoxContainer/RandomizeButton
@onready var confirm_button = $ActionButtons/ConfirmButton
@onready var back_button = $ActionButtons/BackButton
@onready var hover_sound_player = $HoverSoundPlayer
@onready var click_sound_player = $ClickSoundPlayer

var car_instance: CharacterBody3D
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
		car_preview.add_child(car_instance)
		car_instance.set_physics_process(false)
		car_instance.set_process_input(false)
		car_instance.position = Vector3(0, 0, 0)

func _process(delta):
	current_camera_angle += camera_rotation_speed * delta
	preview_camera.position = Vector3(
		sin(current_camera_angle) * 5.0,
		2.0,
		cos(current_camera_angle) * 5.0
	)
	preview_camera.look_at(Vector3(0, 0.5, 0))
