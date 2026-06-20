# res://src/shared/views/settings_overlay.gd
extends CanvasLayer

# Node References
@onready var language_dropdown: OptionButton = $"Background/MarginContainer/PanelContainer/SettingOptionsContainer/MarginContainer/VBoxContainer2/LanguageDropdown Dropdown"
@onready var bgm_volume_slider: HSlider = $Background/MarginContainer/PanelContainer/SettingOptionsContainer/MarginContainer/VBoxContainer2/BGMVolumeSlider
@onready var sfx_volume_slider: HSlider = $Background/MarginContainer/PanelContainer/SettingOptionsContainer/MarginContainer/VBoxContainer2/SFXVolumeSlider
@onready var fullscreen_toggle: CheckButton = $Background/MarginContainer/PanelContainer/SettingOptionsContainer/MarginContainer/VBoxContainer2/FullscreenToggle
@onready var close_button: Button = $Background/MarginContainer/PanelContainer/CloseButtonContainer/MarginContainer/VBoxContainer/CloseButton

const BGM_BUS_NAME = "BGM"
const SFX_BUS_NAME = "SFX"

var _previously_focused_node: Control = null

func _ready() -> void:
	_previously_focused_node = get_viewport().gui_get_focus_owner()
	
	# Clear and initialize dropdown choices FIRST 
	language_dropdown.clear()
	language_dropdown.add_item("English")
	language_dropdown.add_item("日本語")
	
	# Wire up UI signals
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	language_dropdown.item_selected.connect(_on_language_selected)
	bgm_volume_slider.value_changed.connect(_on_bgm_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Pull directly from ConfigManager to set the visual states of the UI
	fullscreen_toggle.button_pressed = ConfigManager.get_setting("video", "fullscreen", false)
	var saved_locale: String = ConfigManager.get_setting("localization", "locale", "en")
	language_dropdown.selected = 0 if saved_locale == "en" else 1
	
	bgm_volume_slider.value = ConfigManager.get_setting("audio", "bgm_volume", 0.75)
	sfx_volume_slider.value = ConfigManager.get_setting("audio", "sfx_volume", 0.75)
	
	# Grab focus for your first menu item
	language_dropdown.grab_focus()


func _on_language_selected(index: int) -> void:
	var locale = "en" if index == 0 else "ja"
	TranslationServer.set_locale(locale)
	ConfigManager.save_setting("localization", "locale", locale)


func _on_bgm_volume_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index(BGM_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(bus_idx, value == 0.0)
	ConfigManager.save_setting("audio", "bgm_volume", value)


func _on_sfx_volume_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index(SFX_BUS_NAME)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(bus_idx, value == 0.0)
	ConfigManager.save_setting("audio", "sfx_volume", value)


func _on_fullscreen_toggled(is_pressed: bool) -> void:
	if is_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Save the preference to disk instantly
	ConfigManager.save_setting("video", "fullscreen", is_pressed)


func _on_close_pressed() -> void:
	if _previously_focused_node and is_instance_valid(_previously_focused_node):
		_previously_focused_node.grab_focus()
	queue_free()
