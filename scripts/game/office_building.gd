extends Node2D
## OfficeBuilding - Main gameplay scene with building navigation

signal room_entered(room_name: String)
signal floor_changed(floor_number: int)

# Room definitions with their functionality
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
var floors: Dictionary = {}
var player: CharacterBody2D
var current_room_dialog: Control = null
var pause_menu: CanvasLayer

@onready var building_exterior = $BuildingContainer/BuildingExterior
@onready var game_hud = $UI/GameHUD

func _ready() -> void:
	pause_menu = $UI/PauseMenu
	_setup_floors()
	_connect_room_signals()
	_setup_player()
	
	AudioManager.play_music("office")
	EventBus.emit_signal("game_started", GameManager.is_freeplay)
	
	_update_floor_visibility()
	
	# Start the game unpaused
	GameManager.resume_game()

func _setup_floors() -> void:
	floors = {
		0: $BuildingContainer/BuildingExterior/Floor0_Basement,
		1: $BuildingContainer/BuildingExterior/Floor1_Ground,
		2: $BuildingContainer/BuildingExterior/Floor2_Upper,
		3: $BuildingContainer/BuildingExterior/Floor3_Top
	}

func _connect_room_signals() -> void:
	for floor_node in floors.values():
		for child in floor_node.get_children():
			if child is Area2D:
				if child.name.begins_with("Room_") or child.name == "Elevator":
					child.mouse_entered.connect(_on_room_hover_enter.bind(child))
					child.mouse_exited.connect(_on_room_hover_exit.bind(child))
					child.input_event.connect(_on_room_input.bind(child))

func _setup_player() -> void:
	player = $BuildingContainer/Player
	if player.has_node("InteractionArea"):
		player.get_node("InteractionArea").area_entered.connect(_on_player_near_room)
		player.get_node("InteractionArea").area_exited.connect(_on_player_left_room)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	if current_room_dialog != null:
		return
	
	pause_menu.visible = not pause_menu.visible
	if pause_menu.visible:
		GameManager.pause_game()
	else:
		GameManager.resume_game()

func _update_floor_visibility() -> void:
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
	
	var floor_node = floors[current_floor]
	var elevator = floor_node.get_node_or_null("Elevator")
	if elevator:
		player.global_position = elevator.global_position + Vector2(45, 90)
	
	_update_floor_visibility()
	emit_signal("floor_changed", current_floor)
	game_hud.update_location("Office Building - " + _get_floor_name(current_floor))

func _get_floor_name(floor_num: int) -> String:
	match floor_num:
		0: return "Basement"
		1: return "Ground Floor"
		2: return "Upper Floor"
		3: return "Top Floor"
		_: return "Unknown"

func _on_room_hover_enter(room: Area2D) -> void:
	var door = room.get_node_or_null("Door")
	if door:
		door.modulate = Color(1.3, 1.3, 1.3, 1)
	
	if rooms.has(room.name):
		game_hud.show_interaction_hint("Click to enter: " + rooms[room.name].description)
	elif room.name == "Elevator":
		game_hud.show_interaction_hint("Click to use elevator")

func _on_room_hover_exit(room: Area2D) -> void:
	var door = room.get_node_or_null("Door")
	if door:
		door.modulate = Color(1, 1, 1, 1)
	game_hud.hide_interaction_hint()

func _on_room_input(viewport: Node, event: InputEvent, shape_idx: int, room: Area2D) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_enter_room(room.name)

func _on_player_near_room(area: Area2D) -> void:
	var parent = area.get_parent()
	if rooms.has(parent.name):
		game_hud.show_interaction_hint("Press E to enter " + rooms[parent.name].name)
	elif parent.name == "Elevator":
		game_hud.show_interaction_hint("Press E to use elevator")

func _on_player_left_room(area: Area2D) -> void:
	game_hud.hide_interaction_hint()

func _enter_room(room_name: String) -> void:
	if room_name == "Elevator":
		_show_elevator_dialog()
		return
	
	if not rooms.has(room_name):
		return
	
	var room_data = rooms[room_name]
	AudioManager.play_sfx("door_open")
	
	EventBus.emit_signal("room_entered", room_data.name)
	emit_signal("room_entered", room_data.name)
	
	_show_room_dialog(room_name, room_data)

func _show_elevator_dialog() -> void:
	AudioManager.play_sfx("click")
	
	var dialog = _create_elevator_dialog()
	add_child(dialog)
	current_room_dialog = dialog
	GameManager.pause_game()

func _create_elevator_dialog() -> Control:
	var dialog = Control.new()
	dialog.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.8)
	dialog.add_child(bg)
	
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -150
	panel.offset_right = 150
	panel.offset_top = -180
	panel.offset_bottom = 180
	dialog.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 15
	vbox.offset_right = -15
	vbox.offset_top = 15
	vbox.offset_bottom = -15
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "Select Floor"
	title.add_theme_font_size_override("font_size", 24)
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
	
	return dialog

func _on_floor_selected(floor_num: int, dialog: Control) -> void:
	_close_dialog(dialog)
	if floor_num != current_floor:
		change_floor(floor_num)

func _show_room_dialog(room_name: String, room_data: Dictionary) -> void:
	var dialog = _create_room_dialog(room_name, room_data)
	add_child(dialog)
	current_room_dialog = dialog
	GameManager.pause_game()

func _create_room_dialog(room_name: String, room_data: Dictionary) -> Control:
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
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 15
	vbox.offset_bottom = -15
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = room_data.name
	title.add_theme_font_size_override("font_size", 26)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	# Add room-specific content
	var content = _get_room_content(room_name, room_data)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(content)
	
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(150, 40)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(func(): _close_dialog(dialog))
	vbox.add_child(close_btn)
	
	return dialog

func _get_room_content(room_name: String, room_data: Dictionary) -> Control:
	match room_name:
		"Room_Contracts":
			return _create_contracts_content()
		"Room_Dispatch":
			return _create_dispatch_content()
		"Room_TruckDealer1":
			return _create_truck_dealer_content()
		"Room_Garage":
			return _create_garage_content()
		"Room_HR":
			return _create_hr_content()
		"Room_Statistics":
			return _create_statistics_content()
		"Room_Home":
			return _create_home_content()
		"Room_Bank":
			return _create_bank_content()
		"Room_Accounting":
			return _create_accounting_content()
		_:
			return _create_generic_content(room_data)

func _create_contracts_content() -> Control:
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(vbox)
	
	var available = GameManager.contracts.filter(func(c): return c.status == "available")
	
	if available.is_empty():
		var label = Label.new()
		label.text = "No contracts available. Check back later!"
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(label)
	else:
		for contract in available.slice(0, 8):
			var card = _create_contract_card(contract)
			vbox.add_child(card)
	
	return scroll

func _create_contract_card(contract: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 90)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	card.add_child(hbox)
	
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var title_label = Label.new()
	title_label.text = "%s → %s" % [contract.origin, contract.destination]
	title_label.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(title_label)
	
	var details_label = Label.new()
	details_label.text = "%s | %.1f tons | %.0f km" % [contract.cargo_type, contract.cargo_weight, contract.distance]
	info_vbox.add_child(details_label)
	
	var deadline_label = Label.new()
	deadline_label.text = "Deadline: Day %d | %s" % [contract.deadline_day, contract.urgency.capitalize()]
	if contract.deadline_day <= GameManager.current_day + 1:
		deadline_label.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	info_vbox.add_child(deadline_label)
	
	hbox.add_child(info_vbox)
	
	var money_vbox = VBoxContainer.new()
	
	var payment_label = Label.new()
	payment_label.text = "€%.0f" % contract.payment
	payment_label.add_theme_font_size_override("font_size", 18)
	payment_label.add_theme_color_override("font_color", Color(0.4, 1, 0.5))
	money_vbox.add_child(payment_label)
	
	var accept_btn = Button.new()
	accept_btn.text = "Accept"
	accept_btn.custom_minimum_size = Vector2(80, 35)
	var cid = contract.id
	accept_btn.pressed.connect(func(): _accept_contract(cid))
	money_vbox.add_child(accept_btn)
	
	hbox.add_child(money_vbox)
	
	return card

func _accept_contract(contract_id: String) -> void:
	if GameManager.accept_contract(contract_id):
		EventBus.show_notification("Contract accepted!", "success")
		# Refresh dialog
		if current_room_dialog:
			_close_dialog(current_room_dialog)
			_enter_room("Room_Contracts")

func _create_dispatch_content() -> Control:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	var accepted = GameManager.contracts.filter(func(c): return c.status == "accepted")
	var available_trucks = GameManager.trucks.filter(func(t): return t.is_available)
	var available_drivers = GameManager.employees.filter(func(e): return e.role == "Driver" and e.is_available)
	
	if accepted.is_empty():
		var label = Label.new()
		label.text = "No accepted contracts. Go to Contracts to accept some first!"
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(label)
		return vbox
	
	if available_trucks.is_empty() or available_drivers.is_empty():
		var label = Label.new()
		label.text = "You need available trucks and drivers to dispatch deliveries."
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(label)
		return vbox
	
	var info = Label.new()
	info.text = "Available: %d trucks, %d drivers, %d contracts" % [available_trucks.size(), available_drivers.size(), accepted.size()]
	vbox.add_child(info)
	
	for contract in accepted.slice(0, 5):
		var card = _create_dispatch_card(contract, available_trucks, available_drivers)
		vbox.add_child(card)
	
	return vbox

func _create_dispatch_card(contract: Dictionary, trucks: Array, drivers: Array) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 80)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	card.add_child(hbox)
	
	var info = Label.new()
	info.text = "%s → %s\n€%.0f | Day %d deadline" % [contract.origin, contract.destination, contract.payment, contract.deadline_day]
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)
	
	var dispatch_btn = Button.new()
	dispatch_btn.text = "Dispatch"
	dispatch_btn.custom_minimum_size = Vector2(90, 40)
	var cid = contract.id
	var tid = trucks[0].id if trucks.size() > 0 else ""
	var did = drivers[0].id if drivers.size() > 0 else ""
	dispatch_btn.pressed.connect(func(): _dispatch_delivery(cid, tid, did))
	hbox.add_child(dispatch_btn)
	
	return card

func _dispatch_delivery(contract_id: String, truck_id: String, driver_id: String) -> void:
	if GameManager.start_delivery(contract_id, truck_id, driver_id):
		EventBus.show_notification("Delivery started!", "success")
		if current_room_dialog:
			_close_dialog(current_room_dialog)
			_enter_room("Room_Dispatch")
	else:
		EventBus.show_notification("Could not start delivery", "error")

func _create_truck_dealer_content() -> Control:
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(vbox)
	
	var money_label = Label.new()
	money_label.text = "Company funds: €%.0f" % GameManager.company_money
	money_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(money_label)
	
	var trucks_for_sale = [
		{"model": "MAN TGX 18.510", "price": 95000, "fuel": "diesel", "capacity": 25, "efficiency": 28},
		{"model": "Mercedes Actros 1845", "price": 102000, "fuel": "diesel", "capacity": 24, "efficiency": 26},
		{"model": "Volvo FH Electric", "price": 185000, "fuel": "electric", "capacity": 22, "efficiency": 120},
		{"model": "DAF XF 480", "price": 88000, "fuel": "diesel", "capacity": 24, "efficiency": 29},
		{"model": "Scania R500", "price": 98000, "fuel": "diesel", "capacity": 26, "efficiency": 27}
	]
	
	for truck in trucks_for_sale:
		var card = _create_truck_sale_card(truck)
		vbox.add_child(card)
	
	return scroll

func _create_truck_sale_card(truck: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 80)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	card.add_child(hbox)
	
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var name_label = Label.new()
	name_label.text = truck.model
	name_label.add_theme_font_size_override("font_size", 16)
	info.add_child(name_label)
	
	var specs = Label.new()
	specs.text = "%s | %d tons | %.0f L/100km" % [truck.fuel.capitalize(), truck.capacity, truck.efficiency]
	info.add_child(specs)
	
	hbox.add_child(info)
	
	var price_vbox = VBoxContainer.new()
	
	var price_label = Label.new()
	price_label.text = "€%.0f" % truck.price
	price_label.add_theme_font_size_override("font_size", 18)
	price_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	price_vbox.add_child(price_label)
	
	var buy_btn = Button.new()
	buy_btn.text = "Buy"
	buy_btn.custom_minimum_size = Vector2(70, 35)
	buy_btn.disabled = GameManager.company_money < truck.price
	var t = truck
	buy_btn.pressed.connect(func(): _buy_truck(t))
	price_vbox.add_child(buy_btn)
	
	hbox.add_child(price_vbox)
	
	return card

func _buy_truck(truck: Dictionary) -> void:
	if GameManager.buy_truck(truck.model, truck.price, truck.fuel, truck.capacity, truck.efficiency):
		EventBus.show_notification("Truck purchased: " + truck.model, "success")
		if current_room_dialog:
			_close_dialog(current_room_dialog)
			_enter_room("Room_TruckDealer1")

func _create_garage_content() -> Control:
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(vbox)
	
	if GameManager.trucks.is_empty():
		var label = Label.new()
		label.text = "No trucks in your fleet. Visit the Truck Dealer to buy some!"
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(label)
		return scroll
	
	for truck in GameManager.trucks:
		var card = _create_garage_truck_card(truck)
		vbox.add_child(card)
	
	return scroll

func _create_garage_truck_card(truck: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 90)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	card.add_child(hbox)
	
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var name_label = Label.new()
	name_label.text = truck.model
	name_label.add_theme_font_size_override("font_size", 16)
	info.add_child(name_label)
	
	var condition_label = Label.new()
	condition_label.text = "Condition: %.0f%% | Mileage: %.0f km" % [truck.condition, truck.mileage]
	if truck.condition < 50:
		condition_label.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	info.add_child(condition_label)
	
	var status_label = Label.new()
	status_label.text = "Available" if truck.is_available else "On delivery"
	status_label.add_theme_color_override("font_color", Color(0.4, 1, 0.5) if truck.is_available else Color(1, 0.8, 0.3))
	info.add_child(status_label)
	
	hbox.add_child(info)
	
	var buttons = VBoxContainer.new()
	
	var repair_cost = (100.0 - truck.condition) * truck.value * 0.002
	var repair_btn = Button.new()
	repair_btn.text = "Repair €%.0f" % repair_cost
	repair_btn.custom_minimum_size = Vector2(110, 32)
	repair_btn.disabled = not truck.is_available or truck.condition >= 99 or GameManager.company_money < repair_cost
	var tid = truck.id
	repair_btn.pressed.connect(func(): _repair_truck(tid))
	buttons.add_child(repair_btn)
	
	var sell_btn = Button.new()
	var sell_price = truck.value * (truck.condition / 100.0) * 0.7
	sell_btn.text = "Sell €%.0f" % sell_price
	sell_btn.custom_minimum_size = Vector2(110, 32)
	sell_btn.disabled = not truck.is_available
	sell_btn.pressed.connect(func(): _sell_truck(tid))
	buttons.add_child(sell_btn)
	
	hbox.add_child(buttons)
	
	return card

func _repair_truck(truck_id: String) -> void:
	if GameManager.repair_truck(truck_id):
		EventBus.show_notification("Truck repaired!", "success")
		if current_room_dialog:
			_close_dialog(current_room_dialog)
			_enter_room("Room_Garage")

func _sell_truck(truck_id: String) -> void:
	if GameManager.sell_truck(truck_id):
		EventBus.show_notification("Truck sold!", "success")
		if current_room_dialog:
			_close_dialog(current_room_dialog)
			_enter_room("Room_Garage")

func _create_hr_content() -> Control:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	var title = Label.new()
	title.text = "Current Employees: %d" % GameManager.employees.size()
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 200)
	
	var emp_vbox = VBoxContainer.new()
	emp_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(emp_vbox)
	
	for emp in GameManager.employees:
		var label = Label.new()
		label.text = "%s - %s | Skill: %.0f%% | €%.0f/mo" % [emp.name, emp.role, emp.skill, emp.salary]
		emp_vbox.add_child(label)
	
	vbox.add_child(scroll)
	
	var hire_btn = Button.new()
	hire_btn.text = "Hire New Driver (€3000/mo)"
	hire_btn.custom_minimum_size = Vector2(0, 40)
	hire_btn.pressed.connect(func(): _hire_driver())
	vbox.add_child(hire_btn)
	
	return vbox

func _hire_driver() -> void:
	var names = ["Hans Weber", "Peter Mueller", "Stefan Richter", "Thomas Klein", "Michael Bauer"]
	var name = names[randi() % names.size()]
	if GameManager.hire_employee("Driver", name):
		EventBus.show_notification("Hired " + name + " as driver!", "success")
		if current_room_dialog:
			_close_dialog(current_room_dialog)
			_enter_room("Room_HR")

func _create_statistics_content() -> Control:
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 30)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)
	
	var stats = [
		["Days in Business:", str(GameManager.current_day)],
		["Company Money:", "€%.0f" % GameManager.company_money],
		["Company Debt:", "€%.0f" % GameManager.company_debt],
		["Private Money:", "€%.0f" % GameManager.private_money],
		["Reputation:", "%.0f%%" % GameManager.company_reputation],
		["Total Trucks:", str(GameManager.trucks.size())],
		["Total Employees:", str(GameManager.employees.size())],
		["Deliveries Completed:", str(GameManager.total_deliveries_completed)],
		["Total Revenue:", "€%.0f" % GameManager.total_revenue],
		["Family Happiness:", "%.0f%%" % GameManager.family_happiness],
		["Social Status:", "%.0f%%" % GameManager.social_status]
	]
	
	for stat in stats:
		var label_name = Label.new()
		label_name.text = stat[0]
		grid.add_child(label_name)
		
		var label_value = Label.new()
		label_value.text = stat[1]
		label_value.add_theme_color_override("font_color", Color(0.4, 1, 0.5))
		grid.add_child(label_value)
	
	return scroll

func _create_home_content() -> Control:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	
	var status_label = Label.new()
	status_label.text = "Family Happiness: %.0f%% | Social Status: %.0f%%" % [GameManager.family_happiness, GameManager.social_status]
	status_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(status_label)
	
	var family_request = Label.new()
	family_request.text = "Your family would like some money for shopping..."
	family_request.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(family_request)
	
	var give_btn = Button.new()
	give_btn.text = "Give €500 to Family"
	give_btn.custom_minimum_size = Vector2(0, 40)
	give_btn.disabled = GameManager.private_money < 500
	give_btn.pressed.connect(func(): _give_family_money())
	vbox.add_child(give_btn)
	
	var can_retire = GameManager.can_retire()
	var retire_info = Label.new()
	if can_retire:
		retire_info.text = "You have achieved enough! You can retire."
		retire_info.add_theme_color_override("font_color", Color(0.4, 1, 0.5))
	else:
		retire_info.text = "Reach 75% social status and 50% family happiness to retire."
	vbox.add_child(retire_info)
	
	var retire_btn = Button.new()
	retire_btn.text = "Retire"
	retire_btn.custom_minimum_size = Vector2(0, 45)
	retire_btn.disabled = not can_retire
	retire_btn.pressed.connect(func(): _retire())
	vbox.add_child(retire_btn)
	
	return vbox

func _give_family_money() -> void:
	if GameManager.give_family_money(500):
		EventBus.show_notification("Your family is happy!", "success")
		if current_room_dialog:
			_close_dialog(current_room_dialog)
			_enter_room("Room_Home")

func _retire() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _create_bank_content() -> Control:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	
	var balance = Label.new()
	balance.text = "Company Balance: €%.0f | Debt: €%.0f" % [GameManager.company_money, GameManager.company_debt]
	balance.add_theme_font_size_override("font_size", 16)
	vbox.add_child(balance)
	
	var max_loan = GameManager.company_reputation * 1000
	var loan_info = Label.new()
	loan_info.text = "Maximum loan: €%.0f (based on reputation)" % max_loan
	vbox.add_child(loan_info)
	
	var amounts = [10000, 25000, 50000]
	for amount in amounts:
		var btn = Button.new()
		btn.text = "Take €%.0f Loan" % amount
		btn.custom_minimum_size = Vector2(0, 38)
		btn.disabled = GameManager.company_debt + amount > max_loan
		var a = amount
		btn.pressed.connect(func(): _take_loan(a))
		vbox.add_child(btn)
	
	if GameManager.company_debt > 0:
		var repay_btn = Button.new()
		repay_btn.text = "Repay €10,000"
		repay_btn.custom_minimum_size = Vector2(0, 38)
		repay_btn.disabled = GameManager.company_money < 10000 or GameManager.company_debt < 10000
		repay_btn.pressed.connect(func(): _repay_loan(10000))
		vbox.add_child(repay_btn)
	
	return vbox

func _take_loan(amount: float) -> void:
	if GameManager.take_loan(amount):
		EventBus.show_notification("Loan of €%.0f approved!" % amount, "success")
		if current_room_dialog:
			_close_dialog(current_room_dialog)
			_enter_room("Room_Bank")

func _repay_loan(amount: float) -> void:
	if GameManager.repay_loan(amount):
		EventBus.show_notification("Repaid €%.0f of loan" % amount, "success")
		if current_room_dialog:
			_close_dialog(current_room_dialog)
			_enter_room("Room_Bank")

func _create_accounting_content() -> Control:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 30)
	grid.add_theme_constant_override("v_separation", 6)
	
	var data = [
		["Company Balance:", "€%.0f" % GameManager.company_money],
		["Monthly Income:", "€%.0f" % GameManager.monthly_income],
		["Monthly Expenses:", "€%.0f" % GameManager.monthly_expenses],
		["Total Revenue:", "€%.0f" % GameManager.total_revenue],
		["Total Expenses:", "€%.0f" % GameManager.total_expenses],
		["Net Profit:", "€%.0f" % (GameManager.total_revenue - GameManager.total_expenses)]
	]
	
	for item in data:
		var label = Label.new()
		label.text = item[0]
		grid.add_child(label)
		
		var value = Label.new()
		value.text = item[1]
		grid.add_child(value)
	
	vbox.add_child(grid)
	
	return vbox

func _create_generic_content(room_data: Dictionary) -> Control:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	
	var desc = Label.new()
	desc.text = room_data.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc)
	
	var info = Label.new()
	info.text = "This room's functionality will be expanded in future updates."
	info.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	info.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(info)
	
	return vbox

func _close_dialog(dialog: Control) -> void:
	AudioManager.play_sfx("door_close")
	dialog.queue_free()
	current_room_dialog = null
	GameManager.resume_game()

# Pause menu handlers
func _on_resume_pressed() -> void:
	pause_menu.visible = false
	GameManager.resume_game()

func _on_save_pressed() -> void:
	if SaveManager.save_game(1):
		EventBus.show_notification("Game saved!", "success")

func _on_load_pressed() -> void:
	if SaveManager.load_game(1):
		EventBus.show_notification("Game loaded!", "success")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
