# res://src/autoloads/inventory_manager.gd
extends Node

signal inventory_updated

## A convenient helper reference that points directly into the active save state
var stash: Array[InventoryItem]:
	get:
		if SaveManager.current_save:
			return SaveManager.current_save.shared_inventory
		return []


## Adds an item to the persistent shared stash by its YARD ID
func add_item(item_id: String, qty: int = 1) -> void:
	# FIXED: Look up the real template data asset from the YARD registry via DB autoload
	var item_asset = DB.get_item(item_id)
	if not item_asset: 
		print("Warning: Attempted to add non-existent item ID to stash: ", item_id)
		return
	
	var new_item = InventoryItem.new()
	new_item.item_id = item_id
	new_item.quantity = qty
	
	# Check if your custom item data class has a method or property for durability
	if item_asset.has_method("has_durability") and item_asset.has_durability():
		if "base_durability" in item_asset:
			new_item.current_durability = item_asset.base_durability
		
	# Try to stack if it doesn't use durability
	var can_stack = true
	if item_asset.has_method("has_durability"):
		can_stack = not item_asset.has_durability()
		
	if can_stack:
		for existing_item in stash:
			if existing_item.can_stack_with(new_item):
				existing_item.quantity += qty
				inventory_updated.emit()
				return
				
	# If unique or no matching stack found, append fresh slot
	stash.append(new_item)
	inventory_updated.emit()


## Filters items for your InventoryUI view tabs
func get_items_by_category(category_name: String) -> Array[InventoryItem]:
	if category_name.to_lower() == "all":
		return stash
		
	var filtered: Array[InventoryItem] = []
	for item in stash:
		if item.matches_type(category_name):
			filtered.append(item)
	return filtered
