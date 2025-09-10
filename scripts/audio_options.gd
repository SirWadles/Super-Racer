extends CanvasLayer

@onready var master_slider = $MasterVolume/MasterSlider
@onready var music_slider = $MusicVolume/MusicSlider
@onready var sfx_slider = $SFXVolume/SFXSlider

@onready var apply_button = $Buttons/ApplyButton
@onready var back_button = $Buttons/BackButton
@onready var button_sound = $Buttons/ButtonSound

var race_time = 0.0
var is_racing: bool = false

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
	apply_audio_settings()

func load_audio_settings():
	audio_settings = {
	"master_volume": Settings.get_setting("audio", "master_volume", 1.0),
	"music_volume": Settings.get_setting("audio", "music_volume", 1.0),
	"sfx_volume": Settings.get_setting("audio", "sfx_volume", 1.0)
	}
	master_slider.value = audio_settings.master_volume
	music_slider.value = audio_settings.music_volume
	sfx_slider.value = audio_settings.sfx_volume

func _on_master_volume_changed(value: float):
	audio_settings.master_volume = value
	var bus_index = AudioServer.get_bus_index("Master")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func _on_music_volume_changed(value: float):
	audio_settings.music_volume = value
	var bus_index = AudioServer.get_bus_index("Music")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value * 0.8))

func _on_sfx_volume_changed(value: float):
	audio_settings.sfx_volume = value
	var bus_index = AudioServer.get_bus_index("SFX")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value * 0.8))

func _on_apply_pressed():
	save_audio_settings()
	hide()
	button_sound.play()
	get_tree().paused = false

func _on_back_pressed():
	hide()
	get_tree().paused = false

func apply_audio_settings():
	var master_bus = AudioServer.get_bus_index("Master")
	if master_bus != -1:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(audio_settings.master_volume))
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(audio_settings.music_volume))
	else:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(audio_settings.music_volume))
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(audio_settings.sfx_volume))
	else:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(audio_settings.sfx_volume))

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
