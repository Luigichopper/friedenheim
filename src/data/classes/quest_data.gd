# res://src/data/classes/quest_data.gd
extends Resource
class_name QuestData

## Placeholder — authored quest/venture template. Real shape (stage graph,
## power level inputs, per-slot enemy pools, end-chest loot table) is still
## an open design question as of this point in development. This stub
## exists only so RunState and other in-progress systems have a type to
## reference without parse errors; expect this file to be substantially
## rewritten once quest generation is actually designed.
@export var quest_name: String = ""
