extends Node2D
## BuildingRenderer - Renders the building in authentic Der Planer style

const PlanerGraphics = preload("res://scripts/graphics/planer_graphics.gd")

# Building dimensions
const FLOOR_HEIGHT: int = 180
const CORRIDOR_WIDTH: int = 1280
const FLOOR_DEPTH: int = 120

# Room positions for each floor
var room_definitions: Dictionary = {
	0: [  # Basement
		{"name": "Room_Garage", "pos": 100, "label": "GARAGE"},
		{"name": "Room_PR", "pos": 300, "label": "PR"},
		{"name": "Room_TruckDealer1", "pos": 500, "label": "DEALER"},
		{"name": "Room_Exit", "pos": 900, "label": "EXIT"},
	],
	1: [  # Ground floor
		{"name": "Room_Reception", "pos": 100, "label": "RECEPTION"},
		{"name": "Room_Contracts", "pos": 300, "label": "CONTRACTS"},
		{"name": "Room_Dispatch", "pos": 500, "label": "DISPATCH"},
		{"name": "Room_Stations", "pos": 800, "label": "STATIONS"},
	],
	2: [  # Upper floor
		{"name": "Room_Office", "pos": 150, "label": "OFFICE"},
		{"name": "Room_Accounting", "pos": 350, "label": "ACCOUNTING"},
		{"name": "Room_HR", "pos": 550, "label": "HR"},
		{"name": "Room_Email", "pos": 750, "label": "EMAIL"},
		{"name": "Room_Bank", "pos": 950, "label": "BANK"},
	],
	3: [  # Top floor
		{"name": "Room_BoardRoom", "pos": 200, "label": "BOARDROOM"},
		{"name": "Room_Statistics", "pos": 450, "label": "STATS"},
		{"name": "Room_Luxury", "pos": 700, "label": "LUXURY"},
		{"name": "Room_Home", "pos": 950, "label": "HOME"},
	]
}

func _ready() -> void:
	_render_building()

func _render_building() -> void:
	for floor_num in range(4):
		_render_floor(floor_num)

func _render_floor(floor_num: int) -> void:
	var floor_y = -floor_num * FLOOR_HEIGHT
	var floor_container = Node2D.new()
	floor_container.name = "Floor%d_Container" % floor_num
	floor_container.position = Vector2(0, floor_y + 500)  # Center vertically
	add_child(floor_container)

	# Background wall
	var wall = PlanerGraphics.create_wall_texture(CORRIDOR_WIDTH, FLOOR_HEIGHT)
	wall.position = Vector2(640, FLOOR_HEIGHT / 2)
	floor_container.add_child(wall)

	# Floor
	var floor_sprite = PlanerGraphics.create_floor_texture(CORRIDOR_WIDTH, 40)
	floor_sprite.position = Vector2(640, FLOOR_HEIGHT - 20)
	floor_container.add_child(floor_sprite)

	# Ceiling line
	var ceiling = ColorRect.new()
	ceiling.size = Vector2(CORRIDOR_WIDTH, 2)
	ceiling.position = Vector2(0, 0)
	ceiling.color = Color(0.2, 0.2, 0.3)
	floor_container.add_child(ceiling)

	# Add windows on back wall
	for w in range(3):
		var window = PlanerGraphics.create_window_sprite()
		window.position = Vector2(200 + w * 400, 40)
		floor_container.add_child(window)

	# Add rooms/doors
	if room_definitions.has(floor_num):
		for room_def in room_definitions[floor_num]:
			_create_room_entrance(floor_container, room_def)

	# Add elevator
	_create_elevator(floor_container, floor_num)

	# Add decorative furniture
	_add_furniture(floor_container, floor_num)

func _create_room_entrance(parent: Node2D, room_def: Dictionary) -> void:
	var room_node = Node2D.new()
	room_node.name = room_def.name
	room_node.position = Vector2(room_def.pos, FLOOR_HEIGHT - 70)
	parent.add_child(room_node)

	# Door sprite
	var door = PlanerGraphics.create_door_sprite()
	door.name = "Door"
	door.position = Vector2(0, 0)
	room_node.add_child(door)

	# Room sign above door
	var sign = PlanerGraphics.create_room_sign(room_def.label)
	sign.position = Vector2(0, -40)
	room_node.add_child(sign)

	# Interaction area
	var area = Area2D.new()
	area.name = "InteractionArea"
	room_node.add_child(area)

	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 80)
	collision.shape = shape
	area.add_child(collision)

	# Make clickable
	area.input_pickable = true
	area.mouse_filter = Control.MOUSE_FILTER_STOP

func _create_elevator(parent: Node2D, floor_num: int) -> void:
	var elevator_node = Node2D.new()
	elevator_node.name = "Elevator"
	elevator_node.position = Vector2(1150, FLOOR_HEIGHT - 80)
	parent.add_child(elevator_node)

	# Elevator sprite
	var elevator = PlanerGraphics.create_elevator_sprite()
	elevator.name = "ElevatorDoor"
	elevator_node.add_child(elevator)

	# Elevator sign
	var sign = PlanerGraphics.create_room_sign("ELEVATOR")
	sign.position = Vector2(0, -50)
	elevator_node.add_child(sign)

	# Floor indicator
	var floor_label = Label.new()
	floor_label.text = str(floor_num + 1)
	floor_label.position = Vector2(-8, -10)
	floor_label.add_theme_font_size_override("font_size", 18)
	floor_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	elevator_node.add_child(floor_label)

	# Interaction area
	var area = Area2D.new()
	area.name = "InteractionArea"
	elevator_node.add_child(area)

	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(70, 90)
	collision.shape = shape
	area.add_child(collision)

	area.input_pickable = true
	area.mouse_filter = Control.MOUSE_FILTER_STOP

func _add_furniture(parent: Node2D, floor_num: int) -> void:
	# Add some decorative furniture to make it feel alive
	match floor_num:
		0:  # Basement - industrial
			var filing = PlanerGraphics.create_furniture("filing_cabinet")
			filing.position = Vector2(80, FLOOR_HEIGHT - 50)
			parent.add_child(filing)
		1:  # Ground floor - reception area
			var plant = PlanerGraphics.create_furniture("plant")
			plant.position = Vector2(1100, FLOOR_HEIGHT - 40)
			parent.add_child(plant)

			var desk = PlanerGraphics.create_furniture("desk")
			desk.position = Vector2(150, FLOOR_HEIGHT - 50)
			parent.add_child(desk)
		2:  # Upper floor - offices
			var plant1 = PlanerGraphics.create_furniture("plant")
			plant1.position = Vector2(100, FLOOR_HEIGHT - 40)
			parent.add_child(plant1)

			var plant2 = PlanerGraphics.create_furniture("plant")
			plant2.position = Vector2(1100, FLOOR_HEIGHT - 40)
			parent.add_child(plant2)
		3:  # Top floor - executive
			var desk1 = PlanerGraphics.create_furniture("desk")
			desk1.position = Vector2(100, FLOOR_HEIGHT - 50)
			parent.add_child(desk1)

			var plant = PlanerGraphics.create_furniture("plant")
			plant.position = Vector2(300, FLOOR_HEIGHT - 40)
			parent.add_child(plant)
