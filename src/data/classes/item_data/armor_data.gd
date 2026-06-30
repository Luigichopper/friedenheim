# res://src/data/classes/armor_data.gd
extends ItemData
class_name ArmorData

enum ArmorType {HEAD, CHEST, LEGS, NECK}

@export_group("Combat")
## The flat rate addition to defense per armor instance.
@export var defense_power: int = 5
@export var allowed_hero_classes: Array[HeroData.HeroClass] = []
@export var armor_type: ArmorType = ArmorType.HEAD
## Provides a bonus if full a set is equipped, not required.
@export var armor_set_name: String = ""
