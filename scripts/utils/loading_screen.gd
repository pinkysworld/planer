extends CanvasLayer
## LoadingScreen - Professional loading screen with progress bar

@onready var progress_bar: ProgressBar
@onready var tip_label: Label
@onready var spinner: Control

var tips: Array[String] = [
	"Tip: Keep your trucks well-maintained to avoid breakdowns",
	"Tip: Higher reputation means better contract offers",
	"Tip: Expand to multiple cities to increase profit",
	"Tip: Hire skilled drivers for faster deliveries",
	"Tip: Check fuel prices - they change based on market conditions",
	"Tip: Insurance can save you from expensive repairs",
	"Tip: Research new technologies to improve efficiency",
	"Tip: Balance work and family life for best results",
	"Tip: Luxury items increase your social status",
	"Tip: Monitor your competitors' activities"
]

func _ready() -> void:
	_create_loading_screen()
	_start_spinner_animation()

func _create_loading_screen() -> void:
	# Background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.12, 0.15)
	add_child(bg)

	# Logo/Title
	var title = Label.new()
	title.text = "DER PLANER"
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 150
	title.offset_left = -300
	title.offset_right = 300
	add_child(title)

	# Spinner
	spinner = Control.new()
	spinner.set_anchors_preset(Control.PRESET_CENTER)
	spinner.offset_left = -32
	spinner.offset_right = 32
	spinner.offset_top = -32
	spinner.offset_bottom = 32
	add_child(spinner)

	for i in range(8):
		var dot = ColorRect.new()
		dot.size = Vector2(8, 8)
		var angle = (PI * 2.0 * i) / 8.0
		dot.position = Vector2(cos(angle) * 24, sin(angle) * 24) + Vector2(28, 28)
		dot.color = Color(0.6, 0.8, 1.0, 1.0 - float(i) / 8.0)
		spinner.add_child(dot)

	# Progress bar container
	var progress_container = VBoxContainer.new()
	progress_container.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	progress_container.offset_left = -300
	progress_container.offset_right = 300
	progress_container.offset_top = -150
	progress_container.offset_bottom = -50
	progress_container.add_theme_constant_override("separation", 15)
	add_child(progress_container)

	# Progress bar
	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(600, 30)
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0

	var progress_style = StyleBoxFlat.new()
	progress_style.bg_color = Color(0.3, 0.6, 0.9)
	progress_style.corner_radius_top_left = 4
	progress_style.corner_radius_top_right = 4
	progress_style.corner_radius_bottom_left = 4
	progress_style.corner_radius_bottom_right = 4
	progress_bar.add_theme_stylebox_override("fill", progress_style)

	progress_container.add_child(progress_bar)

	# Tip label
	tip_label = Label.new()
	tip_label.text = tips[randi() % tips.size()]
	tip_label.add_theme_font_size_override("font_size", 16)
	tip_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	progress_container.add_child(tip_label)

func _start_spinner_animation() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(spinner, "rotation", PI * 2, 1.0)

func set_progress(value: float) -> void:
	if progress_bar:
		progress_bar.value = value

func show_loading() -> void:
	show()
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func hide_loading() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(hide)
