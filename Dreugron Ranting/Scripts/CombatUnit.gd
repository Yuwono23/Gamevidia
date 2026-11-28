class_name CombatUnit
extends UnitBase

@export var attack_range: float = 45.0
@export var attack_interval: float = 1.0
@export var damage: float = 10.0
@export var projectile_scene: PackedScene   # null = melee, instant hit
@export var enemy_group: StringName = &"enemies"

var _cooldown: float = 0.0

func _on_hold() -> void:
	# Desync attacks so a whole rank doesn't swing on the same frame.
	_cooldown = randf() * attack_interval

func _process(delta: float) -> void:
	super._process(delta)
	if not is_holding:
		return
	_cooldown = maxf(_cooldown - delta, 0.0)
	if _cooldown > 0.0:
		return
	var target := _find_target()
	if target == null:
		return
	_attack(target)
	_cooldown = attack_interval

func _find_target() -> Node2D:
	var best: Node2D = null
	var best_dist := attack_range
	for n in get_tree().get_nodes_in_group(enemy_group):
		var d := global_position.distance_to(n.global_position)
		if d <= best_dist:
			best = n
			best_dist = d
	return best

func _attack(target: Node2D) -> void:
	if projectile_scene == null:
		if target.has_method("take_damage"):
			target.take_damage(damage)
		return
	var p := projectile_scene.instantiate()
	p.global_position = global_position
	get_parent().add_child(p)
	if p.has_method("launch"):
		p.launch(target, damage)
