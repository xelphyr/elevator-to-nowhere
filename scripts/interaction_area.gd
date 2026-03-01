extends Area2D
class_name InteractionArea

enum InteractType {HOLD, TAP}

signal activated

@export var display_ui : Control
@export var interact_type : InteractType
@export var hold_time : float

var player_inside := false
var timer : float = 0.0

func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
	if display_ui:
		display_ui.visible = false

func _process(delta:float) -> void:
	if player_inside:
		match interact_type:
			InteractType.HOLD:
				if Input.is_action_pressed("interact"):
					timer += delta
					if timer >= hold_time:
						activated.emit()
			InteractType.TAP: 
				if Input.is_action_just_pressed("interact"):
					activated.emit()

func on_body_entered(body):
	if body.is_in_group("Player"):
		enable_detect()

func on_body_exited(body):
	if body.is_in_group("Player"):
		disable_detect()


func enable_detect() -> void:
	if display_ui:
		display_ui.visible = true
	player_inside = true

func disable_detect() -> void:
	if display_ui:
		display_ui.visible = false
	player_inside = false
