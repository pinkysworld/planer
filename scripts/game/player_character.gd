extends CharacterBody2D
## PlayerCharacter - The player's avatar that walks around the office building

signal entered_room(room_name: String)
signal near_interactable(interactable: Node2D)

const SPEED: float = 200.0
const ANIMATION_SPEED: float = 8.0

var is_walking: bool = false
var facing_direction: int = 1  # 1 = right, -1 = left
var current_interactable: Area2D = null
var can_interact: bool = true

@onready var sprite = $Sprite
@onready var head = $Head
@onready var interaction_area = $InteractionArea

# Animation
var walk_frame: float = 0.0
var bob_offset: float = 0.0

func _ready() -> void:
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)

func _physics_process(delta: float) -> void:
	if not can_interact:
		return

	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * SPEED
		facing_direction = sign(direction)
		is_walking = true
		_update_walk_animation(delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		is_walking = false
		_reset_animation()

	# Keep player on current floor (basic boundary)
	velocity.y = 0

	move_and_slide()

	# Update sprite facing
	sprite.scale.x = facing_direction
	head.scale.x = facing_direction

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_interactable and can_interact:
		_interact_with_current()

func _update_walk_animation(delta: float) -> void:
	walk_frame += delta * ANIMATION_SPEED

	# Simple walking bob animation
	bob_offset = sin(walk_frame * 2.0) * 2.0
	sprite.position.y = -60 + bob_offset
	head.position.y = -80 + bob_offset * 0.5

	# Leg animation (color shift to simulate movement)
	var leg_phase = sin(walk_frame * 4.0)
	sprite.color = Color(0.3 + leg_phase * 0.05, 0.5, 0.7)

func _reset_animation() -> void:
	sprite.position.y = -60
	head.position.y = -80
	sprite.color = Color(0.3, 0.5, 0.7)

func _on_interaction_area_entered(area: Area2D) -> void:
	if area.get_parent().name.begins_with("Room_") or area.get_parent().name == "Elevator":
		current_interactable = area
		emit_signal("near_interactable", area.get_parent())

func _on_interaction_area_exited(area: Area2D) -> void:
	if current_interactable == area:
		current_interactable = null

func _interact_with_current() -> void:
	if current_interactable:
		var room_name = current_interactable.get_parent().name
		emit_signal("entered_room", room_name)

		# Notify the office building to handle room entry
		var office = get_parent().get_parent()
		if office.has_method("_enter_room"):
			office._enter_room(room_name)

func set_can_interact(value: bool) -> void:
	can_interact = value

func teleport_to(position: Vector2) -> void:
	global_position = position

func play_footstep_sound() -> void:
	if is_walking and int(walk_frame) % 2 == 0:
		AudioManager.play_sfx("footsteps", 0.1)
