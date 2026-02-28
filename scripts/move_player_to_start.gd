extends StaticBody2D

@export var start_pos : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_nodes_in_group("Player")[0]
	if player:
		player.position = start_pos.global_position
