extends Control
## AccountingDialog - View finances, invoices, and transactions

signal closed

@onready var finances_grid = $Panel/VBox/FinancesSummary
@onready var transactions_container = $Panel/VBox/TransactionsList/TransactionsContainer

func _ready() -> void:
	_refresh_finances()
	_refresh_transactions()

func _refresh_finances() -> void:
	for child in finances_grid.get_children():
		child.queue_free()

	var summary = [
		["Company Balance:", "€%.0f" % GameManager.company_money],
		["Company Debt:", "€%.0f" % GameManager.company_debt],
		["Monthly Revenue:", "€%.0f" % GameManager.monthly_income],
		["Monthly Expenses:", "€%.0f" % GameManager.monthly_expenses],
		["Profit Margin:", "%.1f%%" % _calculate_profit_margin()],
	]

	for item in summary:
		var label_name = Label.new()
		label_name.text = item[0]
		label_name.add_theme_font_size_override("font_size", 16)
		finances_grid.add_child(label_name)

		var label_value = Label.new()
		label_value.text = item[1]
		label_value.add_theme_font_size_override("font_size", 16)
		label_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

		# Color code
		if item[0] == "Company Balance:":
			if GameManager.company_money < 10000:
				label_value.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
			else:
				label_value.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		elif item[0] == "Company Debt:":
			if GameManager.company_debt > 0:
				label_value.add_theme_color_override("font_color", Color(1, 0.5, 0.3))

		finances_grid.add_child(label_value)

func _calculate_profit_margin() -> float:
	if GameManager.monthly_income == 0:
		return 0.0
	return ((GameManager.monthly_income - GameManager.monthly_expenses) / GameManager.monthly_income) * 100.0

func _refresh_transactions() -> void:
	for child in transactions_container.get_children():
		child.queue_free()

	var title = Label.new()
	title.text = "Recent Activity"
	title.add_theme_font_size_override("font_size", 16)
	transactions_container.add_child(title)

	# Show recent completed contracts as transactions
	var recent = GameManager.completed_contracts.slice(-10) if GameManager.completed_contracts.size() > 10 else GameManager.completed_contracts
	recent.reverse()

	if recent.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No transactions yet. Complete deliveries to see activity here."
		empty_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		transactions_container.add_child(empty_label)
		return

	for contract in recent:
		var entry = _create_transaction_entry(contract)
		transactions_container.add_child(entry)

func _create_transaction_entry(contract: Dictionary) -> Control:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var desc_label = Label.new()
	desc_label.text = "Delivery to %s - %s" % [contract.destination, contract.client]
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(desc_label)

	var amount_label = Label.new()
	amount_label.text = "+€%.0f" % contract.payment
	amount_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
	hbox.add_child(amount_label)

	return hbox

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
