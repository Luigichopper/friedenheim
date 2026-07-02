# res://src/core/inventory/inventory_item.gd
extends Resource
class_name InventoryItem

@export_group("Data Reference")
## The unique YARD identifier string for the item template asset (e.g., "iron_sword").
@export var item_id: String = ""
@export var quantity: int = 1

@export_group("Dynamic State")
## Mutable attributes modifying this explicit item row instance
@export var current_durability: int = 0
var equipped_by_hero_name: String = ""


## Explicit wrapper to safely resolve underlying item properties from our DB autoload framework.
func get_static_data() -> ItemData:
	if item_id == "":
		return null
	return DB.get_item(item_id)


## Computed pseudo-property property wrapper matching your existing view nodes and UI loops.
var data: ItemData:
	get:
		return get_static_data()


## Evaluates whether two runtime item references are eligible to stack together inside inventory nodes.
func can_stack_with(other: InventoryItem) -> bool:
	var my_static = get_static_data()
	var other_static = other.get_static_data()
	
	if not my_static or not other_static: 
		return false
		
	# Durability-bearing items are completely unique instances and cannot stack
	if my_static.has_durability() or other_static.has_durability():
		return false
		
	return item_id == other.item_id


## Type classification matcher utilized dynamically by the inventory system category filters.
func matches_type(type_string: String) -> bool:
	var d = get_static_data()
	if not d: 
		return false
	
	match type_string.to_lower():
		"weapon": return d is WeaponData
		"armor": return d is ArmorData
		"food", "consumable": return d is ConsumableData
		"potion": return d is PotionData
		"material": return d is MaterialData
		_: return false


## Damages or repairs the item by a set number of ticks
func modify_durability(amount: int) -> void:
	var static_data = get_static_data()
	if not static_data or not static_data.has_method("has_durability") or not static_data.has_durability():
		return # Can't damage something that doesn't track durability
		
	var max_durability = static_data.base_durability if "base_durability" in static_data else 100
	current_durability = clampi(current_durability + amount, 0, max_durability)


## Quick check to see if the item is completely broken
func is_broken() -> bool:
	return current_durability <= 0
