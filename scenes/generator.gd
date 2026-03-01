extends StaticBody2D

@export var interaction_area : InteractionArea


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.activated.connect(on_activated)

func on_activated() -> void:
	SignalBus.generator_activated.emit()
	interaction_area.monitoring = false 
	interaction_area.disable_detect()
