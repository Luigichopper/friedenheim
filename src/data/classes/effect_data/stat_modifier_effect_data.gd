# res://src/data/classes/effect_data/stat_modifier_effect_data.gd
extends EffectData
class_name StatModifierEffectData

## Defense-up potion, attack-down debuff, etc. Multiplicative, consistent with
## how mood already scales base stats in CombatStats — so a hero affected by
## both mood and a stat effect just multiplies both factors together, no
## special-casing needed in CombatStats later.
@export var attack_multiplier: float = 1.0
@export var defense_multiplier: float = 1.0
