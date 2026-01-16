extends Control
## StatisticsDialog - View company performance statistics

signal closed

@onready var stats_grid = $Panel/VBox/StatsGrid

func _ready() -> void:
	_refresh_statistics()

func _refresh_statistics() -> void:
	for child in stats_grid.get_children():
		child.queue_free()

	var stats = [
		["Days in Business", "%d" % GameManager.current_day],
		["Current Time", "%02d:%02d" % [GameManager.current_hour, GameManager.current_minute]],
		["", ""],
		["--- FINANCES ---", ""],
		["Company Money", "€%.0f" % GameManager.company_money],
		["Company Debt", "€%.0f" % GameManager.company_debt],
		["Private Money", "€%.0f" % GameManager.private_money],
		["Monthly Salary", "€%.0f" % GameManager.monthly_salary],
		["Total Revenue", "€%.0f" % GameManager.total_revenue],
		["Total Expenses", "€%.0f" % GameManager.total_expenses],
		["Net Profit", "€%.0f" % (GameManager.total_revenue - GameManager.total_expenses)],
		["", ""],
		["--- OPERATIONS ---", ""],
		["Total Deliveries", "%d" % GameManager.total_deliveries_completed],
		["Active Deliveries", "%d" % GameManager.active_deliveries.size()],
		["Available Contracts", "%d" % GameManager.contracts.filter(func(c): return c.status == "available").size()],
		["Accepted Contracts", "%d" % GameManager.contracts.filter(func(c): return c.status == "accepted").size()],
		["", ""],
		["--- FLEET ---", ""],
		["Total Trucks", "%d" % GameManager.trucks.size()],
		["Available Trucks", "%d" % GameManager.trucks.filter(func(t): return t.is_available).size()],
		["Total Employees", "%d" % GameManager.employees.size()],
		["Available Drivers", "%d" % GameManager.employees.filter(func(e): return e.role == "Driver" and e.is_available).size()],
		["", ""],
		["--- EXPANSION ---", ""],
		["Unlocked Cities", "%d" % GameManager.unlocked_cities.size()],
		["Stations", "%d" % GameManager.stations.size()],
		["", ""],
		["--- STATUS ---", ""],
		["Company Reputation", "%.0f%%" % GameManager.company_reputation],
		["Social Status", "%.0f%%" % GameManager.social_status],
		["Family Happiness", "%.0f%%" % GameManager.family_happiness],
		["Luxury Items Owned", "%d" % GameManager.luxury_items.size()]
	]

	for stat in stats:
		var label_name = Label.new()
		label_name.text = stat[0]

		if stat[0].begins_with("---"):
			label_name.add_theme_font_size_override("font_size", 16)
			label_name.add_theme_color_override("font_color", Color(0.3, 0.8, 1))
		else:
			label_name.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))

		stats_grid.add_child(label_name)

		var label_value = Label.new()
		label_value.text = stat[1]
		label_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

		# Color code certain values
		if stat[0] == "Company Money":
			if GameManager.company_money < 10000:
				label_value.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
			elif GameManager.company_money > 100000:
				label_value.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		elif stat[0] == "Company Debt":
			if GameManager.company_debt > 0:
				label_value.add_theme_color_override("font_color", Color(1, 0.5, 0.3))
		elif stat[0] == "Net Profit":
			var profit = GameManager.total_revenue - GameManager.total_expenses
			if profit < 0:
				label_value.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
			else:
				label_value.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		elif stat[0] == "Company Reputation":
			if GameManager.company_reputation < 40:
				label_value.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
			elif GameManager.company_reputation > 70:
				label_value.add_theme_color_override("font_color", Color(0.3, 1, 0.5))

		stats_grid.add_child(label_value)

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
