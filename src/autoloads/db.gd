# res://src/autoloads/db.gd
extends Node

## Reference your baked YARD registry files directly
const HEROES_REGISTRY = preload("res://src/data/registries/hero_registry.tres")
const ITEMS_REGISTRY = preload("res://src/data/registries/item_registry.tres")


## Retrieves a HeroData resource by its YARD string ID
func get_hero(hero_id: String) -> HeroData:
	if hero_id == "" or not HEROES_REGISTRY: 
		return null
	# FIXED: YARD API uses get_resource() to fetch from the lookup map
	return HEROES_REGISTRY.load_entry(hero_id) as HeroData


## Retrieves an ItemData (Weapon, Armor, Consumable) by its YARD string ID
func get_item(item_id: String) -> ItemData:
	if item_id == "" or not ITEMS_REGISTRY: 
		return null
	# FIXED: YARD API uses get_resource() to fetch from the lookup map
	return ITEMS_REGISTRY.load_entry(item_id) as ItemData
