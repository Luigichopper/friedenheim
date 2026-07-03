# res://src/data/classes/weapon_data.gd
extends ItemData
class_name WeaponData

enum WeaponType {LONGSWORD, BATTLEAXE, DAGGERS, SPEAR, SHORTBOW, LONGBOW, CROSSBOW, GRIMOIRE, STAFF}
enum Element {NONE, FIRE, EARTH, WIND, WATER}

@export_group("Combat")
@export var weapon_type: WeaponType = WeaponType.LONGSWORD
@export var elemental_affinity: Element = Element.NONE
@export var attack_power: int = 5

@export_subgroup("Secondary Stats")
@export var crit_rate: float = 0.05
@export var crit_damage_mult: float = 1.5
## Percentage of enemy armor ignored (0.0 = 0%, 0.4 = 40%)
@export var armor_pierce: float = 0.0
## Flat accuracy modification for this weapon type
@export var accuracy_modifier: float = 0.0
## How much this weapon slows down the character's internal action tick speed
@export var speed_penalty: float = 0.0

@export_group("Restrictions")
## Which hero classes can equip this. Empty = no restriction.
@export var allowed_hero_classes: Array[HeroData.HeroClass] = []
