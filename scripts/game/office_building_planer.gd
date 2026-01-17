extends Node2D
## OfficeBuilding - Der Planer style building with authentic graphics

signal room_entered(room_name: String)
signal floor_changed(floor_number: int)

const PlanerGraphics = preload("res://scripts/graphics/planer_graphics.gd")
const EnhancedGraphics = preload("res://scripts/graphics/enhanced_graphics.gd")

var rooms: Dictionary = {
	"Room_Garage": {"name": "Garage", "floor": 0, "description": "Manage and repair your truck fleet"},
	"Room_PR": {"name": "PR & Marketing", "floor": 0, "description": "Advertise your company"},
	"Room_TruckDealer1": {"name": "Truck Dealer", "floor": 0, "description": "Buy and sell trucks"},
	"Room_Exit": {"name": "Exit / Travel", "floor": 0, "description": "Travel to other cities"},
	"Room_Reception": {"name": "Reception", "floor": 1, "description": "Company reception"},
	"Room_Contracts": {"name": "Contracts Office", "floor": 1, "description": "View and accept delivery contracts"},
	"Room_Dispatch": {"name": "Dispatch Center", "floor": 1, "description": "Assign trucks and drivers to deliveries"},
	"Room_Stations": {"name": "Station Management", "floor": 1, "description": "Open stations in other cities"},
	"Room_Office": {"name": "Your Office", "floor": 2, "description": "Your personal office"},
	"Room_Accounting": {"name": "Accounting", "floor": 2, "description": "View finances and invoices"},
	"Room_HR": {"name": "Human Resources", "floor": 2, "description": "Hire and manage employees"},
	"Room_Email": {"name": "Communications", "floor": 2, "description": "Email and messaging center"},
	"Room_Bank": {"name": "Bank & Loans", "floor": 2, "description": "Take loans and manage finances"},
	"Room_BoardRoom": {"name": "Board Room", "floor": 3, "description": "Strategic decisions"},
	"Room_Statistics": {"name": "Statistics", "floor": 3, "description": "View company statistics"},
	"Room_Luxury": {"name": "Luxury Shop", "floor": 3, "description": "Buy luxury items"},
	"Room_Home": {"name": "Go Home", "floor": 3, "description": "Go home to your family"}
}

var current_floor: int = 1
var floors: Array[Node2D] = []
var player: CharacterBody2D
var player_sprite: AnimatedSprite2D
var current_room_dialog: Control = null
var game_hud: CanvasLayer
var building_renderer: Node2D
var camera: Camera2D

func _ready() -> void:
	_setup_camera()
	_setup_building_graphics()
	_setup_player()
	_setup_hud()

	AudioManager.play_music("office")
	EventBus.emit_signal("game_started", GameManager.is_freeplay)
	GameManager.resume_game()

	_change_to_floor(current_floor)

func _setup_camera() -> void:
	camera = Camera2D.new()
	camera.enabled = true
	camera.zoom = Vector2(1.0, 1.0)
	add_child(camera)
	camera.position = Vector2(640, 360)

func _setup_building_graphics() -> void:
	# Create the building renderer
	building_renderer = Node2D.new()
	building_renderer.name = "BuildingRenderer"
	add_child(building_renderer)

	# Create all floors
	for floor_num in range(4):
		var floor_node = _create_floor(floor_num)
		floors.append(floor_node)
		building_renderer.add_child(floor_node)

func _create_floor(floor_num: int) -> Node2D:
	var floor_container = Node2D.new()
	floor_container.name = "Floor%d" % floor_num
	floor_container.visible = (floor_num == current_floor)

	# Background - gradient sky
	var bg = ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.position = Vector2(0, 0)
	bg.color = Color(0.4, 0.5, 0.65)
	floor_container.add_child(bg)

	# Corridor wall (concrete texture)
	var wall = EnhancedGraphics.create_textured_wall_with_bitmaps(1280, 180)
	wall.position = Vector2(0, 440)
	floor_container.add_child(wall)

	# Tiled floor (different for each floor type)
	var floor_graphic: Control
	if floor_num == 3:  # Top floor - marble
		floor_graphic = EnhancedGraphics.create_marble_floor(1280)
	elif floor_num == 2:  # Office floor - carpet
		floor_graphic = EnhancedGraphics.create_carpet(1280, 80)
	else:  # Lower floors - ceramic tiles
		floor_graphic = EnhancedGraphics.create_tiled_floor(1280)

	floor_graphic.position = Vector2(0, 620)
	floor_container.add_child(floor_graphic)

	# Detailed windows in background
	for i in range(4):
		var window = EnhancedGraphics.create_detailed_window()
		window.position = Vector2(200 + i * 250, 470)
		floor_container.add_child(window)

	# Add rooms based on floor
	_add_rooms_to_floor(floor_container, floor_num)

	# Add elevator
	_add_elevator_to_floor(floor_container)

	# Add office furniture for detail
	if floor_num == 2:  # Office floor
		var desk = EnhancedGraphics.create_textured_desk()
		desk.position = Vector2(100, 550)
		floor_container.add_child(desk)

		var chair = EnhancedGraphics.create_office_chair()
		chair.position = Vector2(160, 560)
		floor_container.add_child(chair)

		var cabinet = EnhancedGraphics.create_filing_cabinet()
		cabinet.position = Vector2(1150, 550)
		floor_container.add_child(cabinet)

	return floor_container

func _create_simple_window() -> Node2D:
	var window = Node2D.new()

	# Window frame
	var frame = ColorRect.new()
	frame.size = Vector2(48, 64)
	frame.color = Color(0.3, 0.35, 0.4)
	window.add_child(frame)

	# Glass
	var glass = ColorRect.new()
	glass.size = Vector2(44, 60)
	glass.position = Vector2(2, 2)
	glass.color = Color(0.6, 0.75, 0.9)
	window.add_child(glass)

	# Divider
	var divider_h = ColorRect.new()
	divider_h.size = Vector2(44, 2)
	divider_h.position = Vector2(2, 31)
	divider_h.color = Color(0.3, 0.35, 0.4)
	window.add_child(divider_h)

	var divider_v = ColorRect.new()
	divider_v.size = Vector2(2, 60)
	divider_v.position = Vector2(23, 2)
	divider_v.color = Color(0.3, 0.35, 0.4)
	window.add_child(divider_v)

	return window

func _add_rooms_to_floor(floor_container: Node2D, floor_num: int) -> void:
	var room_positions = [
		[100, 280, 460, 800],     # Floor 0
		[120, 320, 520, 850],     # Floor 1
		[80, 260, 440, 620, 950], # Floor 2
		[150, 400, 650, 950]      # Floor 3
	]

	var room_labels = [
		["GARAGE", "PR", "DEALER", "EXIT"],
		["RECEPTION", "CONTRACTS", "DISPATCH", "STATIONS"],
		["OFFICE", "ACCOUNTING", "HR", "EMAIL", "BANK"],
		["BOARDROOM", "STATS", "LUXURY", "HOME"]
	]

	var room_names = [
		["Room_Garage", "Room_PR", "Room_TruckDealer1", "Room_Exit"],
		["Room_Reception", "Room_Contracts", "Room_Dispatch", "Room_Stations"],
		["Room_Office", "Room_Accounting", "Room_HR", "Room_Email", "Room_Bank"],
		["Room_BoardRoom", "Room_Statistics", "Room_Luxury", "Room_Home"]
	]

	for i in range(room_positions[floor_num].size()):
		var room = _create_room_door(room_names[floor_num][i], room_labels[floor_num][i])
		room.position = Vector2(room_positions[floor_num][i], 540)
		floor_container.add_child(room)

func _create_room_door(room_name: String, label: String) -> Node2D:
	var room = Node2D.new()
	room.name = room_name

	# Textured door graphic with real wood and metal
	var door_graphic = EnhancedGraphics.create_textured_door()
	door_graphic.name = "Door"
	room.add_child(door_graphic)

	# Room label with better visibility
	var label_bg = ColorRect.new()
	label_bg.position = Vector2(-15, -22)
	label_bg.size = Vector2(78, 18)
	label_bg.color = Color(0, 0, 0, 0.7)
	room.add_child(label_bg)

	var label_node = Label.new()
	label_node.text = label
	label_node.position = Vector2(-10, -20)
	label_node.add_theme_font_size_override("font_size", 11)
	label_node.add_theme_color_override("font_color", Color(1, 1, 0.9))
	room.add_child(label_node)

	# Interaction area
	var area = Area2D.new()
	area.name = "InteractionArea"
	room.add_child(area)

	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 100)
	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(24, 48)
	area.add_child(collision)

	area.input_pickable = true
	area.mouse_entered.connect(_on_room_hover_enter.bind(room))
	area.mouse_exited.connect(_on_room_hover_exit.bind(room))
	area.input_event.connect(_on_room_clicked.bind(room))

	return room

func _add_elevator_to_floor(floor_container: Node2D) -> void:
	var elevator = Node2D.new()
	elevator.name = "Elevator"
	elevator.position = Vector2(1180, 530)
	floor_container.add_child(elevator)

	# Elevator frame
	var frame = ColorRect.new()
	frame.size = Vector2(72, 110)
	frame.color = Color(0.25, 0.3, 0.35)
	elevator.add_child(frame)

	# Doors
	var left_door = ColorRect.new()
	left_door.size = Vector2(30, 100)
	left_door.position = Vector2(5, 5)
	left_door.color = Color(0.65, 0.7, 0.75)
	elevator.add_child(left_door)

	var right_door = ColorRect.new()
	right_door.size = Vector2(30, 100)
	right_door.position = Vector2(37, 5)
	right_door.color = Color(0.65, 0.7, 0.75)
	elevator.add_child(right_door)

	# Label
	var label_node = Label.new()
	label_node.text = "ELEVATOR"
	label_node.position = Vector2(-5, -18)
	label_node.add_theme_font_size_override("font_size", 10)
	label_node.add_theme_color_override("font_color", Color(1, 1, 1))
	elevator.add_child(label_node)

	# Interaction area
	var area = Area2D.new()
	area.name = "InteractionArea"
	elevator.add_child(area)

	var shape = RectangleShape2D.new()
	shape.size = Vector2(80, 115)
	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(36, 55)
	area.add_child(collision)

	area.input_pickable = true
	area.mouse_entered.connect(_on_elevator_hover_enter.bind(elevator))
	area.mouse_exited.connect(_on_elevator_hover_exit.bind(elevator))
	area.input_event.connect(_on_elevator_clicked.bind(elevator))

func _setup_player() -> void:
	player = CharacterBody2D.new()
	player.name = "Player"
	player.position = Vector2(640, 640)
	add_child(player)

	# Use pixel art character
	player_sprite = PlanerGraphics.create_character_sprite()
	player_sprite.position = Vector2(0, -16)
	player.add_child(player_sprite)

	# Collision
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(20, 30)
	collision.shape = shape
	player.add_child(collision)

	# Add script
	var script = load("res://scripts/game/player_character.gd")
	player.set_script(script)

func _setup_hud() -> void:
	# Load the authentic Der Planer HUD
	var hud_script = load("res://scripts/ui/planer_hud.gd")
	game_hud = CanvasLayer.new()
	game_hud.set_script(hud_script)
	add_child(game_hud)

func _change_to_floor(floor_num: int) -> void:
	current_floor = floor_num

	# Show/hide floors
	for i in range(floors.size()):
		floors[i].visible = (i == floor_num)

	# Move player to elevator position on new floor
	player.position = Vector2(1150, 640)

	emit_signal("floor_changed", floor_num)
	if game_hud and game_hud.has_method("update_location"):
		game_hud.update_location("Floor %d" % (floor_num + 1))

func _on_room_hover_enter(room: Node2D) -> void:
	var door = room.get_node_or_null("Door")
	if door:
		door.modulate = Color(1.3, 1.3, 1.3)

	if game_hud and game_hud.has_method("show_hint"):
		var room_name = room.name
		if rooms.has(room_name):
			game_hud.show_hint("Click to enter: " + rooms[room_name].name)

func _on_room_hover_exit(room: Node2D) -> void:
	var door = room.get_node_or_null("Door")
	if door:
		door.modulate = Color(1, 1, 1)

	if game_hud and game_hud.has_method("hide_hint"):
		game_hud.hide_hint()

func _on_room_clicked(viewport: Node, event: InputEvent, shape_idx: int, room: Node2D) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_enter_room(room.name)

func _on_elevator_hover_enter(elevator: Node2D) -> void:
	if game_hud and game_hud.has_method("show_hint"):
		game_hud.show_hint("Click to use elevator")

func _on_elevator_hover_exit(elevator: Node2D) -> void:
	if game_hud and game_hud.has_method("hide_hint"):
		game_hud.hide_hint()

func _on_elevator_clicked(viewport: Node, event: InputEvent, shape_idx: int, elevator: Node2D) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_elevator_dialog()

func _enter_room(room_name: String) -> void:
	if not rooms.has(room_name):
		return

	var room_data = rooms[room_name]
	AudioManager.play_sfx("door_open")

	EventBus.emit_signal("room_entered", room_data.name)
	emit_signal("room_entered", room_data.name)

	# For now, show a simple dialog - the full dialogs are in the original office_building.gd
	_show_simple_room_dialog(room_name, room_data)

func _show_simple_room_dialog(room_name: String, room_data: Dictionary) -> void:
	var dialog = Control.new()
	dialog.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.85)
	dialog.add_child(bg)

	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -400
	panel.offset_right = 400
	panel.offset_top = -280
	panel.offset_bottom = 280
	dialog.add_child(panel)

	# Add navigation bar at top
	var nav_bar = _create_navigation_bar()
	nav_bar.position = Vector2(0, 0)
	panel.add_child(nav_bar)

	# Connect navigation signals
	nav_bar.get_node("CloseBtn").pressed.connect(func(): _close_dialog(dialog))
	nav_bar.get_node("LaptopBtn").pressed.connect(func(): _nav_to_room("Room_Office", dialog))
	nav_bar.get_node("MoneyBtn").pressed.connect(func(): _nav_to_room("Room_Accounting", dialog))
	nav_bar.get_node("StatsBtn").pressed.connect(func(): _nav_to_room("Room_Statistics", dialog))
	nav_bar.get_node("EmailBtn").pressed.connect(func(): _nav_to_room("Room_Email", dialog))

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 60  # Leave space for nav bar
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 15)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = room_data.name
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var desc = Label.new()
	desc.text = room_data.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(150, 40)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(func(): _close_dialog(dialog))
	vbox.add_child(close_btn)

	add_child(dialog)
	current_room_dialog = dialog
	GameManager.pause_game()

func _show_elevator_dialog() -> void:
	AudioManager.play_sfx("click")

	var dialog = Control.new()
	dialog.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.8)
	dialog.add_child(bg)

	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -250
	panel.offset_right = 250
	panel.offset_top = -240
	panel.offset_bottom = 240
	dialog.add_child(panel)

	# Add navigation bar at top
	var nav_bar = _create_navigation_bar()
	nav_bar.position = Vector2(0, 0)
	panel.add_child(nav_bar)

	# Connect navigation signals
	nav_bar.get_node("CloseBtn").pressed.connect(func(): _close_dialog(dialog))
	nav_bar.get_node("LaptopBtn").pressed.connect(func(): _nav_to_room("Room_Office", dialog))
	nav_bar.get_node("MoneyBtn").pressed.connect(func(): _nav_to_room("Room_Accounting", dialog))
	nav_bar.get_node("StatsBtn").pressed.connect(func(): _nav_to_room("Room_Statistics", dialog))
	nav_bar.get_node("EmailBtn").pressed.connect(func(): _nav_to_room("Room_Email", dialog))

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 15
	vbox.offset_right = -15
	vbox.offset_top = 60  # Leave space for nav bar
	vbox.offset_bottom = -15
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "Select Floor"
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var floor_names = ["Basement", "Ground Floor", "Upper Floor", "Top Floor"]
	for i in range(4):
		var btn = Button.new()
		btn.text = floor_names[i]
		btn.custom_minimum_size = Vector2(0, 45)
		if i == current_floor:
			btn.text += " (Current)"
			btn.disabled = true
		var floor_num = i
		btn.pressed.connect(func(): _on_floor_selected(floor_num, dialog))
		vbox.add_child(btn)

	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(0, 40)
	close_btn.pressed.connect(func(): _close_dialog(dialog))
	vbox.add_child(close_btn)

	add_child(dialog)
	current_room_dialog = dialog
	GameManager.pause_game()

func _on_floor_selected(floor_num: int, dialog: Control) -> void:
	_close_dialog(dialog)
	if floor_num != current_floor:
		AudioManager.play_sfx("elevator")
		_change_to_floor(floor_num)

func _create_navigation_bar() -> Control:
	var nav_container = Control.new()
	nav_container.custom_minimum_size = Vector2(800, 50)

	# Background bar
	var bg = ColorRect.new()
	bg.size = Vector2(800, 50)
	bg.color = Color(0.18, 0.22, 0.28, 0.98)
	nav_container.add_child(bg)

	# Navigation buttons container
	var hbox = HBoxContainer.new()
	hbox.position = Vector2(10, 8)
	hbox.add_theme_constant_override("separation", 10)
	nav_container.add_child(hbox)

	# Laptop/Computer button
	var laptop_btn = _create_nav_icon_button("COMPUTER", Color(0.5, 0.7, 0.95))
	laptop_btn.name = "LaptopBtn"
	hbox.add_child(laptop_btn)

	# Money button
	var money_btn = _create_nav_icon_button("MONEY", Color(0.3, 0.9, 0.5))
	money_btn.name = "MoneyBtn"
	hbox.add_child(money_btn)

	# Statistics button
	var stats_btn = _create_nav_icon_button("STATS", Color(0.95, 0.75, 0.35))
	stats_btn.name = "StatsBtn"
	hbox.add_child(stats_btn)

	# Email button
	var email_btn = _create_nav_icon_button("EMAIL", Color(0.95, 0.5, 0.5))
	email_btn.name = "EmailBtn"
	hbox.add_child(email_btn)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(300, 1)
	hbox.add_child(spacer)

	# Close button
	var close_btn = _create_nav_icon_button("CLOSE", Color(1, 0.4, 0.4))
	close_btn.name = "CloseBtn"
	hbox.add_child(close_btn)

	return nav_container

func _create_nav_icon_button(label_text: String, icon_color: Color) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(70, 34)

	# Simple styled button with colored background
	var style = StyleBoxFlat.new()
	style.bg_color = icon_color
	style.border_color = Color(0, 0, 0)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1

	btn.text = label_text
	btn.add_theme_font_size_override("font_size", 10)
	btn.add_theme_color_override("font_color", Color(0, 0, 0))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))

	return btn

func _nav_to_room(room_name: String, current_dialog: Control) -> void:
	AudioManager.play_sfx("click")
	_close_dialog(current_dialog)
	if rooms.has(room_name):
		_enter_room(room_name)

func _close_dialog(dialog: Control) -> void:
	AudioManager.play_sfx("door_close")
	dialog.queue_free()
	current_room_dialog = null
	GameManager.resume_game()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if current_room_dialog == null:
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
