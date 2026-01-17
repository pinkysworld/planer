extends CanvasLayer
## ClassicHUD - Der Planer-style HUD at bottom of screen

@onready var bottom_panel: ColorRect
@onready var time_label: Label
@onready var date_label: Label
@onready var money_label: Label
@onready var reputation_label: Label
@onready var trucks_label: Label
@onready var contracts_label: Label
@onready var hint_label: Label

const PANEL_HEIGHT: int = 100
const PANEL_COLOR: Color = Color(0.15, 0.2, 0.25, 0.95)
const TEXT_COLOR: Color = Color(0.9, 0.95, 1.0)
const VALUE_COLOR: Color = Color(0.4, 1.0, 0.5)
const URGENT_COLOR: Color = Color(1.0, 0.4, 0.4)

func _ready() -> void:
	_create_ui()
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.reputation_changed.connect(_on_reputation_changed)
	EventBus.day_passed.connect(_update_date)
	_update_all()

func _create_ui() -> void:
	# Bottom panel
	bottom_panel = ColorRect.new()
	bottom_panel.color = PANEL_COLOR
	bottom_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_panel.size.y = PANEL_HEIGHT
	bottom_panel.offset_top = -PANEL_HEIGHT
	add_child(bottom_panel)

	# Container for info
	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 25)
	hbox.offset_left = 20
	hbox.offset_right = -20
	hbox.offset_top = 10
	hbox.offset_bottom = -10
	bottom_panel.add_child(hbox)

	# Date & Time section
	var time_section = _create_info_section("TIME", "09:00")
	time_label = time_section.get_node("Value")
	hbox.add_child(time_section)

	var date_section = _create_info_section("DATE", "Day 1")
	date_label = date_section.get_node("Value")
	hbox.add_child(date_section)

	# Money section
	var money_section = _create_info_section("MONEY", "€50,000")
	money_label = money_section.get_node("Value")
	money_label.add_theme_color_override("font_color", VALUE_COLOR)
	hbox.add_child(money_section)

	# Reputation section
	var rep_section = _create_info_section("REPUTATION", "100%")
	reputation_label = rep_section.get_node("Value")
	reputation_label.add_theme_color_override("font_color", VALUE_COLOR)
	hbox.add_child(rep_section)

	# Trucks section
	var trucks_section = _create_info_section("TRUCKS", "0")
	trucks_label = trucks_section.get_node("Value")
	hbox.add_child(trucks_section)

	# Contracts section
	var contracts_section = _create_info_section("CONTRACTS", "0")
	contracts_label = contracts_section.get_node("Value")
	hbox.add_child(contracts_section)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# Hint label (right side)
	hint_label = Label.new()
	hint_label.text = "Click to move • Click doors to enter"
	hint_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	hint_label.add_theme_font_size_override("font_size", 14)
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(hint_label)

func _create_info_section(title: String, value: String) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_color_override("font_color", TEXT_COLOR)
	title_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(title_label)

	var value_label = Label.new()
	value_label.name = "Value"
	value_label.text = value
	value_label.add_theme_color_override("font_color", TEXT_COLOR)
	value_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(value_label)

	return vbox

func _update_all() -> void:
	_update_time()
	_update_date()
	_update_money()
	_update_reputation()
	_update_trucks()
	_update_contracts()

func _process(delta: float) -> void:
	_update_time()

func _update_time() -> void:
	if time_label:
		var hour = GameManager.current_hour
		var minute = GameManager.current_minute
		time_label.text = "%02d:%02d" % [hour, minute]

func _update_date() -> void:
	if date_label:
		date_label.text = "Day %d" % GameManager.current_day

func _on_money_changed(company: float, private: float) -> void:
	_update_money()

func _update_money() -> void:
	if money_label:
		money_label.text = "€%s" % _format_money(GameManager.company_money)

func _on_reputation_changed(new_rep: float) -> void:
	_update_reputation()

func _update_reputation() -> void:
	if reputation_label:
		reputation_label.text = "%.0f%%" % GameManager.company_reputation

func _update_trucks() -> void:
	if trucks_label:
		var available = GameManager.trucks.filter(func(t): return t.is_available).size()
		trucks_label.text = "%d/%d" % [available, GameManager.trucks.size()]

func _update_contracts() -> void:
	if contracts_label:
		var active = GameManager.contracts.filter(func(c): return c.status == "accepted").size()
		contracts_label.text = "%d" % active

func show_hint(text: String) -> void:
	if hint_label:
		hint_label.text = text

func hide_hint() -> void:
	if hint_label:
		hint_label.text = "Click to move • Click doors to enter"

func update_location(location: String) -> void:
	# Can add a location label if needed
	pass

func show_interaction_hint(text: String) -> void:
	show_hint(text)

func hide_interaction_hint() -> void:
	hide_hint()

func _format_money(amount: float) -> String:
	if amount >= 1000000:
		return "%.1fM" % (amount / 1000000.0)
	elif amount >= 1000:
		return "%.1fK" % (amount / 1000.0)
	else:
		return "%.0f" % amount
