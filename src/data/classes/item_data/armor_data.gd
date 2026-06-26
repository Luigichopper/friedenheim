# res://src/data/classes/armor_data.gd
extends ItemData
class_name ArmorData

enum ArmorType {HEAD, CHEST, LEGS, NECKLACE}

@export_group("Combat")
@export var defense_power: int = 5
@export var allowed_hero_classes: Array[HeroData.HeroClass] = []
@export var armor_type: ArmorType = ArmorType.HEAD
