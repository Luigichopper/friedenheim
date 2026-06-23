# res://src/core/combat_stats.gd
extends RefCounted
class_name CombatStats

## Computes effective combat stats from a HeroData template + HeroState
## loadout + current mood. Effective stats are never stored — always derived
## fresh — so there's no risk of a stat going stale after a re-equip or mood
## change. Lives apart from HeroData/HeroState because it needs all three,
## plus resolved ItemData for whatever is currently equipped.
##
## Formula: effective_stat = round(base_stat * mood_multiplier) + gear_bonus
## Mood only scales the hero's BASE stat. Gear bonuses are always flat and
## fully reliable regardless of mood — this is deliberate: gear is meant to
## be the dependable, prep-driven lever, and mood is the volatile one. A
## well-equipped hero in a bad mood should still hit hard; mood only swings
## what the character contributes on their own.
##
## Callers are responsible for resolving equipped_weapon_id/equipped_armor_id
## to actual ItemData (e.g. via the item registry) and passing them in — this
## keeps CombatStats free of any direct registry dependency.

## Single source of truth for mood balance. Change values here only —
## nowhere else in the codebase should hardcode a mood percentage.
const MOOD_MULTIPLIERS := {
	HeroState.Mood.HAPPY: 1.15,
	HeroState.Mood.NEUTRAL: 1.0,
	HeroState.Mood.SAD: 0.85,
	HeroState.Mood.UPSET: 0.70,
}


static func get_mood_multiplier(mood: HeroState.Mood) -> float:
	return MOOD_MULTIPLIERS.get(mood, 1.0)


## weapon may be null if nothing is equipped in that slot.
static func get_effective_attack(hero: HeroData, weapon: ItemData, mood: HeroState.Mood) -> int:
	var mood_scaled_base := roundi(hero.base_attack * get_mood_multiplier(mood))

	var gear_bonus := 0


	return mood_scaled_base + gear_bonus


## armor may be null if nothing is equipped in that slot.
static func get_effective_defense(hero: HeroData, armor: ItemData, mood: HeroState.Mood) -> int:
	var mood_scaled_base := roundi(hero.base_defense * get_mood_multiplier(mood))

	var gear_bonus := 0


	return mood_scaled_base + gear_bonus
