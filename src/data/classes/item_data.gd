# res://src/data/classes/item_data.gd
extends Resource
class_name ItemData

## WEAPON and ARMOR are equip-slot categories in their own right — there is no
## separate "equipment_slot" field. item_type alone tells you both what kind
## of item this is AND which equip slot it fills, when applicable. There is
## no TOOL category; non-weapon/non-armor gear is out of scope for now and
## should be represented as CONSUMABLE or MATERIAL if it ever comes back.
enum Type { WEAPON, ARMOR, CONSUMABLE, MATERIAL }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export_group("Identity")
@export var item_name: String
@export_multiline var lore_description: String
@export var icon: Texture2D

@export_group("Economy & Mechanics")
@export var item_type: Type = Type.CONSUMABLE
@export var item_rarity: Rarity = Rarity.COMMON
@export var base_value: int = 10
@export var weight: float = 1.0

@export_group("Equipment")
## Flat stat bonus applied while equipped. Only meaningful when item_type is
## WEAPON or ARMOR. Meaning depends on item_type: WEAPON -> added to attack,
## ARMOR -> added to defense. Ignored for CONSUMABLE/MATERIAL.
@export var power_value: int = 0

@export_group("Dietary Profiling")
## Examples: ["meat", "raw"], ["vegetarian", "elven"], ["cooked"]
@export var dietary_tags: Array[String] = []
