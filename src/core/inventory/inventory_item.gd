# res://src/core/inventory/inventory_item.gd
extends RefCounted
class_name InventoryItem

var data: ItemData
var quantity: int = 1

# Dynamic states that change per-item instance
var current_durability: int = 0

func _init(item_data: ItemData, qty: int = 1):
	data = item_data
	quantity = qty
	if data.has_durability():
		current_durability = data.base_durability

## Durability-bearing items are always unique instances and never stack.
func can_stack_with(other: InventoryItem) -> bool:
	if data.has_durability() or other.data.has_durability():
		return false
	return data == other.data

## Helper function to check if this item belongs to a specific tab type
func matches_type(type_string: String) -> bool:
	match type_string.to_lower():
		"weapon": return data is WeaponData
		"armor": return data is ArmorData
		"food", "consumable": return data is ConsumableData
		"potion": return data is PotionData
		"material": return data is MaterialData
		_: return false
