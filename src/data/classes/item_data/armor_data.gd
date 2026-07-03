# res://src/data/classes/armor_data.gd
extends ItemData
class_name ArmorData

enum ArmorType {HEAD, CHEST, LEGS, NECK}

@export_group("Combat")
@export var armor_type: ArmorType = ArmorType.HEAD
## The flat rate addition to defense per armor instance.
@export var defense_power: int = 5

@export_subgroup("Secondary Stats")
## Increases the wearer's chance to completely nullify physical hits
@export var dodge_modifier: float = 0.0
## Heavy pieces (like Copper) will increase stamina cost or slow down turn gauge ticks
@export var speed_penalty: float = 0.0

@export_group("Set Configuration")
## Provides a bonus if full a set is equipped, not required.
@export var armor_set_name: String = ""

@export_group("Restrictions")
@export var allowed_hero_classes: Array[HeroData.HeroClass] = []
