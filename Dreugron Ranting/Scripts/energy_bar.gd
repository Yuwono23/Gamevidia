extends ProgressBar

func _ready() -> void:
	EnergyManager.energy_changed.connect(_on_energy_changed)
	# Autoloads are ready BEFORE the main scene, so we missed the
	# initial emission. Sync manually once:
	_on_energy_changed(EnergyManager.energy, EnergyManager.max_energy)

func _on_energy_changed(current: float, maximum: float) -> void:
	max_value = maximum
	value = current
