extends Control
## HRDialog - Hire and manage employees

signal closed

@onready var employees_container = $"Panel/VBox/TabContainer/Current Employees/EmployeesContainer"
@onready var candidates_container = $"Panel/VBox/TabContainer/Hire New/CandidatesScroll/CandidatesContainer"
@onready var role_dropdown = $"Panel/VBox/TabContainer/Hire New/RoleSelection/RoleDropdown"
@onready var info_label = $Panel/VBox/Footer/InfoLabel

var roles: Array = ["Driver", "Mechanic", "Secretary", "Accountant", "Manager"]
var generated_candidates: Array = []

# Name pools for generating random employee names
var first_names: Array = [
	"Klaus", "Hans", "Peter", "Michael", "Thomas", "Andreas", "Stefan",
	"Maria", "Anna", "Sarah", "Lisa", "Julia", "Sophie", "Emma",
	"Max", "Felix", "Leon", "Lukas", "Tim", "Jan", "Markus"
]

var last_names: Array = [
	"Mueller", "Schmidt", "Schneider", "Fischer", "Weber", "Meyer",
	"Wagner", "Becker", "Schulz", "Hoffmann", "Koch", "Richter",
	"Klein", "Wolf", "Schroeder", "Neumann", "Schwarz", "Braun"
]

func _ready() -> void:
	_setup_role_dropdown()
	_refresh_employees()

func _setup_role_dropdown() -> void:
	role_dropdown.clear()
	for role in roles:
		role_dropdown.add_item(role)

func _refresh_employees() -> void:
	for child in employees_container.get_children():
		child.queue_free()

	if GameManager.employees.is_empty():
		var label = Label.new()
		label.text = "No employees yet. Go to 'Hire New' tab to hire staff."
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		employees_container.add_child(label)
		return

	for employee in GameManager.employees:
		var card = _create_employee_card(employee)
		employees_container.add_child(card)

func _create_employee_card(employee: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 90)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)

	# Employee info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label = Label.new()
	name_label.text = "%s - %s" % [employee.name, employee.role]
	name_label.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(name_label)

	var stats_label = Label.new()
	stats_label.text = "Skill: %.0f%% | Experience: %.1f years" % [employee.skill, employee.experience]
	info_vbox.add_child(stats_label)

	var status_label = Label.new()
	if employee.is_available:
		status_label.text = "Available"
		status_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
	else:
		status_label.text = "On assignment"
		status_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	info_vbox.add_child(status_label)

	hbox.add_child(info_vbox)

	# Salary and morale
	var stats_vbox = VBoxContainer.new()

	var salary_label = Label.new()
	salary_label.text = "€%.0f/month" % employee.salary
	salary_label.add_theme_font_size_override("font_size", 16)
	stats_vbox.add_child(salary_label)

	var morale_label = Label.new()
	morale_label.text = "Morale: %.0f%%" % employee.morale
	if employee.morale < 40:
		morale_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	elif employee.morale > 70:
		morale_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
	stats_vbox.add_child(morale_label)

	hbox.add_child(stats_vbox)

	# Fire button
	var fire_btn = Button.new()
	fire_btn.text = "Fire"
	fire_btn.custom_minimum_size = Vector2(80, 40)
	fire_btn.disabled = not employee.is_available
	var emp_id = employee.id
	fire_btn.pressed.connect(func(): _fire_employee(emp_id))
	hbox.add_child(fire_btn)

	return card

func _generate_candidates() -> void:
	AudioManager.play_sfx("paper_shuffle")

	for child in candidates_container.get_children():
		child.queue_free()

	generated_candidates.clear()
	var selected_role = roles[role_dropdown.selected]

	# Generate 3-5 random candidates
	for i in range(randi_range(3, 5)):
		var candidate = _generate_random_candidate(selected_role)
		generated_candidates.append(candidate)

		var card = _create_candidate_card(candidate)
		candidates_container.add_child(card)

	info_label.text = "Found %d candidates for %s position" % [generated_candidates.size(), selected_role]

func _generate_random_candidate(role: String) -> Dictionary:
	var first_name = first_names[randi() % first_names.size()]
	var last_name = last_names[randi() % last_names.size()]

	var base_salary = 0.0
	match role:
		"Driver": base_salary = randf_range(2500.0, 3200.0)
		"Mechanic": base_salary = randf_range(2800.0, 3600.0)
		"Secretary": base_salary = randf_range(2200.0, 2800.0)
		"Accountant": base_salary = randf_range(3000.0, 4000.0)
		"Manager": base_salary = randf_range(4000.0, 5500.0)

	return {
		"name": first_name + " " + last_name,
		"role": role,
		"salary": snapped(base_salary, 100.0),
		"skill": randf_range(40.0, 95.0),
		"experience": randf_range(0.5, 15.0)
	}

func _create_candidate_card(candidate: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 80)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)

	# Candidate info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label = Label.new()
	name_label.text = candidate.name
	name_label.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(name_label)

	var stats_label = Label.new()
	stats_label.text = "Skill: %.0f%% | Experience: %.1f years" % [candidate.skill, candidate.experience]
	info_vbox.add_child(stats_label)

	hbox.add_child(info_vbox)

	# Salary
	var salary_label = Label.new()
	salary_label.text = "€%.0f/month" % candidate.salary
	salary_label.add_theme_font_size_override("font_size", 16)
	salary_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	hbox.add_child(salary_label)

	# Hire button
	var hire_btn = Button.new()
	hire_btn.text = "Hire"
	hire_btn.custom_minimum_size = Vector2(80, 40)
	var cand = candidate
	hire_btn.pressed.connect(func(): _hire_candidate(cand, card))
	hbox.add_child(hire_btn)

	return card

func _hire_candidate(candidate: Dictionary, card: Control) -> void:
	AudioManager.play_sfx("stamp")

	if GameManager.hire_employee(candidate.role, candidate.name):
		# Update the newly hired employee with candidate's stats
		var hired = GameManager.employees.back()
		hired.salary = candidate.salary
		hired.skill = candidate.skill
		hired.experience = candidate.experience

		info_label.text = "Hired %s as %s!" % [candidate.name, candidate.role]
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))

		card.queue_free()
		_refresh_employees()
	else:
		info_label.text = "Cannot afford to hire this employee (first month's salary required)."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _fire_employee(employee_id: String) -> void:
	AudioManager.play_sfx("click")

	if GameManager.fire_employee(employee_id):
		info_label.text = "Employee terminated. Severance pay deducted."
		info_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
		_refresh_employees()
	else:
		info_label.text = "Cannot fire this employee (currently on assignment)."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
