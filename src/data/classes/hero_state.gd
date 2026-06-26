# res://src/data/classes/hero_state.gd
extends Resource
class_name HeroState

## Mutable, per-save runtime state for a single hero instance. This is what
## actually gets saved/loaded between runs. It never holds a direct reference
## to a HeroData object — only the string id — so it stays small, save-safe,
## and immune to going stale if HeroData is edited later.
##
## Deliberately does NOT track anything that only exists mid-run (active
## status effects, current target, turn counters, etc.) — that's RunState's
## job, and RunState is never saved. By the time a run ends, every mid-run
## detail has already resolved into a change to the fields below (HP lost,
## XP gained, loot committed) or been discarded entirely (on death).
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

@export_group("Persistent Health")
## Does NOT regenerate between runs. Must be restored via a paid heal
## service or item use outside of a run. A hero embarking with low HP is a
## real, visible risk the player chose to accept.
@export var current_hp: int = 0

@export_group("Availability")
## Temporarily unavailable for party selection — e.g. "recovering from Wyvern
## Peak" — but NOT a death state. A benched hero is still alive and can still
## eventually become selectable again once benched_reason resolves (whatever
## resolves it is a future system; this is just the flag + reason it reads).
@export var is_benched: bool = false
@export var benched_reason: String = ""

## Distinct from is_benched on purpose: a dead hero needs a revival action
## (future system, more significant than a normal heal) before they can be
## selected again — being benched does not imply death, and being healed
## off 0 HP is not the same action as being revived from death. Reaching
## 0 HP does not automatically set this; see take_damage() below for why.
@export var is_dead: bool = false


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


enum ArmorType { HEAD, CHEST, LEGS, NECKLACE }

@export_group("Loadout")
## Exactly one weapon slot — not a generic list — so the 1-weapon rule is
## structurally enforced rather than just convention. Empty StringName ("")
## means the slot is unequipped.
@export var equipped_weapon_id: StringName = &""

## One armor slot per ArmorType, keyed by the enum above — so "at most one
## HEAD, one CHEST, one LEGS, one NECKLACE" is structurally enforced rather
## than just convention, the same way the old single equipped_armor_id
## enforced "at most one armor total." An empty StringName ("") for a given
## type means that slot is unequipped. All four keys are present from
## construction (rather than populated lazily) so callers can always index
## any ArmorType without a "key not found" check.
@export var equipped_armor_ids: Dictionary = {
	ArmorType.HEAD: &"",
	ArmorType.CHEST: &"",
	ArmorType.LEGS: &"",
	ArmorType.NECKLACE: &"",
}


## Equips an item into whichever slot matches its concrete type. Returns false
## (and equips nothing) if the item is neither WeaponData nor ArmorData — this
## is the structural enforcement of "only weapons/armor can be equipped, and
## each goes in the slot matching its type (and, for armor, its armor_type)."
## item_id must be the same string id the item is registered under in the
## YARD item registry.
##
## NOTE: this assumes ArmorData exposes an `armor_type: ArmorType` field so
## this can pick the right slot. I don't have the ArmorData source to verify
## that field exists under that name — add it if missing, or tell me the
## real property name and I'll wire it up correctly.
func equip(item_id: StringName, item: ItemData) -> bool:
	if item is WeaponData:
		equipped_weapon_id = item_id
		return true
	elif item is ArmorData:
		equipped_armor_ids[item.armor_type] = item_id
		return true
	return false


func unequip_weapon() -> void:
	equipped_weapon_id = &""


## Unequips whatever occupies the given armor slot, e.g.
## unequip_armor(ArmorType.HEAD). No-op if that slot was already empty.
func unequip_armor(armor_type: ArmorType) -> void:
	equipped_armor_ids[armor_type] = &""


## Convenience read accessor for a single slot, e.g.
## get_equipped_armor(ArmorType.CHEST). Returns "" if that slot is empty.
func get_equipped_armor(armor_type: ArmorType) -> StringName:
	return equipped_armor_ids.get(armor_type, &"")


## Applies damage and clamps at 0 — but does NOT set is_dead. Death is a
## deliberate, separate decision made by whatever called this (e.g. combat
## resolution checking "did this hero just hit 0 HP this turn" once, rather
## than every single HP mutation site needing to ask "should this hero die
## now"). This keeps HeroState a passive data holder: it tracks the numbers
## correctly, but doesn't decide game-rule consequences of those numbers.
func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)


func heal(amount: int, max_hp: int) -> void:
	if is_dead:
		push_warning("HeroState.heal() called on a dead hero (%s) — use revive() instead." % hero_id)
		return
	current_hp = min(max_hp, current_hp + amount)


## Marks this hero dead and unavailable for party selection. Does not clear
## HP, equipment, or progression — death is a state layered on top of an
## otherwise-intact hero, reversible by a future revival system.
func mark_dead() -> void:
	is_dead = true
	current_hp = 0


## Reverses mark_dead(). Caller is responsible for deciding starting HP
## (e.g. a revival item/service might restore partial vs. full HP) — this
## only clears the flag.
func revive(restored_hp: int) -> void:
	is_dead = false
	current_hp = restored_hp


## Single source of truth for "can this hero currently be selected into a
## party." Checked by HeroParty so the eligibility rule lives in exactly one
## place instead of being re-derived ad hoc by every screen that lists heroes.
func is_available_for_party() -> bool:
	return not is_dead and not is_benched
