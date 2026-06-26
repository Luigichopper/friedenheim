extends Node

@export var iron_sword: WeaponData
@export var copper_sword: WeaponData
@export var raw_boar_meat: ConsumableData
@export var cooked_boar_meat: ConsumableData
@export var bat_wing: MaterialData

func _ready() -> void:
	# Give the player some items to test the system out!
	InventoryManager.add_item(iron_sword)
	InventoryManager.add_item(iron_sword)
	InventoryManager.add_item(copper_sword)
	InventoryManager.add_item(raw_boar_meat, 5)
	InventoryManager.add_item(cooked_boar_meat, 7)
	InventoryManager.add_item(bat_wing, 22)
