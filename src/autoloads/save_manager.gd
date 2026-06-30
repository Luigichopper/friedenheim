# res://src/autoloads/save_manager.gd
extends Node

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "save_slot_1.tres"

## The active persistent save state containing our roster, items, gold, etc.
var current_save: SaveGameData


func _ready() -> void:
	# Ensure the target directory exists on the player's native filesystem
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)
		
	# Automatically attempt to parse an existing file on boot
	if load_game() != OK:
		print("No valid save profile found. Initializing a pristine new game...")
		initialize_new_game()


## Prepares a completely fresh save file with starting heroes and items via YARD IDs
func initialize_new_game() -> void:
	current_save = SaveGameData.new()
	current_save.player_gold = 150 # Starting allowance (1g 5s)
	
	# 1. Instantiate your starting roster using flat YARD string IDs
	var starting_hero_ids: Array[String] = ["eisen", "vyr", "wise"]
	
	for id in starting_hero_ids:
		var fresh_hero = HeroInstance.new()
		fresh_hero.hero_id = id
		fresh_hero.level = 1
		fresh_hero.status = HeroInstance.AssignmentStatus.BENCHED
		
		# Look up base HP from YARD via our DB wrapper to initialize current hit points
		var base_data = fresh_hero.get_static_data()
		if base_data:
			fresh_hero.current_hp = base_data.base_hp
			
		current_save.roster.append(fresh_hero)
		
	# 2. Populate your starting vault stash using the InventoryManager
	# This safely pipes through the serializable InventoryItem architecture
	InventoryManager.add_item("iron_sword", 1)
	InventoryManager.add_item("cooked_boar_meat", 3)
	InventoryManager.add_item("minor_health_potion", 2)
		
	# Instantly commit the initialized baseline state to disk
	save_game()


## Collects permanent profile data and flattens it directly into a local .tres file
func save_game() -> Error:
	if not current_save:
		print("CRITICAL: Cannot save, current_save state object is uninitialized.")
		return ERR_INVALID_DATA
		
	var path = SAVE_DIR + SAVE_FILE_NAME
	
	# FIXED: Removed FLAG_BUNDLE_RESOURCES to prevent script metadata duplication
	var error = ResourceSaver.save(current_save, path)
	
	if error == OK:
		print("Permanent Profile Saved Successfully to: ", path)
	else:
		print("CRITICAL: Failed to write save file! Error code: ", error)
		
	return error
	

## Loads the saved custom resource from disk and re-caches it into active execution memory
func load_game() -> Error:
	var path = SAVE_DIR + SAVE_FILE_NAME
	if not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND
		
	# REPLACE mode ensures we clear stale references in cache memory upon execution
	var loaded_resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	if loaded_resource is SaveGameData:
		current_save = loaded_resource
		print("Game Loaded Natively. Roster entries count: ", current_save.roster.size())
		return OK
		
	print("CRITICAL: Loaded file was corrupted or not valid SaveGameData.")
	return ERR_FILE_CORRUPT
