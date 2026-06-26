# res://src/data/classes/item_data.gd
extends Resource
class_name ItemData

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export_group("Identity")
@export var item_name: String = "ITEM_text_NAME"
@export_multiline var lore_description: String = "ITEM_text_DESC"
@export var icon: Texture2D

@export_group("Economy")
@export var item_rarity: Rarity = Rarity.COMMON
@export var base_cost : int = 10
@export var weight: float = 1.0
@export var can_be_sold: bool = true

@export_group("Durability")
## 0 = item does not use durability and may stack freely.
## > 0 = item is a unique instance and never stacks, regardless of quantity logic elsewhere.
@export var base_durability: int = 0

func has_durability() -> bool:
	return base_durability > 0
