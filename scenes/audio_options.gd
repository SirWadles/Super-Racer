extends CanvasLayer

@onready var master_slider = $AudioContainer/MasterVolume/MasterSlider
@onready var music_slider = $AudioContainer/MusicVolume/MusicSlider
@onready var sfx_slider = $AudioContainer/SFXVolume/SFXSlider

@onready var apply_buttons = $Buttons/ApplyButton
@onready var back_buttons = $Buttons/BackButton

var audio_settings = {
	"master_volume": 1.0,
	"music_volume": 1.0,
	"sfx_volume": 1.0
}

func _ready():
	load_audio_settings()
	apply_buttons.pressed.connect(_on_apply_pressed)
	back_buttons.pressed.connect(_on_back_pressed)
	
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_volume.value_changed.connect(_on_music_volume_changed)
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)
	
	apply_audio_settings()

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
	audio_settings.master_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_volume_changed(value: float):
	audio_settings.master_volume = value
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
	get_tree().paused = true

func hide_options():
	visible = false
	get_tree().paused = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_back_pressed()
		else:
			show_options()
