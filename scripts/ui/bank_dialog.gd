extends Control
## BankDialog - Take and repay loans

signal closed

@onready var balance_label = $Panel/VBox/BalanceSection/BalanceLabel
@onready var debt_label = $Panel/VBox/BalanceSection/DebtLabel
@onready var max_loan_label = $Panel/VBox/BalanceSection/MaxLoanLabel
@onready var loan_input = $Panel/VBox/LoanSection/LoanHBox/LoanAmountInput
@onready var repay_input = $Panel/VBox/RepaySection/RepayHBox/RepayAmountInput
@onready var repay_all_btn = $Panel/VBox/RepaySection/RepayAllBtn
@onready var info_label = $Panel/VBox/Footer/InfoLabel

func _ready() -> void:
	_refresh_display()

func _refresh_display() -> void:
	balance_label.text = "Company Balance: €%.0f" % GameManager.company_money
	debt_label.text = "Current Debt: €%.0f" % GameManager.company_debt

	var max_loan = GameManager.company_reputation * 1000.0
	max_loan_label.text = "Max Loan Available: €%.0f (based on reputation)" % max_loan

	loan_input.max_value = max_loan - GameManager.company_debt
	repay_input.max_value = GameManager.company_debt

	if GameManager.company_debt > 0:
		debt_label.add_theme_color_override("font_color", Color(1, 0.5, 0.3))
		repay_all_btn.text = "Repay All (€%.0f)" % GameManager.company_debt
		repay_all_btn.disabled = GameManager.company_money < GameManager.company_debt
	else:
		debt_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		repay_all_btn.text = "No Debt"
		repay_all_btn.disabled = true

func _on_take_loan_pressed() -> void:
	var amount = loan_input.value
	AudioManager.play_sfx("cash_register")

	if GameManager.take_loan(amount):
		info_label.text = "Loan of €%.0f approved! Remember to repay with 0.5%% monthly interest." % amount
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		_refresh_display()
	else:
		info_label.text = "Loan rejected. Exceeds maximum allowed based on reputation."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_repay_loan_pressed() -> void:
	var amount = repay_input.value
	AudioManager.play_sfx("cash_register")

	if GameManager.repay_loan(amount):
		info_label.text = "Repaid €%.0f of your loan." % amount
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		_refresh_display()
	else:
		info_label.text = "Cannot repay. Insufficient funds or invalid amount."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_repay_all_pressed() -> void:
	var amount = GameManager.company_debt
	AudioManager.play_sfx("cash_register")

	if GameManager.repay_loan(amount):
		info_label.text = "All debt repaid! You are debt-free!"
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		_refresh_display()
	else:
		info_label.text = "Cannot repay full amount. Insufficient funds."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
