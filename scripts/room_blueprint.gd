extends Resource
class_name RoomBlueprint

enum ROOM_TYPE {BASIC, ELEVATOR, GENERATOR}

func _init(_type: ROOM_TYPE, _rect : Rect2i, _room_center : Vector2i):
    type = _type
    rect = _rect
    room_center = _room_center

var rect : Rect2i 
var type : ROOM_TYPE 
var room_center : Vector2i



