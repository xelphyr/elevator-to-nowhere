extends Node
class_name ApplyRot

@export var aim_node: AimNode

func _process(delta):
    get_parent().rotation -= aim_node.get_rot()