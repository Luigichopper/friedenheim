extends Control

# Node References
@onready var story_mode_button: Button = $MarginContainer/MainLayout/MenuPanel/ButtonCluster/StoryModeButton
@onready var infinite_mode_button: Button = $MarginContainer/MainLayout/MenuPanel/ButtonCluster/InfiniteModeButton
@onready var settings_button: Button = $MarginContainer/MainLayout/MenuPanel/ButtonCluster/SettingsButton
@onready var exit_game_button: Button = $MarginContainer/MainLayout/MenuPanel/ButtonCluster/ExitGameButton
@onready var version_label: Label = $VersionLabel

func _ready() -> void:
	# Fetch version from project settings with a safe fallback and update the VersionLabel
	var game_version: String = ProjectSettings.get_setting("application/config/version", "v0.1.0-dev")
	version_label.text = game_version
	
	# Wire up button signals cleanly via code
	story_mode_button.pressed.connect(_on_story_mode_pressed)
	infinite_mode_button.pressed.connect(_on_infinite_mode_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_game_button.pressed.connect(_on_exit_game_pressed)
	
	# Automatically grab focus for controller/keyboard menu support
	story_mode_button.grab_focus()


func _on_story_mode_pressed() -> void:
	print("Loading Friedenheim Campaign...")


func _on_infinite_mode_pressed() -> void:
	print("Initializing Rogue-lite Loop...")


func _on_settings_pressed() -> void:
	# 1. Preload the settings visual scene file path
	var settings_scene = preload("res://src/shared/views/settings_overlay.tscn")
	
	# 2. Instantiate a copy clone of it into a live node instance
	var settings_instance = settings_scene.instantiate()
	
	# 3. Add it as a child to the current viewport scene tree view
	add_child(settings_instance)


func _on_exit_game_pressed() -> void:
	# Shuts down the game loop engine execution
	get_tree().quit()
