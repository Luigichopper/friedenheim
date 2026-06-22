# res://src/core/inventory/inventory_system.gd
extends RefCounted
class_name InventorySystem

## Centralized mutation logic for PartyInventory. All quantity changes should
## go through here rather than touching PartyInventory.quantities directly —
## this is the one place "never go negative" and "remove the key at zero" are
## enforced, so every caller (shop, feeding, equipping, loot) behaves
## consistently without duplicating that logic.


## Adds amount (must be >= 1) of item_id to the inventory.
static func add_item(inventory: PartyInventory, item_id: StringName, amount: int = 1) -> void:
	if amount < 1:
		push_warning("InventorySystem.add_item called with amount < 1: %d" % amount)
		return

	var current: int = inventory.quantities.get(item_id, 0)
	inventory.quantities[item_id] = current + amount


## Removes up to amount of item_id from the inventory. Returns true if the
## full amount was available and removed, false if there wasn't enough —
## in the false case, nothing is removed at all (all-or-nothing), so callers
## don't need to handle a partial-removal state.
static func remove_item(inventory: PartyInventory, item_id: StringName, amount: int = 1) -> bool:
	if amount < 1:
		push_warning("InventorySystem.remove_item called with amount < 1: %d" % amount)
		return false

	var current: int = inventory.quantities.get(item_id, 0)
	if current < amount:
		return false

	var remaining := current - amount
	if remaining == 0:
		inventory.quantities.erase(item_id)
	else:
		inventory.quantities[item_id] = remaining

	return true


static func get_quantity(inventory: PartyInventory, item_id: StringName) -> int:
	return inventory.quantities.get(item_id, 0)


static func has_quantity(inventory: PartyInventory, item_id: StringName, amount: int = 1) -> bool:
	return get_quantity(inventory, item_id) >= amount


## Returns every item_id currently owned (quantity > 0), as an Array[StringName].
## Safe to call even on an empty inventory.
static func get_owned_item_ids(inventory: PartyInventory) -> Array[StringName]:
	var ids: Array[StringName] = []
	for item_id: StringName in inventory.quantities.keys():
		ids.append(item_id)
	return ids
