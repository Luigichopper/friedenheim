# res://src/autoloads/config_manager.gd
extends Node

const CONFIG_PATH = "user://config.cfg"
var _config := ConfigFile.new()

func _ready() -> void:
	if _config.load(CONFIG_PATH) == OK:
		_apply_loaded_settings()
	else:
		_set_default_settings()


## Sets a value in memory and writes it to disk immediately. Use this for
## one-off changes (e.g. a single toggle).
func save_setting(section: String, key: String, value: Variant) -> void:
	_config.set_value(section, key, value)
	_config.save(CONFIG_PATH)


## Sets a value in memory WITHOUT writing to disk. Use this when setting
## multiple values in a row — call flush() once at the end instead.
func set_setting_deferred(section: String, key: String, value: Variant) -> void:
	_config.set_value(section, key, value)


## Writes whatever's currently in memory to disk. Call after one or more
## set_setting_deferred() calls.
func flush() -> void:
	_config.save(CONFIG_PATH)


func get_setting(section: String, key: String, default: Variant) -> Variant:
	return _config.get_value(section, key, default)


func _apply_loaded_settings() -> void:
	var sfx_vol = get_setting("audio", "sfx_volume", 0.75)
	var bgm_vol = get_setting("audio", "bgm_volume", 0.75)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_vol))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), sfx_vol == 0.0)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(bgm_vol))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("BGM"), bgm_vol == 0.0)

	var locale = get_setting("localization", "locale", "en")
	TranslationServer.set_locale(locale)

	var is_fullscreen = get_setting("video", "fullscreen", false)
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _set_default_settings() -> void:
	set_setting_deferred("audio", "sfx_volume", 0.75)
	set_setting_deferred("audio", "bgm_volume", 0.75)
	set_setting_deferred("localization", "locale", TranslationServer.get_locale().left(2))
	set_setting_deferred("video", "fullscreen", false)
	flush()
