extends Node
class_name AimNode

@export var root: Node2D
@export var point_1: Node2D
@export var point_2: Node2D 

@export var aim_at : AimResolveModule

var rot : float = 0

func get_rot() -> float:
    return rot

func _process(delta: float) -> void:
    if aim_at:
        if root:
            if point_1 and point_2:
                var a = point_1.global_position - root.global_position
                var b = point_2.global_position - root.global_position

                var c = aim_at.get_aim_position() - root.global_position

                var barrel_line = b-a
                var aim_line = c

                rot = atan2(aim_line.cross(barrel_line), aim_line.dot(barrel_line))