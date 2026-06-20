# res://src/autoloads/config_manager.gd
extends Node

const CONFIG_PATH = "user://config.cfg"
var _config := ConfigFile.new()

func _ready() -> void:
	# Load existing settings, or create defaults if the file doesn't exist yet
	if _config.load(CONFIG_PATH) == OK:
		_apply_loaded_settings()
	else:
		_set_default_settings()


func save_setting(section: String, key: String, value: Variant) -> void:
	# Updates an in-memory configuration value and flushes it to the disk
	_config.set_value(section, key, value)
	_config.save(CONFIG_PATH)


func get_setting(section: String, key: String, default: Variant) -> Variant:
	return _config.get_value(section, key, default)


func _apply_loaded_settings() -> void:
	# Apply Audio Volume
	var bgm_vol = get_setting("audio", "bgm_volume", 0.75)
	var sfx_vol = get_setting("audio", "sfx_volume", 0.75)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(bgm_vol))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("BGM"), bgm_vol == 0.0)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_vol))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), sfx_vol == 0.0)
	
	# Apply Language Locale
	var locale = get_setting("localization", "locale", "en")
	TranslationServer.set_locale(locale)
	
	# Apply Fullscreen Mode
	var is_fullscreen = get_setting("video", "fullscreen", false)
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _set_default_settings() -> void:
	# Populates a brand new file with optimized baseline settings
	save_setting("audio", "bgm_volume", 0.75)
	save_setting("audio", "sfx_volume", 0.75)
	save_setting("localization", "locale", TranslationServer.get_locale().left(2))
	save_setting("video", "fullscreen", false)
