extends CanvasLayer

@onready var master_slider = $MarginContainer/CenterContainer/VBoxContainer/MasterVolume/MasterSlider
@onready var music_slider = $MarginContainer/CenterContainer/VBoxContainer/MusicVolume/MusicSlider
@onready var sfx_slider = $MarginContainer/CenterContainer/VBoxContainer/SFXVolume/SFXSlider

@onready var apply_button = $MarginContainer/CenterContainer/Buttons/ApplyButton
@onready var back_button = $MarginContainer/CenterContainer/Buttons/BackButton

var audio_settings = {
	"master_volume": 1.0,
	"music_volume": 1.0,
	"sfx_volume": 1.0
}

func _ready():
	load_audio_settings()
	apply_button.pressed.connect(_on_apply_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	setup_slider_size()
	setup_button_layer()
	apply_audio_settings()
	
	var buttons_container = $MarginContainer/CenterContainer/Buttons
	buttons_container.add_theme_constant_override("margin_top", 100)

func load_audio_settings():
	audio_settings = {
	"master_volume": Settings.get_setting("audio", "master_volume", 1.0),
	"music_volume": Settings.get_setting("audio", "music_volume", 1.0),
	"sfx_volume": Settings.get_setting("audio", "sfx_volume", 1.0)
	}

func _on_master_volume_changed(value: float):
	audio_settings.master_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_volume_changed(value: float):
	audio_settings.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_volume_changed(value: float):
	audio_settings.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_apply_pressed():
	save_audio_settings()
	hide()
	get_tree().paused = false

func _on_back_pressed():
	save_audio_settings()
	hide()
	get_tree().paused = false

func apply_audio_settings():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(audio_settings.master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(audio_settings.music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(audio_settings.sfx_volume))

func save_audio_settings():
	Settings.set_setting("audio", "master_volume", audio_settings.master_volume)
	Settings.set_setting("audio", "music_volume", audio_settings.music_volume)
	Settings.set_setting("audio", "sfx_volume", audio_settings.sfx_volume)
	Settings.save_settings()

func show_options():
	load_audio_settings()
	visible = true

func hide_options():
	visible = false
	get_tree().paused = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_back_pressed()
		else:
			show_options()

func setup_slider_size():
	master_slider.custom_minimum_size = Vector2(250, 30)
	music_slider.custom_minimum_size = Vector2(250, 30)
	sfx_slider.custom_minimum_size = Vector2(250, 30)

func setup_button_layer():
	apply_button.custom_minimum_size = Vector2(160, 80)
	back_button.custom_minimum_size = Vector2(160, 80)
	
	var buttons_container = get_node("MarginContainer/CenterContainer/Buttons")
	await get_tree().process_frame
	
	buttons_container.position.y = 500
	var screen_size = get_viewport().get_visible_rect().size
	buttons_container.position.y = screen_size.y * 0.8
