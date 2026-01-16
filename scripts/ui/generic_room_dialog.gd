extends Control
## GenericRoomDialog - Placeholder dialog for rooms not yet implemented

signal closed

@onready var title_label = $Panel/VBox/Header/Title
@onready var description_label = $Panel/VBox/Description
@onready var info_label = $Panel/VBox/InfoLabel

var room_data: Dictionary = {}

func setup(data: Dictionary) -> void:
	room_data = data

func _ready() -> void:
	if not room_data.is_empty():
		title_label.text = room_data.get("name", "Room")
		description_label.text = room_data.get("description", "No description available")

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
