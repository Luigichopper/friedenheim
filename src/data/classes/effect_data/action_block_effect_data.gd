# res://src/data/classes/effect_data/action_block_effect_data.gd
extends EffectData
class_name ActionBlockEffectData

## Sleep, paralysis, blindness, etc. — anything that prevents or impairs
## acting rather than changing a stat number. Kept as two independent bools
## rather than an enum since blindness and sleep aren't mutually exclusive
## categories — a hero could plausibly have both at once.
@export var prevents_acting: bool = true
## If true, this is an accuracy-style impairment (e.g. blindness) rather than
## a full action lock (e.g. sleep) — combat resolution decides what to do
## with this distinction; EffectData just describes it.
@export var causes_miss_chance: bool = false
@export var miss_chance: float = 0.5
