extends Node
## EventBus - Global event system for decoupled communication between game systems

# Contract Events
signal contract_accepted(contract: Dictionary)
signal contract_completed(contract: Dictionary)
signal contract_failed(contract: Dictionary)
signal new_contract_available(contract: Dictionary)

# Delivery Events
signal delivery_started(delivery: Dictionary)
signal delivery_completed(delivery: Dictionary, on_time: bool)
signal delivery_progress_updated(delivery: Dictionary, progress: float)

# Truck Events
signal truck_purchased(truck: Dictionary)
signal truck_sold(truck: Dictionary, price: float)
signal truck_repaired(truck: Dictionary)
signal truck_breakdown(truck: Dictionary)
signal truck_needs_maintenance(truck: Dictionary)

# Employee Events
signal employee_hired(employee: Dictionary)
signal employee_fired(employee: Dictionary)
signal employee_event(employee: Dictionary, event_type: String)
signal employee_quit(employee: Dictionary)

# Financial Events
signal loan_taken(amount: float)
signal loan_repaid(amount: float)
signal payment_received(amount: float, source: String)
signal expense_incurred(amount: float, category: String)

# Station Events
signal station_opened(station: Dictionary)
signal station_upgraded(station: Dictionary)
signal station_closed(station: Dictionary)

# Personal Life Events
signal luxury_purchased(item: Dictionary)
signal family_request(member: String, amount: float)
signal family_happiness_changed(happiness: float)
signal social_status_changed(status: float)

# Random Events
signal random_event(event_type: String)
signal robbery_occurred(loss: float)
signal fuel_price_changed(fuel_type: String, new_price: float)
signal traffic_delay(delivery: Dictionary, delay_hours: int)
signal bonus_contract_offered(contract: Dictionary)

# UI Events
signal room_entered(room_name: String)
signal room_exited(room_name: String)
signal dialog_opened(dialog_name: String)
signal dialog_closed(dialog_name: String)
signal notification_shown(message: String, type: String)

# Game State Events
signal game_started(is_freeplay: bool)
signal game_paused()
signal game_resumed()
signal game_saved(slot: int)
signal game_loaded(slot: int)
signal scenario_won(scenario_name: String)
signal scenario_lost(reason: String)

# Communication Events (Modern replacements for fax)
signal email_received(email: Dictionary)
signal email_sent(email: Dictionary)
signal message_received(message: Dictionary)

# Helper function to show notifications
func show_notification(message: String, type: String = "info") -> void:
	emit_signal("notification_shown", message, type)

# Helper function for sending emails
func send_email(to: String, subject: String, body: String) -> void:
	var email = {
		"to": to,
		"subject": subject,
		"body": body,
		"timestamp": Time.get_unix_time_from_system(),
		"read": false
	}
	emit_signal("email_sent", email)

# Helper function for receiving emails
func receive_email(from: String, subject: String, body: String, email_type: String = "general") -> void:
	var email = {
		"from": from,
		"subject": subject,
		"body": body,
		"type": email_type,
		"timestamp": Time.get_unix_time_from_system(),
		"read": false
	}
	emit_signal("email_received", email)
