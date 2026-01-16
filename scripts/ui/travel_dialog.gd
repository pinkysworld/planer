extends Control
## TravelDialog - Travel to other cities/stations

signal closed

@onready var current_location_label = $Panel/VBox/CurrentLocation
@onready var destinations_container = $Panel/VBox/DestinationsList/DestinationsContainer
@onready var info_label = $Panel/VBox/Footer/InfoLabel

func _ready() -> void:
	_refresh_display()

func _refresh_display() -> void:
	current_location_label.text = "Current Location: %s" % GameManager.current_city
	_refresh_destinations()

func _refresh_destinations() -> void:
	for child in destinations_container.get_children():
		child.queue_free()

	if GameManager.unlocked_cities.size() <= 1:
		var label = Label.new()
		label.text = "No other stations available.\nOpen new stations in the Station Management room to expand your reach."
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		destinations_container.add_child(label)
		return

	var title = Label.new()
	title.text = "Travel to:"
	title.add_theme_font_size_override("font_size", 16)
	destinations_container.add_child(title)

	for city in GameManager.unlocked_cities:
		if city == GameManager.current_city:
			continue

		var btn = Button.new()
		btn.text = city
		btn.custom_minimum_size = Vector2(0, 45)
		btn.pressed.connect(func(): _travel_to(city))
		destinations_container.add_child(btn)

func _travel_to(city: String) -> void:
	AudioManager.play_sfx("truck_start")

	GameManager.current_city = city
	info_label.text = "Traveled to %s! You are now at your %s station." % [city, city]
	info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))

	# Advance time for travel (simplified)
	GameManager.current_hour += 2
	if GameManager.current_hour >= 24:
		GameManager.current_hour -= 24
		GameManager.current_day += 1
		GameManager.emit_signal("day_changed", GameManager.current_day)

	_refresh_display()

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
