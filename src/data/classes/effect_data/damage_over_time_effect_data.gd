# res://src/data/classes/effect_data/damage_over_time_effect_data.gd
extends EffectData
class_name DamageOverTimeEffectData

## Poison, burning, etc. — flat damage applied once per turn for duration_turns.
@export var damage_per_turn: int = 5
