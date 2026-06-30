# res://src/data/classes/consumable_data.gd
extends ItemData
class_name ConsumableData

enum DietaryTag {RAW, COOKED, MEAT, VEGETABLE, FRUIT, SWEET, SOUR, SALTY, BITTER, UMAMI, SPICY, ELVEN, DWARVEN}

@export_group("Feeding")
@export var saturation_value: int = 10
@export var dietary_tags: Array[DietaryTag] = []
