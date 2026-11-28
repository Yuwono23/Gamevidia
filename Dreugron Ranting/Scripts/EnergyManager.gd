extends Node

signal energy_changed(current: float, maximum: float)
signal energy_spent(amount: float)

@export var max_energy: float = 100.0
@export var regen_per_second: float = 10.0
@export var starting_energy: float = 20.0

var energy: float = 0.0
var regen_bonus: float = 0.0   # for future "generator" units

func _ready() -> void:
	energy = starting_energy
	energy_changed.emit(energy, max_energy)

func _process(delta: float) -> void:
	if energy >= max_energy:
		return
	energy = minf(energy + (regen_per_second + regen_bonus) * delta, max_energy)
	energy_changed.emit(energy, max_energy)

func can_afford(amount: float) -> bool:
	return energy >= amount

func spend(amount: float) -> bool:
	if not can_afford(amount):
		return false
	energy -= amount
	energy_changed.emit(energy, max_energy)
	energy_spent.emit(amount)
	return true

func add_energy(amount: float) -> void:
	energy = minf(energy + amount, max_energy)
	energy_changed.emit(energy, max_energy)

func set_max_energy(value: float) -> void:
	max_energy = value
	energy = minf(energy, max_energy)
	energy_changed.emit(energy, max_energy)
