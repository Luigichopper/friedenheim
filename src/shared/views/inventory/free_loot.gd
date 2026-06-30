extends Node

@export var iron_sword: WeaponData
@export var copper_sword: WeaponData
@export var raw_boar_meat: ConsumableData
@export var cooked_boar_meat: ConsumableData
@export var bat_wing: MaterialData

func _ready() -> void:
	# Give the player some items to test the system out!
	InventoryManager.add_item("iron_sword", 1)
