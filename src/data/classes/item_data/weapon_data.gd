# res://src/data/classes/weapon_data.gd
extends ItemData
class_name WeaponData

enum WeaponType {LONGSWORD, BATTLEAXE, DAGGERS, SPEAR, SHORTBOW, LONGBOW, CROSSBOW, GRIMOIRE, STAFF}

@export_group("Combat")
@export var attack_power: int = 5
@export var crit_rate: float = 0.05
@export var crit_damage_mult: float = 1.5
## Which hero classes can equip this. Empty = no restriction.
@export var allowed_hero_classes: Array[HeroData.HeroClass] = []
@export var weapon_type: WeaponType = WeaponType.LONGSWORD
