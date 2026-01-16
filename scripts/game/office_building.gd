extends Node2D
## OfficeBuilding - Main gameplay scene with building navigation

signal room_entered(room_name: String)
signal floor_changed(floor_number: int)

# Room definitions with their functionality
var rooms: Dictionary = {
	# Basement (Floor 0)
	"Room_Garage": {
		"name": "Garage",
		"floor": 0,
		"description": "Manage and repair your truck fleet",
		"scene": "res://scenes/rooms/garage.tscn"
	},
	"Room_PR": {
		"name": "PR & Marketing",
		"floor": 0,
		"description": "Advertise your company and manage public relations",
		"scene": "res://scenes/rooms/pr_room.tscn"
	},
	"Room_TruckDealer1": {
		"name": "Truck Dealer",
		"floor": 0,
		"description": "Buy and sell trucks",
		"scene": "res://scenes/rooms/truck_dealer.tscn"
	},
	"Room_Exit": {
		"name": "Exit / Travel",
		"floor": 0,
		"description": "Travel to other cities or go to stations",
		"scene": "res://scenes/rooms/travel.tscn"
	},

	# Ground Floor (Floor 1)
	"Room_Reception": {
		"name": "Reception",
		"floor": 1,
		"description": "Company reception and visitor management",
		"scene": "res://scenes/rooms/reception.tscn"
	},
	"Room_Contracts": {
		"name": "Contracts Office",
		"floor": 1,
		"description": "View and accept delivery contracts",
		"scene": "res://scenes/rooms/contracts.tscn"
	},
	"Room_Dispatch": {
		"name": "Dispatch Center",
		"floor": 1,
		"description": "Assign trucks and drivers to deliveries",
		"scene": "res://scenes/rooms/dispatch.tscn"
	},
	"Room_Stations": {
		"name": "Station Management",
		"floor": 1,
		"description": "Open and manage stations in other cities",
		"scene": "res://scenes/rooms/stations.tscn"
	},

	# Upper Floor (Floor 2)
	"Room_Office": {
		"name": "Your Office",
		"floor": 2,
		"description": "Your personal office - check emails and overview",
		"scene": "res://scenes/rooms/office.tscn"
	},
	"Room_Accounting": {
		"name": "Accounting",
		"floor": 2,
		"description": "View finances, invoices, and payment reminders",
		"scene": "res://scenes/rooms/accounting.tscn"
	},
	"Room_HR": {
		"name": "Human Resources",
		"floor": 2,
		"description": "Hire and manage employees",
		"scene": "res://scenes/rooms/hr.tscn"
	},
	"Room_Email": {
		"name": "Communications",
		"floor": 2,
		"description": "Email and messaging center",
		"scene": "res://scenes/rooms/email.tscn"
	},
	"Room_Bank": {
		"name": "Bank & Loans",
		"floor": 2,
		"description": "Take loans and manage company finances",
		"scene": "res://scenes/rooms/bank.tscn"
	},

	# Top Floor (Floor 3)
	"Room_BoardRoom": {
		"name": "Board Room",
		"floor": 3,
		"description": "Strategic decisions and company overview",
		"scene": "res://scenes/rooms/boardroom.tscn"
	},
	"Room_Statistics": {
		"name": "Statistics",
		"floor": 3,
		"description": "View company statistics and performance",
		"scene": "res://scenes/rooms/statistics.tscn"
	},
	"Room_Luxury": {
		"name": "Luxury Shop",
		"floor": 3,
		"description": "Buy luxury items to increase social status",
		"scene": "res://scenes/rooms/luxury.tscn"
	},
	"Room_Home": {
		"name": "Go Home",
		"floor": 3,
		"description": "Go home to your family",
		"scene": "res://scenes/rooms/home.tscn"
	}
}

var current_floor: int = 1
var floors: Dictionary = {}
var player: CharacterBody2D
var current_room_dialog: Control = null

@onready var building_exterior = $BuildingContainer/BuildingExterior
@onready var game_hud = $UI/GameHUD
@onready var pause_menu = $UI/PauseMenu

func _ready() -> void:
	_setup_floors()
	_connect_room_signals()
	_setup_player()

	AudioManager.play_music("office")
	EventBus.emit_signal("game_started", GameManager.is_freeplay)

	# Set initial floor visibility
	_update_floor_visibility()

func _setup_floors() -> void:
	floors = {
		0: $BuildingContainer/BuildingExterior/Floor0_Basement,
		1: $BuildingContainer/BuildingExterior/Floor1_Ground,
		2: $BuildingContainer/BuildingExterior/Floor2_Upper,
		3: $BuildingContainer/BuildingExterior/Floor3_Top
	}

func _connect_room_signals() -> void:
	# Connect all room Area2D signals
	for floor_node in floors.values():
		for child in floor_node.get_children():
			if child is Area2D:
				if child.name.begins_with("Room_") or child.name == "Elevator":
					child.mouse_entered.connect(_on_room_hover_enter.bind(child))
					child.mouse_exited.connect(_on_room_hover_exit.bind(child))
					child.input_event.connect(_on_room_input.bind(child))

func _setup_player() -> void:
	player = $BuildingContainer/Player
	player.interaction_area.area_entered.connect(_on_player_near_room)
	player.interaction_area.area_exited.connect(_on_player_left_room)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	if current_room_dialog != null:
		return  # Don't pause if in a room dialog

	pause_menu.visible = not pause_menu.visible
	if pause_menu.visible:
		GameManager.pause_game()
		EventBus.emit_signal("game_paused")
	else:
		GameManager.resume_game()
		EventBus.emit_signal("game_resumed")

func _update_floor_visibility() -> void:
	# Show all floors but highlight current floor
	for floor_num in floors:
		var floor_node = floors[floor_num]
		if floor_num == current_floor:
			floor_node.modulate = Color(1, 1, 1, 1)
		else:
			floor_node.modulate = Color(0.6, 0.6, 0.6, 1)

func change_floor(new_floor: int) -> void:
	if new_floor < 0 or new_floor > 3:
		return

	AudioManager.play_sfx("elevator")
	current_floor = new_floor

	# Move player to new floor's elevator position
	var floor_node = floors[current_floor]
	var elevator = floor_node.get_node_or_null("Elevator")
	if elevator:
		player.global_position = elevator.global_position + Vector2(50, 90)

	_update_floor_visibility()
	emit_signal("floor_changed", current_floor)
	game_hud.update_location("Office Building - Floor %d" % (current_floor + 1))

func _on_room_hover_enter(room: Area2D) -> void:
	# Highlight room on hover
	var door_sprite = room.get_node_or_null("DoorSprite")
	if door_sprite:
		door_sprite.modulate = Color(1.2, 1.2, 1.2, 1)

	# Show room info
	if rooms.has(room.name):
		game_hud.show_interaction_hint(rooms[room.name].description)
	elif room.name == "Elevator":
		game_hud.show_interaction_hint("Use elevator to change floors")

func _on_room_hover_exit(room: Area2D) -> void:
	var door_sprite = room.get_node_or_null("DoorSprite")
	if door_sprite:
		door_sprite.modulate = Color(1, 1, 1, 1)
	game_hud.hide_interaction_hint()

func _on_room_input(viewport: Node, event: InputEvent, shape_idx: int, room: Area2D) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_enter_room(room.name)

func _on_player_near_room(area: Area2D) -> void:
	if rooms.has(area.get_parent().name):
		game_hud.show_interaction_hint("Press E to enter " + rooms[area.get_parent().name].name)
	elif area.get_parent().name == "Elevator":
		game_hud.show_interaction_hint("Press E to use elevator")

func _on_player_left_room(area: Area2D) -> void:
	game_hud.hide_interaction_hint()

func _enter_room(room_name: String) -> void:
	if room_name == "Elevator":
		_show_elevator_menu()
		return

	if not rooms.has(room_name):
		return

	var room_data = rooms[room_name]
	AudioManager.play_sfx("door_open")

	EventBus.emit_signal("room_entered", room_data.name)
	emit_signal("room_entered", room_data.name)

	# Load room scene or show room dialog
	_show_room_dialog(room_name, room_data)

func _show_elevator_menu() -> void:
	AudioManager.play_sfx("click")

	var dialog = preload("res://scenes/ui/elevator_dialog.tscn").instantiate()
	dialog.floor_selected.connect(_on_elevator_floor_selected)
	dialog.current_floor = current_floor
	add_child(dialog)
	current_room_dialog = dialog
	GameManager.pause_game()

func _on_elevator_floor_selected(floor_num: int) -> void:
	if current_room_dialog:
		current_room_dialog.queue_free()
		current_room_dialog = null
	GameManager.resume_game()

	if floor_num != current_floor:
		change_floor(floor_num)

func _show_room_dialog(room_name: String, room_data: Dictionary) -> void:
	# Create room-specific dialog based on room type
	var dialog: Control = null

	match room_name:
		"Room_Garage":
			dialog = preload("res://scenes/ui/garage_dialog.tscn").instantiate()
		"Room_Contracts":
			dialog = preload("res://scenes/ui/contracts_dialog.tscn").instantiate()
		"Room_Dispatch":
			dialog = preload("res://scenes/ui/dispatch_dialog.tscn").instantiate()
		"Room_TruckDealer1":
			dialog = preload("res://scenes/ui/truck_dealer_dialog.tscn").instantiate()
		"Room_HR":
			dialog = preload("res://scenes/ui/hr_dialog.tscn").instantiate()
		"Room_Accounting":
			dialog = preload("res://scenes/ui/accounting_dialog.tscn").instantiate()
		"Room_Bank":
			dialog = preload("res://scenes/ui/bank_dialog.tscn").instantiate()
		"Room_Email":
			dialog = preload("res://scenes/ui/email_dialog.tscn").instantiate()
		"Room_Statistics":
			dialog = preload("res://scenes/ui/statistics_dialog.tscn").instantiate()
		"Room_Luxury":
			dialog = preload("res://scenes/ui/luxury_dialog.tscn").instantiate()
		"Room_Home":
			dialog = preload("res://scenes/ui/home_dialog.tscn").instantiate()
		"Room_Stations":
			dialog = preload("res://scenes/ui/stations_dialog.tscn").instantiate()
		"Room_Exit":
			dialog = preload("res://scenes/ui/travel_dialog.tscn").instantiate()
		_:
			dialog = preload("res://scenes/ui/generic_room_dialog.tscn").instantiate()
			dialog.setup(room_data)

	if dialog:
		dialog.closed.connect(_on_room_dialog_closed)
		add_child(dialog)
		current_room_dialog = dialog
		GameManager.pause_game()

func _on_room_dialog_closed() -> void:
	AudioManager.play_sfx("door_close")
	if current_room_dialog:
		current_room_dialog.queue_free()
		current_room_dialog = null
	EventBus.emit_signal("room_exited", "")
	GameManager.resume_game()

func get_floor_name(floor_num: int) -> String:
	match floor_num:
		0: return "Basement"
		1: return "Ground Floor"
		2: return "Upper Floor"
		3: return "Top Floor"
		_: return "Unknown"
