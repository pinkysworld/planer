extends Control
## ElevatorDialog - Select floor to travel to

signal floor_selected(floor_number: int)

var current_floor: int = 1

@onready var floor_buttons = [
	$Panel/VBox/Floor0Btn,
	$Panel/VBox/Floor1Btn,
	$Panel/VBox/Floor2Btn,
	$Panel/VBox/Floor3Btn
]

func _ready() -> void:
	_update_button_states()

func _update_button_states() -> void:
	for i in range(floor_buttons.size()):
		if i == current_floor:
			floor_buttons[i].disabled = true
			floor_buttons[i].text = floor_buttons[i].text + " (Current)"

func _on_floor_pressed(floor_number: int) -> void:
	AudioManager.play_sfx("elevator")
	emit_signal("floor_selected", floor_number)

func _on_cancel_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("floor_selected", current_floor)
