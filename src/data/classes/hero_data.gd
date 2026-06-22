# res://src/data/classes/hero_data.gd
extends Resource
class_name HeroData

## Authored, static definition of a hero. This is the "template" — YARD-registered,
## never mutated at runtime. Runtime-mutable state (current HP, mood, bond rank,
## equipped items) belongs on a separate HeroState, not here. See planning notes.

enum HeroClass { SWORDSMAN, RANGER, CLERIC }

@export_group("Identity")
@export var hero_name: String
@export_multiline var lore_description: String
@export var portrait: Texture2D

@export_group("Class & Base Stats")
@export var hero_class: HeroClass = HeroClass.SWORDSMAN
## Base stats grown via quest XP over time. These are starting values, not current values.
@export var base_hp: int = 50
@export var base_accuracy: int = 5
@export var base_grit: int = 5
@export var base_attack: int = 5
@export var base_defense: int = 5

@export_group("Dietary Profiling")
## Same string vocabulary as ItemData.dietary_tags — must match exactly for mood matching.
## Examples: ["elven", "vegetarian"]
@export var dietary_likes: Array[String] = []
## Examples: ["meat", "raw"]
@export var dietary_dislikes: Array[String] = []

@export_group("Combat Affinities")
## Tags describing what this hero is naturally good against/equipped for.
## Kept separate from dietary tags so the two vocabularies never collide.
## Examples: ["ranged", "fire"]
@export var combat_affinities: Array[String] = []

@export_group("Bond Skill Table")
## Maps bond rank (int) -> skill id (String). Authored per-hero here; HeroState
## only ever stores the *current rank*, never the unlocked list. Query this table
## with get_unlocked_skill_ids() to derive what's actually unlocked for a given rank.
@export var skills_by_bond_rank: Dictionary = {}


## Returns every skill id this hero has unlocked at or below the given rank.
func get_unlocked_skill_ids(current_bond_rank: int) -> Array[String]:
	var unlocked: Array[String] = []
	for rank: int in skills_by_bond_rank.keys():
		if rank <= current_bond_rank:
			unlocked.append(skills_by_bond_rank[rank])
	return unlocked
