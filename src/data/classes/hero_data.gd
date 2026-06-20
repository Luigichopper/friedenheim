# res://src/data/classes/hero_data.gd
extends Resource
class_name HeroData

@export_group("Identity")
@export var display_name: String = ""
@export_multiline var biography: String = ""

@export_group("Core Vitals")
@export var max_health: int = 100
@export var health: int = 100:
	set(val): health = clampi(val, 0, max_health)

@export var max_hunger: int = 100
@export var hunger: int = 100:
	set(val): hunger = clampi(val, 0, max_hunger)

@export var max_morale: int = 100
@export var morale: int = 100:
	set(val): morale = clampi(val, 0, max_morale)

@export_group("Dietary Quirks")
# Arrays of strings matching item tags (e.g., ["vegetarian", "elven"])
@export var loved_food_tags: Array[String] = []
@export var hated_food_tags: Array[String] = []
