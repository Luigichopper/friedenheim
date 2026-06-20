# res://src/data/item_data.gd
extends Resource
class_name ItemData

enum Type { EQUIPMENT, CONSUMABLE, TOOL, MATERIAL }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export_group("Identity")
@export var item_name: String
@export_multiline var lore_description: String
@export var icon: Texture2D

@export_group("Economy & Mechanics")
@export var item_type: Type = Type.CONSUMABLE
@export var item_rarity: Rarity = Rarity.COMMON
@export var base_value: int = 10
