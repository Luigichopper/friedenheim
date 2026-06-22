# res://src/data/classes/enemy_data.gd
extends Resource
class_name EnemyData

@export_group("Identity")
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Base Combat Stats")
@export var base_health: int = 50
@export var base_attack: int = 10
@export var base_speed: int = 10

@export_group("Loot Table Calculations")
@export var guaranteed_drops: Array[StringName] = []
@export var chance_drop_pool: Array[StringName] = []
@export_range(0.0, 1.0) var chance_drop_rate: float = 0.25
