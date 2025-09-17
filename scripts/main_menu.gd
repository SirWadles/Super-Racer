extends Control

@onready var start_button = $CenterContainer/VBoxContainer/StartButton
@onready var options_button = $CenterContainer/VBoxContainer/OptionsButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

@onready var button_sound_1 = $ButtonSound_1
@onready var button_sound_2 = $ButtonSound_2
@onready var music_player = $MusicPlayer

@onready var audio_options = $AudioOptions

@onready var shiba_sounds = [
	$ShibaSound1,
	$ShibaSound2,
	$ShibaSound3
]

func _ready():
	size = get_viewport().get_visible_rect().size
	position = Vector2.ZERO
	if AudioManager:
		AudioManager.create_audio_buses()
	button_sound_1.bus = "SFX"
	button_sound_2.bus = "SFX"
	for shiba_sounds in shiba_sounds:
		shiba_sounds.bus = "SFX"
	music_player.bus = "Music"
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	options_button.mouse_entered.connect(options_button.release_focus)
	start_button.grab_focus()
	if not music_player.playing:
		music_player.play()
	audio_options.visible = false

func _on_start_button_pressed():
	print("Starting game...")
	var sound_played = play_random_button_sound()
	await sound_played.finished
	get_tree().change_scene_to_file("res://scenes/car_selection.tscn")

func _on_options_button_pressed():
	print("Options Button Pressed")
	var sound_played = play_random_button_sound()
	await sound_played.finished
	audio_options.show_options()

func _on_quit_button_pressed():
	print("Quiting game...")
	button_sound_2.play()
	await button_sound_2.finished
	get_tree().quit()

func play_random_button_sound():
	if randi() % 5 == 0:
		var random_shiba = shiba_sounds[randi() % shiba_sounds.size()]
		random_shiba.play()
		print("Random shiba sound! 🐕")
		return random_shiba
	else:
		button_sound_1.play()
		return button_sound_1
