extends Node2D

const TOTAL_GENERATORS = 3

var generators := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.generator_activated.connect(on_generator_activated)

func on_generator_activated() -> void:
	print("generator activated")
	generators += 1
	if generators == TOTAL_GENERATORS:
		print("elevator unlocked")
		SignalBus.elevator_unlocked.emit()


