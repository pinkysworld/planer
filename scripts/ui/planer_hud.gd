extends CanvasLayer
## PlanerHUD - Authentic Der Planer bottom interface

@onready var hud_container: Control
@onready var time_display: Label
@onready var money_display: Label
@onready var fuel_bar: ProgressBar
@onready var option_list: RichTextLabel

const HUD_HEIGHT: int = 140
const LAPTOP_COLOR: Color = Color(0.25, 0.3, 0.35)
const DISPLAY_BG: Color = Color(0.15, 0.2, 0.15)
const DISPLAY_GREEN: Color = Color(0.3, 1, 0.4)
const BEIGE_PANEL: Color = Color(0.92, 0.85, 0.7)

func _ready() -> void:
	_create_authentic_hud()
	GameManager.money_changed.connect(_update_money)
	_update_all()

func _create_authentic_hud() -> void:
	# Main HUD container
	hud_container = Control.new()
	hud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(hud_container)

	# Bottom panel background (dark gray)
	var bottom_bg = ColorRect.new()
	bottom_bg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_bg.size.y = HUD_HEIGHT
	bottom_bg.offset_top = -HUD_HEIGHT
	bottom_bg.color = Color(0.2, 0.22, 0.25)
	hud_container.add_child(bottom_bg)

	# Create laptop graphic (left side)
	_create_laptop_graphic(bottom_bg)

	# Create calculator (middle-left)
	_create_calculator(bottom_bg)

	# Create time/money displays (middle)
	_create_displays(bottom_bg)

	# Create fuel/status bars (middle-right)
	_create_status_bars(bottom_bg)

	# Create option list (right side - beige panel)
	_create_option_panel(bottom_bg)

func _create_laptop_graphic(parent: Control) -> void:
	# Laptop base
	var laptop_base = ColorRect.new()
	laptop_base.position = Vector2(15, 70)
	laptop_base.size = Vector2(140, 60)
	laptop_base.color = LAPTOP_COLOR
	parent.add_child(laptop_base)

	# Laptop screen
	var screen = ColorRect.new()
	screen.position = Vector2(25, 15)
	screen.size = Vector2(120, 35)
	screen.color = Color(0.1, 0.15, 0.2)
	laptop_base.add_child(screen)

	# Screen content (green lines - simulating text)
	for i in range(4):
		var line = ColorRect.new()
		line.position = Vector2(5, 5 + i * 7)
		line.size = Vector2(80, 2)
		line.color = DISPLAY_GREEN
		screen.add_child(line)

	# Keyboard area
	var keyboard = ColorRect.new()
	keyboard.position = Vector2(10, 52)
	keyboard.size = Vector2(120, 6)
	keyboard.color = Color(0.15, 0.18, 0.2)
	laptop_base.add_child(keyboard)

	# Keyboard keys (dots)
	for x in range(12):
		for y in range(1):
			var key = ColorRect.new()
			key.position = Vector2(12 + x * 9, 54 + y * 3)
			key.size = Vector2(6, 2)
			key.color = Color(0.3, 0.32, 0.35)
			laptop_base.add_child(key)

func _create_calculator(parent: Control) -> void:
	var calc_bg = ColorRect.new()
	calc_bg.position = Vector2(170, 75)
	calc_bg.size = Vector2(60, 55)
	calc_bg.color = Color(0.25, 0.27, 0.3)
	parent.add_child(calc_bg)

	# Calculator display
	var display = ColorRect.new()
	display.position = Vector2(5, 5)
	display.size = Vector2(50, 12)
	display.color = DISPLAY_BG
	calc_bg.add_child(display)

	# Buttons (3x4 grid)
	for row in range(4):
		for col in range(3):
			var btn = ColorRect.new()
			btn.position = Vector2(5 + col * 17, 20 + row * 9)
			btn.size = Vector2(15, 7)
			btn.color = Color(0.35, 0.37, 0.4)
			calc_bg.add_child(btn)

			# Button label
			var label = Label.new()
			var numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "0", "#"]
			label.text = numbers[row * 3 + col]
			label.position = Vector2(5, -2)
			label.add_theme_font_size_override("font_size", 8)
			label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
			btn.add_child(label)

func _create_displays(parent: Control) -> void:
	# Time display box
	var time_box = ColorRect.new()
	time_box.position = Vector2(245, 75)
	time_box.size = Vector2(100, 55)
	time_box.color = Color(0.18, 0.2, 0.22)
	parent.add_child(time_box)

	# Clock icon background
	var clock_bg = ColorRect.new()
	clock_bg.position = Vector2(5, 5)
	clock_bg.size = Vector2(90, 20)
	clock_bg.color = DISPLAY_BG
	time_box.add_child(clock_bg)

	# Time label
	time_display = Label.new()
	time_display.position = Vector2(15, 2)
	time_display.text = "12:33"
	time_display.add_theme_font_size_override("font_size", 14)
	time_display.add_theme_color_override("font_color", DISPLAY_GREEN)
	clock_bg.add_child(time_display)

	# Money display (red background)
	var money_bg = ColorRect.new()
	money_bg.position = Vector2(5, 28)
	money_bg.size = Vector2(90, 22)
	money_bg.color = Color(0.5, 0.1, 0.1)
	time_box.add_child(money_bg)

	# Money label
	money_display = Label.new()
	money_display.position = Vector2(5, 4)
	money_display.text = "€ 50,000"
	money_display.add_theme_font_size_override("font_size", 12)
	money_display.add_theme_color_override("font_color", Color(1, 1, 1))
	money_bg.add_child(money_display)

func _create_status_bars(parent: Control) -> void:
	var bars_container = Control.new()
	bars_container.position = Vector2(360, 75)
	parent.add_child(bars_container)

	# Fuel bar
	var fuel_label = Label.new()
	fuel_label.text = "FUEL"
	fuel_label.position = Vector2(0, 0)
	fuel_label.add_theme_font_size_override("font_size", 10)
	fuel_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	bars_container.add_child(fuel_label)

	fuel_bar = ProgressBar.new()
	fuel_bar.position = Vector2(0, 15)
	fuel_bar.size = Vector2(150, 12)
	fuel_bar.min_value = 0
	fuel_bar.max_value = 100
	fuel_bar.value = 75
	bars_container.add_child(fuel_bar)

	# Style fuel bar
	var fuel_style = StyleBoxFlat.new()
	fuel_style.bg_color = Color(0.2, 0.7, 0.2)
	fuel_bar.add_theme_stylebox_override("fill", fuel_style)

	# Money bar
	var money_label = Label.new()
	money_label.text = "BALANCE"
	money_label.position = Vector2(0, 32)
	money_label.add_theme_font_size_override("font_size", 10)
	money_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	bars_container.add_child(money_label)

	var money_bar = ProgressBar.new()
	money_bar.position = Vector2(0, 47)
	money_bar.size = Vector2(150, 12)
	money_bar.min_value = 0
	money_bar.max_value = 100
	money_bar.value = 60
	bars_container.add_child(money_bar)

	var money_style = StyleBoxFlat.new()
	money_style.bg_color = Color(0.9, 0.7, 0.2)
	money_bar.add_theme_stylebox_override("fill", money_style)

func _create_option_panel(parent: Control) -> void:
	# Beige panel on the right
	var panel = ColorRect.new()
	panel.position = Vector2(530, 75)
	panel.size = Vector2(240, 55)
	panel.color = BEIGE_PANEL
	parent.add_child(panel)

	# Border
	var border_top = ColorRect.new()
	border_top.position = Vector2(0, 0)
	border_top.size = Vector2(240, 2)
	border_top.color = Color(0.4, 0.35, 0.25)
	panel.add_child(border_top)

	# Option list
	option_list = RichTextLabel.new()
	option_list.position = Vector2(5, 5)
	option_list.size = Vector2(230, 45)
	option_list.bbcode_enabled = true
	option_list.fit_content = true
	option_list.scroll_active = false
	option_list.add_theme_font_size_override("normal_font_size", 10)
	option_list.add_theme_color_override("default_color", Color(0.1, 0.1, 0.1))
	panel.add_child(option_list)

	_update_options()

func _update_options() -> void:
	if option_list:
		option_list.text = "[b]1.[/b] OFFICE\n[b]2.[/b] CONTRACTS\n[b]3.[/b] GARAGE\n[b]4.[/b] BACK"

func _process(delta: float) -> void:
	_update_time()

func _update_time() -> void:
	if time_display:
		var hour = GameManager.current_hour
		var minute = GameManager.current_minute
		time_display.text = "%02d:%02d" % [hour, minute]

func _update_money() -> void:
	if money_display:
		var money = GameManager.company_money
		money_display.text = "€ %s" % _format_money(money)

func _update_all() -> void:
	_update_time()
	_update_money()

func _format_money(amount: float) -> String:
	if amount >= 1000000:
		return "%.1fM" % (amount / 1000000.0)
	elif amount >= 1000:
		return "%d,%03d" % [int(amount / 1000), int(amount) % 1000]
	else:
		return "%.0f" % amount

func show_hint(text: String) -> void:
	# Can show hints in the option list
	pass

func hide_hint() -> void:
	_update_options()

func update_location(location: String) -> void:
	# Could show location in HUD
	pass

func show_interaction_hint(text: String) -> void:
	show_hint(text)

func hide_interaction_hint() -> void:
	hide_hint()
