extends Node

func _ready():
	create_audio_buses()

func create_audio_buses():
	if AudioServer.get_bus_index("Music") == -1:
		var music_bus_idx = AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(music_bus_idx, "Music")
		AudioServer.set_bus_send(music_bus_idx, "Master")
		print("Created music")
	if AudioServer.get_bus_index("SFX") == -1:
		var sfx_bus_idx = AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(sfx_bus_idx, "SFX")
		AudioServer.set_bus_send(sfx_bus_idx, "Master")
		print("Created sfx")
	print("Available audio buses:")
	for i in range(AudioServer.get_bus_count()):
		print("  ", i, ": ", AudioServer.get_bus_name(i))

func set_master_volume(linear_volume: float):
	var bus_index = AudioServer.get_bus_index("Master")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))

func set_music_volume(linear_volume: float):
	var bus_index = AudioServer.get_bus_index("Music")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))

func set_sfx_volume(linear_volume: float):
	var bus_index = AudioServer.get_bus_index("SFX")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))

func play_music(audio_stream: AudioStream, volume_db: float = 0.0) -> AudioStreamPlayer:
	return play_sound(audio_stream, "Music", volume_db)

func play_sfx(audio_stream: AudioStream, volume_db: float = 0.0) -> AudioStreamPlayer:
	return play_sound(audio_stream, "SFX", volume_db)

func play_sound(audio_stream: AudioStream, bus_name: String, volume_db: float = 0.0) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = audio_stream
	player.volume_db = volume_db
	player.bus = bus_name
	add_child(player)
	player.play()
	player.finished.connect(_on_audio_finished.bind(player))
	return player

func _on_audio_finished(player: AudioStreamPlayer):
	player.queue_free()
