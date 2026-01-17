extends CanvasLayer
## AuthenticPlanerHUD - Exact recreation of classic Der Planer HUD interface

@onready var hud_container: Control
@onready var time_display: Label
@onready var money_display: Label
@onready var mission_time_display: Label
@onready var option_list: RichTextLabel
var hint_text: String = ""

const HUD_HEIGHT: int = 140
const LAPTOP_COLOR: Color = Color(0.25, 0.3, 0.35)
const DISPLAY_BG: Color = Color(0.08, 0.12, 0.16)  # Dark LCD background
const DISPLAY_GREEN: Color = Color(0.2, 1.0, 0.3)  # Bright green LCD
const DISPLAY_RED: Color = Color(0.8, 0.0, 0.0)    # Red LCD for money/time
const BEIGE_PANEL: Color = Color(0.95, 0.88, 0.72)  # Authentic beige
const GRAY_PANEL: Color = Color(0.22, 0.24, 0.28)

func _ready() -> void:
	_create_authentic_planer_hud()
	GameManager.money_changed.connect(_update_money)
	_update_all()

func _create_authentic_planer_hud() -> void:
	# Main HUD container
	hud_container = Control.new()
	hud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(hud_container)

	# Bottom panel background (dark gray - authentic Der Planer color)
	var bottom_bg = ColorRect.new()
	bottom_bg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_bg.size.y = HUD_HEIGHT
	bottom_bg.offset_top = -HUD_HEIGHT
	bottom_bg.color = GRAY_PANEL
	hud_container.add_child(bottom_bg)

	# Create laptop graphic (left side) - authentic Der Planer style
	_create_authentic_laptop(bottom_bg)

	# Create calculator (middle-left) - authentic style
	_create_authentic_calculator(bottom_bg)

	# Create digital displays (middle) - green LCD clock + red mission timer
	_create_authentic_displays(bottom_bg)

	# Create option list panel (right side - beige with numbered options)
	_create_authentic_option_panel(bottom_bg)

func _create_authentic_laptop(parent: Control) -> void:
	# Laptop base with authentic proportions
	var laptop_base = ColorRect.new()
	laptop_base.position = Vector2(15, 65)
	laptop_base.size = Vector2(150, 65)
	laptop_base.color = LAPTOP_COLOR
	parent.add_child(laptop_base)

	# Laptop screen (dark background)
	var screen = ColorRect.new()
	screen.position = Vector2(15, 8)
	screen.size = Vector2(120, 40)
	screen.color = DISPLAY_BG
	laptop_base.add_child(screen)

	# Screen content - green text lines (simulating code/text)
	var line_texts = ["SYSTEM OK", "ROUTES: 12", "DRIVERS: 8", "PROFIT +"]
	for i in range(4):
		var line = Label.new()
		line.text = line_texts[i]
		line.position = Vector2(5, 2 + i * 9)
		line.add_theme_font_size_override("font_size", 8)
		line.add_theme_color_override("font_color", DISPLAY_GREEN)
		screen.add_child(line)

	# Keyboard area (dark strip)
	var keyboard = ColorRect.new()
	keyboard.position = Vector2(10, 50)
	keyboard.size = Vector2(130, 12)
	keyboard.color = Color(0.15, 0.17, 0.2)
	laptop_base.add_child(keyboard)

	# Keyboard keys (rectangular buttons)
	for x in range(14):
		var key = ColorRect.new()
		key.position = Vector2(12 + x * 9, 52)
		key.size = Vector2(7, 8)
		key.color = Color(0.28, 0.3, 0.33)
		laptop_base.add_child(key)

func _create_authentic_calculator(parent: Control) -> void:
	# Calculator body - authentic Der Planer proportions
	var calc_bg = ColorRect.new()
	calc_bg.position = Vector2(180, 70)
	calc_bg.size = Vector2(70, 60)
	calc_bg.color = Color(0.28, 0.3, 0.33)
	parent.add_child(calc_bg)

	# Calculator display (dark LCD)
	var display = ColorRect.new()
	display.position = Vector2(5, 5)
	display.size = Vector2(60, 14)
	display.color = DISPLAY_BG
	calc_bg.add_child(display)

	# Display number
	var display_num = Label.new()
	display_num.text = "888.88"
	display_num.position = Vector2(8, 2)
	display_num.add_theme_font_size_override("font_size", 10)
	display_num.add_theme_color_override("font_color", DISPLAY_GREEN)
	display.add_child(display_num)

	# Buttons grid (4x3) - authentic layout
	var button_layout = [
		["1", "2", "3"],
		["4", "5", "6"],
		["7", "8", "9"],
		["+", "0", "#"]
	]

	for row in range(4):
		for col in range(3):
			var btn = ColorRect.new()
			btn.position = Vector2(5 + col * 20, 22 + row * 10)
			btn.size = Vector2(18, 8)
			btn.color = Color(0.38, 0.4, 0.43)
			calc_bg.add_child(btn)

			# Button label
			var label = Label.new()
			label.text = button_layout[row][col]
			label.position = Vector2(6, -1)
			label.add_theme_font_size_override("font_size", 8)
			label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
			btn.add_child(label)

func _create_authentic_displays(parent: Control) -> void:
	# Display container
	var display_box = ColorRect.new()
	display_box.position = Vector2(265, 70)
	display_box.size = Vector2(120, 60)
	display_box.color = Color(0.18, 0.2, 0.23)
	parent.add_child(display_box)

	# Clock display (green LCD) - top section
	var clock_bg = ColorRect.new()
	clock_bg.position = Vector2(5, 5)
	clock_bg.size = Vector2(110, 22)
	clock_bg.color = DISPLAY_BG
	display_box.add_child(clock_bg)

	# Clock icon/symbol
	var clock_icon = Label.new()
	clock_icon.text = "⏰"
	clock_icon.position = Vector2(5, 2)
	clock_icon.add_theme_font_size_override("font_size", 14)
	clock_icon.add_theme_color_override("font_color", DISPLAY_GREEN)
	clock_bg.add_child(clock_icon)

	# Time display
	time_display = Label.new()
	time_display.position = Vector2(30, 4)
	time_display.text = "12:33"
	time_display.add_theme_font_size_override("font_size", 14)
	time_display.add_theme_color_override("font_color", DISPLAY_GREEN)
	clock_bg.add_child(time_display)

	# Mission timer display (red LCD) - bottom section
	var timer_bg = ColorRect.new()
	timer_bg.position = Vector2(5, 30)
	timer_bg.size = Vector2(110, 25)
	timer_bg.color = Color(0.45, 0.08, 0.08)  # Dark red background
	display_box.add_child(timer_bg)

	# Mission time label
	var mission_label = Label.new()
	mission_label.text = "ma:"
	mission_label.position = Vector2(5, 2)
	mission_label.add_theme_font_size_override("font_size", 10)
	mission_label.add_theme_color_override("font_color", Color(1, 1, 1))
	timer_bg.add_child(mission_label)

	# Mission time value
	mission_time_display = Label.new()
	mission_time_display.position = Vector2(5, 12)
	mission_time_display.text = "04:04:37"
	mission_time_display.add_theme_font_size_override("font_size", 12)
	mission_time_display.add_theme_color_override("font_color", Color(1, 1, 1))
	timer_bg.add_child(mission_time_display)

	# Money/resource display
	money_display = Label.new()
	money_display.position = Vector2(65, 8)
	money_display.text = "250 m"
	money_display.add_theme_font_size_override("font_size", 14)
	money_display.add_theme_color_override("font_color", DISPLAY_GREEN)
	timer_bg.add_child(money_display)

func _create_authentic_option_panel(parent: Control) -> void:
	# Beige option panel (right side) - authentic Der Planer style
	var panel = ColorRect.new()
	panel.position = Vector2(400, 70)
	panel.size = Vector2(280, 60)
	panel.color = BEIGE_PANEL
	parent.add_child(panel)

	# Top border (darker beige)
	var border_top = ColorRect.new()
	border_top.position = Vector2(0, 0)
	border_top.size = Vector2(280, 2)
	border_top.color = Color(0.65, 0.58, 0.45)
	panel.add_child(border_top)

	# Option list with numbered menu items
	option_list = RichTextLabel.new()
	option_list.position = Vector2(8, 6)
	option_list.size = Vector2(264, 48)
	option_list.bbcode_enabled = true
	option_list.fit_content = true
	option_list.scroll_active = false
	option_list.add_theme_font_size_override("normal_font_size", 11)
	option_list.add_theme_color_override("default_color", Color(0.1, 0.1, 0.1))
	panel.add_child(option_list)

	_update_options()

func _update_options() -> void:
	if option_list:
		# Authentic Der Planer menu style with numbers
		option_list.text = "[b]2.[/b] LKUART WECHSELN\n[b]3.[/b] TELEFON KAUFEN\n[b]4.[/b] ZURUECK"

func _process(_delta: float) -> void:
	_update_time()
	_update_mission_time()

func _update_time() -> void:
	if time_display:
		var hour = GameManager.current_hour
		var minute = GameManager.current_minute
		time_display.text = "%02d:%02d" % [hour, minute]

func _update_mission_time() -> void:
	if mission_time_display:
		# Calculate mission elapsed time
		var total_minutes = GameManager.current_day * 24 * 60 + GameManager.current_hour * 60 + GameManager.current_minute
		var hours = int(total_minutes / 60)
		var minutes = int(total_minutes % 60)
		var seconds = int((GameManager.current_minute % 1.0) * 60)
		mission_time_display.text = "%02d:%02d:%02d" % [hours % 100, minutes, seconds]

func _update_money(_company_money: float = 0.0, _private_money: float = 0.0) -> void:
	if money_display:
		var money = GameManager.company_money
		# Format like "250 m" (m for thousand in German - "Tausend")
		if money >= 1000000:
			money_display.text = "%.0f m" % (money / 1000.0)
		elif money >= 1000:
			money_display.text = "%.0f m" % (money / 1000.0)
		else:
			money_display.text = "%.0f" % money

func _update_all() -> void:
	_update_time()
	_update_mission_time()
	_update_money()

func _format_money(amount: float) -> String:
	# German style formatting
	if amount >= 1000000:
		return "%.1fM" % (amount / 1000000.0)
	elif amount >= 1000:
		var thousands = int(amount / 1000)
		var remainder = int(amount) % 1000
		return "%d.%03d" % [thousands, remainder]
	else:
		return "%.0f" % amount

func show_hint(text: String) -> void:
	hint_text = text
	if option_list:
		option_list.text = "[b]HINWEIS:[/b]\n%s\n\n[b]4.[/b] ZURUECK" % text

func hide_hint() -> void:
	hint_text = ""
	_update_options()

func update_location(location: String) -> void:
	# Could show location in option panel
	pass

func show_interaction_hint(text: String) -> void:
	show_hint(text)

func hide_interaction_hint() -> void:
	hide_hint()
