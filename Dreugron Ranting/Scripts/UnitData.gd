class_name UnitData
extends Resource

@export var display_name: String = "Unit"
@export var icon: Texture2D
@export var unit_scene: PackedScene
@export var cost: float = 20.0
@export var cooldown: float = 2.0
@export var hold_offset: float = 0.0     # ranged units: stand behind the melee line
