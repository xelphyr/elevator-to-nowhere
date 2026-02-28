@tool
extends Node
class_name MapGenerator

const TILE_DATA: Dictionary = {
	"floor" : {
		"source_id": 0,
		"atlas_coords": Vector2i(0,0)
	},
	"wall" : {
		"source_id": 0,
		"atlas_coords": Vector2i(1,0)
	}
}

const CORE_ROOM_DATA: Array = [
	{
		"type": RoomBlueprint.ROOM_TYPE.ELEVATOR,
		"count": 1,
		"min_size": 20,
		"max_size": 25,
		"scene": ""
	},
	{
		"type": RoomBlueprint.ROOM_TYPE.GENERATOR,
		"count": 3,
		"min_size": 15,
		"max_size": 20,
		"scene": ""
	}
]

const CORE_ROOM_PADDING: int = 20 

@export var map_dimensions = Vector2i(100,100)
@export var room_count : int = 12
@export var room_min_size : int = 6
@export var room_max_size : int = 12
@export var room_padding : int = 1
@export_tool_button("Generate Map") var map_gen_button = generate_map
@export var tilemap_layer : TileMapLayer

func _ready() -> void:
	generate_map()

func generate_map() -> void:
	draw_tile_rect(map_dimensions, TILE_DATA.wall.source_id, TILE_DATA.wall.atlas_coords)
	var room_array : Array[RoomBlueprint] = generate_core_rooms(map_dimensions)
	room_array = generate_rooms(map_dimensions, room_min_size, room_max_size, room_array)
	carve_rooms(room_array)

	var corridors = generate_mst_connections(room_array)
	for corridor in corridors:
		carve_corridor(corridor[0], corridor[1])

func draw_tile_rect(dimensions: Vector2i, source_id: int, atlas_coords:Vector2i) -> void:
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			tilemap_layer.set_cell(Vector2(x,y), source_id, atlas_coords)


func generate_core_rooms(
	map_dim: Vector2i, 
	old_arr: Array[RoomBlueprint] = [],
	max_attempts: int = 200	
) -> Array[RoomBlueprint]:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var rooms: Array[RoomBlueprint]

	rooms = old_arr.duplicate()
	for core_room_type in CORE_ROOM_DATA:
		for i in range(core_room_type.count):
			var attempts := 0
			while attempts < max_attempts:
				attempts += 1

				var w = rng.randi_range(core_room_type.min_size, core_room_type.max_size)
				var h = rng.randi_range(core_room_type.min_size, core_room_type.max_size)
				var x = rng.randi_range(1, map_dim.x - w - 2)
				var y = rng.randi_range(1, map_dim.y - h - 2)

				var new_room = RoomBlueprint.new(
					RoomBlueprint.ROOM_TYPE.BASIC, 
					Rect2i(x, y, w, h), 
					Vector2i(
						x + w / 2, 
						y + h / 2
					)
				)

				var overlaps := false 

				for room in rooms:
					var padded_room = room.rect.grow(1)
					if padded_room.intersects(new_room.rect):
						overlaps = true 
						break 
				
				if not overlaps:
					rooms.append(new_room)
					break
	return rooms


func generate_rooms(
	map_dim: Vector2i, 
	min_size: int,
	max_size: int,
	old_arr: Array[RoomBlueprint] = [],
	max_attempts: int = 200,
) -> Array[RoomBlueprint]:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var rooms: Array[RoomBlueprint] = old_arr.duplicate()
	var attempts := 0

	while rooms.size() < room_count and attempts < max_attempts:
		attempts += 1

		var w = rng.randi_range(min_size, max_size)
		var h = rng.randi_range(min_size, max_size)
		var x = rng.randi_range(1, map_dim.x - w - 2)
		var y = rng.randi_range(1, map_dim.y - h - 2)

		var new_room = RoomBlueprint.new(
			RoomBlueprint.ROOM_TYPE.BASIC, 
			Rect2i(x, y, w, h),
			Vector2i(
				x + w / 2, 
				y + h / 2
			)
		)

		var overlaps := false 

		for room in rooms:
			var padded_room = room.rect.grow(room_padding)
			if padded_room.intersects(new_room.rect):
				overlaps = true 
				break 
		
		if not overlaps:
			rooms.append(new_room)
	return rooms

func generate_mst_connections(
	rooms: Array[RoomBlueprint]
) -> Array:
	var centers: Array[Vector2i] = []
	for room in rooms:
		centers.append(room.room_center)

	var connected: Array[int] = [0]
	var remaining: Array[int] = []

	for i in range(1, rooms.size()):
		remaining.append(i)
	
	var connections: Array = []

	while remaining.size() > 0:
		var best_dist := INF
		var best_from := 1
		var best_to := 1

		for c in connected:
			for r in remaining:
				var dist = centers[c].distance_squared_to(centers[r])
				if dist < best_dist:
					best_dist = dist 
					best_from = c
					best_to = r 
	
		connections.append([centers[best_from], centers[best_to]])

		connected.append(best_to) 
		remaining.erase(best_to)
	return connections

func carve_rooms(
	rooms: Array[RoomBlueprint]
) -> void:
	for room in rooms:
		var rect = room.rect
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			for y in range(rect.position.y, rect.position.y + rect.size.y):
				tilemap_layer.set_cell(Vector2i(x,y), TILE_DATA.floor.source_id, TILE_DATA.floor.atlas_coords)

func carve_corridor(
	start: Vector2i,
	end: Vector2i
) -> void:
	var rng = RandomNumberGenerator.new() 
	rng.randomize() 

	if rng.randi_range(0,1) == 0:
		carve_h_line(start.x, end.x, start.y)
		carve_v_line(start.y, end.y, end.x)	
	else:
		carve_v_line(start.y, end.y, start.x)
		carve_h_line(start.x, end.x, end.y)

func carve_h_line(x1:int, x2:int, y:int) -> void:
	for x in range(min(x1, x2), max(x1, x2) + 1):
		tilemap_layer.set_cell(Vector2i(x,y), TILE_DATA.floor.source_id, TILE_DATA.floor.atlas_coords)

func carve_v_line(y1:int, y2:int, x:int) -> void:
	for y in range(min(y1, y2), max(y1, y2) + 1):
		tilemap_layer.set_cell(Vector2i(x,y), TILE_DATA.floor.source_id, TILE_DATA.floor.atlas_coords)
