# res://src/data/classes/armor_data.gd
extends ItemData
class_name ArmorData

@export_group("Combat")
@export var defense_power: int = 5
@export var base_durability: int = 100
## Bonus/penalty defense against specific enemy/combat affinities.
@export var affinity_defense: Dictionary = {}  # StringName affinity -> int bonus
@export var allowed_hero_classes: Array[HeroData.HeroClass] = []
