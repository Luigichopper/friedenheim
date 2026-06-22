# res://src/core/feeding_system.gd
extends RefCounted
class_name FeedingSystem

## Standalone matching logic for feeding a hero a consumable item. Lives apart
## from HeroData/HeroState/ItemData because it needs all three and shouldn't
## be owned by any single one of them.
##
## Rule: dislike tags always take priority over like tags. A food with both an
## elven tag (liked) and a meat tag (disliked) is judged purely on the dislike.
## This matches how taste actually works — one disliked ingredient tends to
## ruin a dish more than one liked ingredient redeems it.


## Pure evaluation — does not mutate anything. Looks only at hero.dietary_likes
## / hero.dietary_dislikes against item.dietary_tags.
static func evaluate_feeding(hero: HeroData, item: ItemData) -> HeroState.Mood:
	var has_dislike := false
	var has_like := false

	for tag: String in item.dietary_tags:
		if hero.dietary_dislikes.has(tag):
			has_dislike = true
		if hero.dietary_likes.has(tag):
			has_like = true

	# Dislike check comes first and returns immediately — this IS the
	# "negative takes priority" rule. A like match is never even considered
	# once a dislike is found.
	if has_dislike:
		return HeroState.Mood.SAD

	if has_like:
		return HeroState.Mood.HAPPY

	return HeroState.Mood.NEUTRAL


## Builds a short human-readable reason string for debug/UI display,
## e.g. "disliked: meat" or "liked: elven". Does not affect the mood result.
static func build_mood_reason(hero: HeroData, item: ItemData) -> String:
	var disliked_matches: Array[String] = []
	var liked_matches: Array[String] = []

	for tag: String in item.dietary_tags:
		if hero.dietary_dislikes.has(tag):
			disliked_matches.append(tag)
		if hero.dietary_likes.has(tag):
			liked_matches.append(tag)

	if not disliked_matches.is_empty():
		return "ate %s — disliked: %s" % [item.item_name, ", ".join(disliked_matches)]
	if not liked_matches.is_empty():
		return "ate %s — liked: %s" % [item.item_name, ", ".join(liked_matches)]
	return "ate %s — no strong opinion" % item.item_name


## Convenience wrapper: evaluates the feeding and applies the resulting mood
## directly to the given HeroState. This is the entry point most game code
## (and the debug screen) should actually call.
static func feed(hero: HeroData, item: ItemData, state: HeroState) -> void:
	var mood := evaluate_feeding(hero, item)
	var reason := build_mood_reason(hero, item)
	state.set_mood(mood, reason)
