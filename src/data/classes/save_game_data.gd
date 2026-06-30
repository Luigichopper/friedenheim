# res://src/data/systems/save_game_data.gd
extends Resource
class_name SaveGameData

@export_group("Party & Roster")
## Contains all recruited heroes (Benched, Deployed, or Dead)
@export var roster: Array[HeroInstance] = []

@export_group("Inventory Stash")
## The shared player vault stash. Natively saves all items, quantities, and durabilities.
@export var shared_inventory: Array[InventoryItem] = []

@export_group("Economy & Meta")
@export var player_gold: int = 150
@export var game_version: String = ProjectSettings.get_setting("application/config/version", "v0.1.0-dev")
