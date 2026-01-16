extends CharacterBody2D
## PlayerCharacter - The player's avatar that walks around the building

@export var speed: float = 200.0

var interaction_area: Area2D
var facing_direction: int = 1  # 1 = right, -1 = left

func _ready() -> void:
	interaction_area = get_node_or_null("InteractionArea")

func _physics_process(delta: float) -> void:
	if GameManager.is_paused:
		return
	
	var direction = 0.0
	
	if Input.is_action_pressed("move_left"):
		direction = -1.0
		facing_direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1.0
		facing_direction = 1
	
	velocity.x = direction * speed
	
	# Update visual direction
	if direction != 0:
		scale.x = facing_direction
	
	move_and_slide()
	
	# Clamp position to building bounds
	global_position.x = clamp(global_position.x, 80, 1180)

func _input(event: InputEvent) -> void:
	if GameManager.is_paused:
		return
	
	if event.is_action_pressed("interact"):
		_try_interact()

func _try_interact() -> void:
	if interaction_area == null:
		return
	
	var overlapping = interaction_area.get_overlapping_areas()
	for area in overlapping:
		var parent = area.get_parent()
		if parent.get_parent() != self:
			# Found a room to interact with
			var building = get_parent().get_parent()
			if building.has_method("_enter_room"):
				building._enter_room(parent.name)
			break
