class_name UnitBase
extends Node2D

signal reached_hold_position

var data: UnitData
@export var move_speed: float = 70.0
@export var arrival_epsilon: float = 2.0

var hold_position: Vector2 = Vector2.ZERO
var slot_index: int = -1
var defense_line: DefenseLine = null
var is_holding: bool = false

func setup(line: DefenseLine, slot: int, target: Vector2, unit_data: UnitData) -> void:
	print("setup() called — target: ", target, " line: ", line)
	defense_line = line
	slot_index = slot
	hold_position = target
	data = unit_data
	print("hold_position is now: ", hold_position)

func _process(delta: float) -> void:
	if is_holding:
		return
	print("walking: pos=", global_position, " target=", hold_position, " delta=", delta)
	var to_target := hold_position - global_position
	if to_target.length() <= arrival_epsilon:
		global_position = hold_position
		_start_holding()
		return
	global_position += to_target.normalized() * move_speed * delta

func _start_holding() -> void:
	is_holding = true
	_on_hold()
	reached_hold_position.emit()

# Override in subclasses.
func _on_hold() -> void:
	pass

func die() -> void:
	if defense_line != null and slot_index >= 0:
		defense_line.release_slot(slot_index)
	queue_free()
