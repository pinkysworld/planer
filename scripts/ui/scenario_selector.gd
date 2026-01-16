extends CanvasLayer
## Scenario Selector - Choose game mode and scenarios

signal scenario_selected(scenario: Dictionary)

var scenarios: Dictionary = {
	"freeplay": {
		"name": "Freeplay",
		"description": "Build your transport empire without restrictions",
		"starting_money": 75000.0,
		"starting_private_money": 8000.0,
		"starting_reputation": 50.0,
		"starting_city": "Berlin",
		"goals": [],
		"difficulty": "normal"
	},
	"startup": {
		"name": "Startup Challenge",
		"description": "Start with limited funds and build a successful company",
		"starting_money": 30000.0,
		"starting_private_money": 3000.0,
		"starting_reputation": 30.0,
		"starting_city": "Berlin",
		"goals": [
			{"type": "money", "target": 500000.0, "description": "Reach €500,000 company funds"}
		],
		"difficulty": "hard"
	},
	"european": {
		"name": "European Expansion",
		"description": "Expand your business across Europe",
		"starting_money": 100000.0,
		"starting_private_money": 10000.0,
		"starting_reputation": 60.0,
		"starting_city": "Berlin",
		"goals": [
			{"type": "stations", "target": 5, "description": "Open stations in 5 different countries"}
		],
		"difficulty": "medium"
	},
	"fleet": {
		"name": "Fleet Commander",
		"description": "Build the largest truck fleet in Europe",
		"starting_money": 80000.0,
		"starting_private_money": 5000.0,
		"starting_reputation": 50.0,
		"starting_city": "Hamburg",
		"goals": [
			{"type": "trucks", "target": 20, "description": "Own a fleet of 20 trucks"}
		],
		"difficulty": "medium"
	},
	"reputation": {
		"name": "Reputation Master",
		"description": "Become the most trusted transport company",
		"starting_money": 50000.0,
		"starting_private_money": 5000.0,
		"starting_reputation": 40.0,
		"starting_city": "Munich",
		"goals": [
			{"type": "reputation", "target": 95.0, "description": "Achieve 95% reputation rating"}
		],
		"difficulty": "hard"
	}
}

func _start_scenario(scenario_key: String) -> void:
	var scenario = scenarios.get(scenario_key, scenarios.freeplay)
	GameManager.start_new_game(scenario)
	get_tree().change_scene_to_file("res://scenes/office_building.tscn")

func _on_freeplay_pressed() -> void:
	AudioManager.play_sfx("click")
	_start_scenario("freeplay")

func _on_scenario1_pressed() -> void:
	AudioManager.play_sfx("click")
	_start_scenario("startup")

func _on_scenario2_pressed() -> void:
	AudioManager.play_sfx("click")
	_start_scenario("european")

func _on_scenario3_pressed() -> void:
	AudioManager.play_sfx("click")
	_start_scenario("fleet")

func _on_scenario4_pressed() -> void:
	AudioManager.play_sfx("click")
	_start_scenario("reputation")

func _on_back_pressed() -> void:
	AudioManager.play_sfx("click")
	visible = false
