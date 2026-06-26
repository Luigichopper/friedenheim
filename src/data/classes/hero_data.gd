# res://src/data/classes/hero_data.gd
extends Resource
class_name HeroData

## Authored, static definition of a hero. This is the "template" — YARD-registered,
## never mutated at runtime.
enum HeroClass { SWORDSMAN, RANGER, CLERIC, MAGE } # Added MAGE for classic fantasy comps

@export_group("Identity")
@export var hero_name: String
@export_multiline var lore_description: String
@export var portrait: Texture2D
@export var icon: Texture2D

@export_group("Class & Base Stats")
@export var hero_class: HeroClass = HeroClass.SWORDSMAN
## These are starting values. The Enhancement tab will use these + HeroState.level to calculate current stats.
@export var base_hp: int = 50
@export var base_accuracy: int = 5
@export var base_grit: int = 5
@export var base_attack: int = 5
@export var base_defense: int = 5

@export_group("Dietary Profiling")
@export var dietary_likes: Array[String] = []
@export var dietary_dislikes: Array[String] = []

@export_group("Combat Affinities")
## Tags describing what this hero is naturally good against/equipped for (e.g., ["ranged", "fire"]).
@export var element_affinities: Array[String] = []
@export var weapon_affinities: Array[WeaponData.WeaponType] = []

@export_group("Bond Skill Table")
## Maps bond rank (int) -> skill id (String).
@export var skills_by_bond_rank: Dictionary = {}

## Returns every skill id this hero has unlocked at or below the given rank.
func get_unlocked_skill_ids(current_bond_rank: int) -> Array[String]:
	var unlocked: Array[String] = []
	for rank: int in skills_by_bond_rank.keys():
		if rank <= current_bond_rank:
			unlocked.append(skills_by_bond_rank[rank])
	return unlocked
