extends StaticBody2D

@export var start_pos : Node2D
@export var interaction_area : InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.elevator_unlocked.connect(on_elevator_unlocked)

	var player = get_tree().get_nodes_in_group("Player")[0]
	if player:
		player.position = start_pos.global_position


func on_elevator_unlocked() -> void:
	interaction_area.monitoring = true 



func _on_interaction_area_activated() -> void:
	GameManager.call_deferred("round_win")
