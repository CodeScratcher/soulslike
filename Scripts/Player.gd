extends CharacterBody2D


@export var MAX_SPEED = 300.0
@export var JUMP_VELOCITY = -200.0
@export var ACCEL = 100.0
@export var DECEL = 150.0
@export var JUMP_VARIETY = 4
@export var ROLL_SPEED = 400.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Timer for variable jumps and coyote time
var jump_timer = 0.0
var started_jump = false
var finished_jump = false

func _physics_process(delta):
	var in_roll = $AnimationPlayer.current_animation == "roll"
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		# Add to the jump timer if not on ground
		jump_timer += delta * (1000.0 / 60.0)
		
		if not Input.is_action_pressed("jump") and started_jump:
			finished_jump = true
	else:
		jump_timer = 0.0
		started_jump = false
		finished_jump = false
		
	# Handle jump.
	if Input.is_action_pressed("jump") and jump_timer < JUMP_VARIETY and not finished_jump:
		velocity.y = JUMP_VELOCITY
		
		# Coyote time
		if not started_jump:
			started_jump = true
			jump_timer = 0.0

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	
	if not in_roll:
		if direction:
			velocity.x += direction * ACCEL
		else:
			velocity.x = move_toward(velocity.x, 0, DECEL)
		
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	else:
		velocity.x = ROLL_SPEED * sign(velocity.x)
		
	move_and_slide()
	
	if Input.is_action_pressed("roll") && velocity.x != 0:
		$AnimationPlayer.play("roll")
