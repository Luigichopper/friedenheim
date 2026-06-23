# res://src/data/classes/effect_data/effect_data.gd
extends Resource
class_name EffectData

## Authored, static definition of a status effect — poison, blindness, sleep,
## a defense buff, etc. This is the template, same relationship to runtime
## effect state as HeroData is to HeroState: this never changes at runtime,
## only how many turns are left on an active instance does.
##
## Concrete behavior lives on subclasses (DamageOverTimeEffectData,
## StatModifierEffectData, ActionBlockEffectData) — this base only holds
## what's true of every effect regardless of what it does.

@export_group("Identity")
@export var effect_name: String
@export_multiline var lore_description: String
@export var icon: Texture2D

@export_group("Duration")
## Fixed length in turns/stages. Ticks down once per turn; expires at 0.
@export var duration_turns: int = 3

## True if disliking this effect would never make sense (e.g. you can't apply a
## debuff and a buff with the same id and have them cancel) — kept simple for
## now: each active effect on a hero is tracked independently by effect id, no
## stacking-rule field yet since you don't have a stacking case in mind yet.
