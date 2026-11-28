class_name DeploymentManager
extends Node2D

signal unit_deployed(unit: Node2D, data: UnitData)
signal deployment_failed(data: UnitData, reason: String)

@export var spawn_point: Node2D
@export var unit_container: Node2D
@export var defense_line: DefenseLine

var _cooldowns: Dictionary = {}   # UnitData -> seconds remaining

func _process(delta: float) -> void:
	for key in _cooldowns.keys():
		_cooldowns[key] = maxf(_cooldowns[key] - delta, 0.0)

func is_on_cooldown(data: UnitData) -> bool:
	return cooldown_remaining(data) > 0.0

func cooldown_remaining(data: UnitData) -> float:
	return _cooldowns.get(data, 0.0)

func cooldown_fraction(data: UnitData) -> float:
	if data == null or data.cooldown <= 0.0:
		return 0.0
	return cooldown_remaining(data) / data.cooldown

func try_deploy(data: UnitData) -> bool:
	if data == null or data.unit_scene == null:
		push_error("try_deploy: UnitData or unit_scene missing")
		return false
	if is_on_cooldown(data):
		deployment_failed.emit(data, "on_cooldown")
		return false
	if defense_line != null and not defense_line.has_free_slot():
		deployment_failed.emit(data, "line_full")
		return false
	if not EnergyManager.spend(data.cost):
		deployment_failed.emit(data, "not_enough_energy")
		return false

	var unit := data.unit_scene.instantiate()
	var target_parent: Node = unit_container if unit_container != null else get_parent()
	target_parent.add_child(unit)

	var spawn_pos: Vector2 = spawn_point.global_position
	if unit is Node2D:
		unit.global_position = spawn_pos

	print("=== DEPLOY ===")
	print("unit: ", unit, " | is UnitBase: ", unit is UnitBase)
	print("defense_line: ", defense_line)
	print("data: ", data, " | has hold_offset: ", data != null and "hold_offset" in data)

	if defense_line != null and unit is UnitBase:
		var slot := defense_line.reserve_slot(unit)
		# ── THIS is the defensive line ──
		var offset: float = data.hold_offset if "hold_offset" in data else 0.0
		var target_pos := defense_line.slot_position(slot, offset)
		print("slot: ", slot, " | offset: ", offset, " | target_pos: ", target_pos)
		unit.setup(defense_line, slot, target_pos, data)
	elif unit is UnitBase and spawn_point != null:
		var fallback_target := spawn_pos + Vector2(300.0, 0.0)
		print("FALLBACK branch — target: ", fallback_target)
		unit.setup(null, -1, fallback_target, data)
	else:
		print("NEITHER branch ran — unit is not a UnitBase!")

	_cooldowns[data] = data.cooldown
	unit_deployed.emit(unit, data)
	return true
