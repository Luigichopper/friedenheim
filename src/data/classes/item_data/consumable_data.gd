# res://src/data/classes/consumable_data.gd
extends ItemData
class_name ConsumableData

@export_group("Feeding")
@export var saturation_value: int = 10
@export var dietary_tags: Array[String] = []
