# res://src/core/run/run_state.gd
extends RefCounted
class_name RunState

var quest: QuestData
var party_hero_ids: Array[StringName] = []

## Snapshot taken at embark — same PartyInventory shape as the persistent
## one, but this instance is throwaway: never the same object reference as
## player_save_data.inventory, and never saved. `favorited`/can_be_sold-style
## concerns are simply never read here — nothing mid-run checks them, so an
## unused favorited dict costs nothing but a few bytes in memory.

var current_stage_index: int = 0
var loot_gained: Dictionary = {}
var xp_gained: Dictionary = {}
var active_effects: Dictionary = {}
