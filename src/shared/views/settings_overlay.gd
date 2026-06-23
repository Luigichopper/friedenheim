# res://src/shared/views/settings_overlay.gd
extends CanvasLayer

# Node References
@onready var language_dropdown: OptionButton = %LanguageDropdown
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var bgm_volume_slider: HSlider = %BGMVolumeSlider
@onready var fullscreen_toggle: CheckButton = %FullscreenToggle
@onready var close_button: Button = %CloseButton

const SFX_BUS_NAME = "SFX"
const BGM_BUS_NAME = "BGM"

var _previously_focused_node: Control = null

func _ready() -> void:
	_previously_focused_node = get_viewport().gui_get_focus_owner()

	language_dropdown.clear()
	language_dropdown.add_item("English")
	language_dropdown.add_item("日本語")

	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	language_dropdown.item_selected.connect(_on_language_selected)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	sfx_volume_slider.drag_ended.connect(_on_sfx_drag_ended)
	bgm_volume_slider.value_changed.connect(_on_bgm_volume_changed)
	bgm_volume_slider.drag_ended.connect(_on_bgm_drag_ended)
	close_button.pressed.connect(_on_close_pressed)

	fullscreen_toggle.button_pressed = ConfigManager.get_setting("video", "fullscreen", false)
	var saved_locale: String = ConfigManager.get_setting("localization", "locale", "en")
	language_dropdown.selected = 0 if saved_locale == "en" else 1
	sfx_volume_slider.value = ConfigManager.get_setting("audio", "sfx_volume", 0.75)
	bgm_volume_slider.value = ConfigManager.get_setting("audio", "bgm_volume", 0.75)

	language_dropdown.grab_focus()


func _on_language_selected(index: int) -> void:
	var locale = "en" if index == 0 else "ja"
	TranslationServer.set_locale(locale)
	# Single discrete change, not a drag — write immediately.
	ConfigManager.save_setting("localization", "locale", locale)


func _on_sfx_volume_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index(SFX_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(bus_idx, value == 0.0)
	ConfigManager.set_setting_deferred("audio", "sfx_volume", value)


func _on_sfx_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigManager.flush()


func _on_bgm_volume_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index(BGM_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(bus_idx, value == 0.0)
	# Memory only — avoids a disk write on every tick while dragging.
	ConfigManager.set_setting_deferred("audio", "bgm_volume", value)


func _on_bgm_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigManager.flush()


func _on_fullscreen_toggled(is_pressed: bool) -> void:
	if is_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	# Single discrete change, not a drag — write immediately.
	ConfigManager.save_setting("video", "fullscreen", is_pressed)


func _on_close_pressed() -> void:
	if _previously_focused_node and is_instance_valid(_previously_focused_node):
		_previously_focused_node.grab_focus()
	queue_free()
