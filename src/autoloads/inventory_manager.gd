# res://src/inventory/inventory_manager.gd
extends Node

# The master list holding instances of InventoryItem
var contents: Array[InventoryItem] = []

signal inventory_updated

## Adds an item to the inventory
func add_item(item_data: ItemData, quantity: int = 1) -> void:
	# Non-equippable items like materials or consumables can stack
	if not (item_data is WeaponData or item_data is ArmorData):
		for item in contents:
			if item.data == item_data:
				item.quantity += quantity
				inventory_updated.emit()
				return
				
	# Weapons, armor, or unique stack items get their own separate slots
	var new_slot = InventoryItem.new(item_data, quantity)
	contents.append(new_slot)
	inventory_updated.emit()

## Removes an item/quantity from the inventory
func remove_item(inventory_item: InventoryItem, quantity: int = 1) -> void:
	if inventory_item in contents:
		inventory_item.quantity -= quantity
		if inventory_item.quantity <= 0:
			contents.erase(inventory_item)
		inventory_updated.emit()

## Returns a filtered array based on item class category
func get_items_by_category(category: String) -> Array[InventoryItem]:
	if category.to_lower() == "all":
		return contents
		
	var filtered: Array[InventoryItem] = []
	for item in contents:
		if item.matches_type(category):
			filtered.append(item)
	return filtered
