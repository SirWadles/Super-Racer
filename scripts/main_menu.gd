extends Control

@onready var start_button = $CenterContainer/VBoxContainer/StartButton
@onready var options_button = $CenterContainer/VBoxContainer/OptionsButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

@onready var button_sound_1 = $ButtonSound_1
@onready var button_sound_2 = $ButtonSound_2
@onready var music_player = $MusicPlayer

@onready var audio_options = $AudioOptions

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	start_button.grab_focus()
	if not music_player.playing:
		music_player.play()
	audio_options.visible = false

func _on_start_button_pressed():
	print("Starting game...")
	button_sound_1.play()
	await button_sound_1.finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_button_pressed():
	print("Options Button Pressed")
	button_sound_1.play()
	await button_sound_1.finished
	audio_options.show_options()

func _on_quit_button_pressed():
	print("Quiting game...")
	button_sound_2.play()
	await button_sound_2.finished
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_start_button_pressed()
	if event.is_action_pressed("ui_cancel"):
		_on_quit_button_pressed()
