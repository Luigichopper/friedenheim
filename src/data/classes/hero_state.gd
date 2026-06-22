# res://src/data/classes/hero_state.gd
extends Resource
class_name HeroState

## Mutable, per-save runtime state for a single hero instance. This is what
## actually gets saved/loaded and changed during play. It never holds a direct
## reference to a HeroData object — only the string id — so it stays small,
## save-safe, and immune to going stale if HeroData is edited later.
##
## Usage: var template := HeroRegistryHelper.get_hero_data(state.hero_id)

enum Mood { HAPPY, NEUTRAL, SAD, UPSET }

@export_group("Identity Link")
## Matches the string id this hero is registered under in the YARD hero registry.
@export var hero_id: StringName

@export_group("Quest Progression")
@export var level: int = 1
@export var current_xp: int = 0
@export var xp_to_next_level: int = 100

@export_group("Bond Progression")
## Only the current rank/points live here. Which skills that rank unlocks is
## derived from HeroData.skills_by_bond_rank — never duplicated here.
@export var bond_rank: int = 0
@export var bond_points: int = 0
@export var bond_points_to_next_rank: int = 50

@export_group("Session Mood")
@export var current_mood: Mood = Mood.NEUTRAL
## Short human-readable reason, e.g. "ate elven rations" — for debug/UI display only,
## not used in any matching logic.
@export var mood_reason: String = ""

@export_group("Combat State")
@export var current_hp: int = 0
@export var is_benched: bool = false
## Reason a hero is benched, e.g. "recovering from Wyvern Peak". Empty if not benched.
@export var benched_reason: String = ""

@export_group("Loadout")
## Exactly one weapon and one armor slot — not a generic list — so the
## 1-weapon/1-armor rule is structurally enforced rather than just convention.
## Empty StringName ("") means the slot is unequipped.
@export var equipped_weapon_id: StringName = &""
@export var equipped_armor_id: StringName = &""


func add_xp(amount: int) -> void:
	current_xp += amount
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		level += 1
		xp_to_next_level = int(xp_to_next_level * 1.2)


func add_bond_points(amount: int) -> void:
	bond_points += amount
	while bond_points >= bond_points_to_next_rank:
		bond_points -= bond_points_to_next_rank
		bond_rank += 1
		bond_points_to_next_rank = int(bond_points_to_next_rank * 1.5)


func set_mood(new_mood: Mood, reason: String = "") -> void:
	current_mood = new_mood
	mood_reason = reason


## Equips an item into whichever slot matches its item_type. Returns false
## (and equips nothing) if the item isn't a WEAPON or ARMOR — this is the
## structural enforcement of "only weapons/armor can be equipped, and each
## goes in the one slot matching its type." item_id must be the same string
## id the item is registered under in the YARD item registry — callers should
## pass this through from their registry lookup, not derive it here.
func equip(item_id: StringName, item: ItemData) -> bool:
	match item.item_type:
		ItemData.Type.WEAPON:
			equipped_weapon_id = item_id
			return true
		ItemData.Type.ARMOR:
			equipped_armor_id = item_id
			return true
		_:
			return false


func unequip_weapon() -> void:
	equipped_weapon_id = &""


func unequip_armor() -> void:
	equipped_armor_id = &""
