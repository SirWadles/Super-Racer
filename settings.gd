extends Node

const CONFIG_PATH = "user://audio_settings.cfg"
var config = ConfigFile.new()

func _ready():
	load_settings()

func get_setting(section: String, key: String, default = null):
	if config.has_section_key(section, key):
		return config.get_value(section, key)
	return default

func set_setting(section: String, key: String, value):
	config.set_value(section, key, value)

func save_settings():
	config.save(CONFIG_PATH)

func load_settings():
	var error = config.load(CONFIG_PATH)
	if error != OK:
		set_setting("audio", "master_volume", 1.0)
		set_setting("audio", "music_volume", 1.0)
		set_setting("audio", "sfx_volume", 1.0)
		save_settings()
