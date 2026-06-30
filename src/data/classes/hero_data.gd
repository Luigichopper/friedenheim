# res://src/data/classes/hero_data.gd
extends Resource
class_name HeroData

## Authored, static definition of a hero. This is the "template" — YARD-registered,
## never mutated at runtime.
enum HeroClass { SWORDSMAN, RANGER, CLERIC, MAGE }

enum ElementType { NONE, FIRE, WATER, EARTH, WIND, LIGHT, DARK }


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
@export var dietary_likes: Array[ConsumableData.DietaryTag] = []
@export var dietary_dislikes: Array[ConsumableData.DietaryTag] = []

@export_group("Combat Affinities")
@export var element_affinities: Array[ElementType] = []
@export var weapon_affinities: Array[WeaponData.WeaponType] = []

@export_group("Bond Skill Table")
## Maps bond rank (int) -> skill id (String).
@export var skills_by_bond_rank: Dictionary[int, String] = {}

## Returns every skill id this hero has unlocked at or below the given rank.
func get_unlocked_skill_ids(current_bond_rank: int) -> Array[String]:
	var unlocked: Array[String] = []
	for rank in skills_by_bond_rank:
		# Explicitly cast to int during the comparison if needed, 
		# or let GDScript handle the variant matching safely
		if int(rank) <= current_bond_rank:
			# Ensure the payload is treated as a String
			unlocked.append(str(skills_by_bond_rank[rank]))
	return unlocked
