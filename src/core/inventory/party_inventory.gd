# res://src/core/inventory/party_inventory.gd
extends Resource
class_name PartyInventory

## Mutable, savable runtime inventory — shared by the whole party, not owned
## by any individual hero (matching the game's "manager owns the stock"
## framing: heroes are assigned gear/food from this shared pool at prep time).
##
## Sparse by construction: an item_id is only a key here if quantity > 0.
## Never iterate "every possible item" to check ownership — check this map.
## Mutation should go through InventorySystem, not direct dictionary edits,
## so the "never negative" rule lives in exactly one place.

## StringName item_id (matching the YARD item registry) -> quantity owned (int).
@export var quantities: Dictionary = {}
