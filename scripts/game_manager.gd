extends Node

var rounds_won := 0

func _ready() -> void:
    print("Floor -", rounds_won + 1)

func round_win() -> void:
    rounds_won += 1
    print("Floor -", rounds_won + 1)
    get_tree().reload_current_scene()