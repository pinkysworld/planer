extends CharacterBody2D
## PlayerCharacter - The player's avatar that walks around the building

@export var speed: float = 200.0
@export var click_threshold: float = 10.0  # Stop moving when this close to target

var interaction_area: Area2D
var facing_direction: int = 1  # 1 = right, -1 = left

# Mouse-controlled movement
var target_position: Vector2 = Vector2.ZERO
var is_moving_to_target: bool = false

func _ready() -> void:
	interaction_area = get_node_or_null("InteractionArea")
	target_position = global_position

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.is_paused:
		return

	# Mouse click movement
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Get the click position in the game world
			target_position = get_global_mouse_position()
			target_position.y = global_position.y  # Keep same Y level
			is_moving_to_target = true

func _physics_process(delta: float) -> void:
	if GameManager.is_paused:
		return

	var direction = 0.0

	# Priority: Mouse movement first, then keyboard
	if is_moving_to_target:
		var distance_to_target = global_position.distance_to(target_position)

		if distance_to_target < click_threshold:
			# Reached target
			is_moving_to_target = false
			velocity.x = 0
		else:
			# Move towards target
			direction = sign(target_position.x - global_position.x)
			facing_direction = int(direction)
	else:
		# Keyboard controls (backup method)
		if Input.is_action_pressed("move_left"):
			direction = -1.0
			facing_direction = -1
		elif Input.is_action_pressed("move_right"):
			direction = 1.0
			facing_direction = 1

	velocity.x = direction * speed

	# Update visual direction
	if direction != 0:
		scale.x = abs(scale.x) * facing_direction

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
