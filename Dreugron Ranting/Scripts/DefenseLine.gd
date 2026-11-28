class_name DefenseLine
extends Node2D

signal occupancy_changed(occupied: int, capacity: int)

@export var front_x: float = 620.0        # local X of rank 0 (front line)
@export var units_per_rank: int = 3
@export var rank_spacing: float = 70.0    # how far back each rank sits
@export var max_ranks: int = 4
@export var depth_spread: float = 26.0    # Y offset between units in a rank

var _occupancy: Dictionary = {}           # slot index -> unit

func capacity() -> int:
	return units_per_rank * max_ranks

func has_free_slot() -> bool:
	return _occupancy.size() < capacity()

func reserve_slot(unit: Node) -> int:
	for i in capacity():
		if not _occupancy.has(i):
			_occupancy[i] = unit
			occupancy_changed.emit(_occupancy.size(), capacity())
			return i
	queue_redraw()
	return -1

func release_slot(index: int) -> void:
	if _occupancy.erase(index):
		occupancy_changed.emit(_occupancy.size(), capacity())
		reflow()
	queue_redraw()

func slot_position(index: int, hold_offset: float = 0.0) -> Vector2:
	var rank := index / units_per_rank
	var col := index % units_per_rank
	var x := front_x - float(rank) * rank_spacing - hold_offset
	var y := (float(col) - (units_per_rank - 1) / 2.0) * depth_spread
	return global_position + Vector2(x, y)
	

func reflow() -> void:
	var units := _occupancy.values()
	units.sort_custom(func(a, b): return a.global_position.x > b.global_position.x)
	_occupancy.clear()
	for i in units.size():
		_occupancy[i] = units[i]
		if units[i] is UnitBase:
			units[i].hold_position = slot_position(i, 0.0)
			units[i].is_holding = false   # resume walking

func _draw() -> void:
	# Draw slots in local space (this node's origin).
	for i in capacity():
		var local_pos := slot_position(i) - global_position
		var color := Color(0.3, 0.8, 1.0, 0.5) if _occupancy.has(i) else Color(1.0, 1.0, 1.0, 0.25)
		draw_circle(local_pos, 6.0, color)
	# Front line marker
	draw_line(Vector2(front_x, -80), Vector2(front_x, 80), Color(1, 0.4, 0.4, 0.6), 2.0)
