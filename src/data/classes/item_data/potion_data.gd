# res://src/data/classes/item_data/potion_data.gd
extends ItemData
class_name PotionData

@export_group("Effect")
## What this potion does on use. See EffectData below.
@export var grants_effect: EffectData = null
## If true, this potion removes a currently-active effect rather than applying one
## (e.g. an antidote). When true, `grants_effect` is ignored and `cures_effect_id`
## is used instead.
@export var is_cure: bool = false
@export var cures_effect_id: StringName = &""
