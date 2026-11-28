extends Button

@export var unit_data: UnitData
@export var deployment_manager: DeploymentManager

func _ready() -> void:
	if unit_data == null:
		push_error("DeployButton: no unit_data assigned")
		return
	if unit_data.icon != null:
		icon = unit_data.icon
	pressed.connect(_on_pressed)
	EnergyManager.energy_changed.connect(_on_energy_changed)
	_refresh()

func _process(_delta: float) -> void:
	if unit_data == null or deployment_manager == null:
		return
	var remain := deployment_manager.cooldown_remaining(unit_data)
	if remain > 0.0:
		text = "%s\n%.1fs" % [unit_data.display_name, remain]
	else:
		text = "%s\n%d" % [unit_data.display_name, int(unit_data.cost)]
	_refresh()

func _on_energy_changed(_current: float, _maximum: float) -> void:
	_refresh()

func _refresh() -> void:
	if unit_data == null:
		return
	var affordable := EnergyManager.can_afford(unit_data.cost)
	var cooling := deployment_manager != null and deployment_manager.is_on_cooldown(unit_data)
	disabled = cooling or not affordable
	modulate = Color.WHITE if affordable else Color(1.0, 0.55, 0.55, 1.0)

func _on_pressed() -> void:
	deployment_manager.try_deploy(unit_data)
