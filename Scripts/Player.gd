extends CharacterBody2D


@export var MAX_SPEED = 300.0
@export var JUMP_VELOCITY = -200.0
@export var ACCEL = 100.0
@export var DECEL = 150.0
@export var JUMP_VARIETY = 4
@export var ROLL_SPEED = 400.0
@export var STAMINA_REGEN = 25.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Timer for variable ajumps and coyote time
var jump_timer = 0.0
var started_jump = false
var finished_jump = false

var MAX_HP = 100.0
var MAX_STAMINA = 100.0

var hp = MAX_HP
var stamina = MAX_STAMINA

var hit_iframes = 0
var flasks = 4

var light_damage = 5
var heavy_damage = 25

func handle_gravity(delta):
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

func handle_jump(delta):
	if Input.is_action_pressed("jump") and jump_timer < JUMP_VARIETY and not finished_jump and stamina > 1.5:
		velocity.y = JUMP_VELOCITY
		stamina -= 1.5
		
		# Coyote time
		if not started_jump:
			started_jump = true
			jump_timer = 0.0

func handle_movement(delta):
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x += direction * ACCEL
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL)
	
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

func handle_roll(delta):
	if Input.is_action_just_pressed("roll") and velocity.x != 0 and is_on_floor() and stamina >= 25:
		if velocity.x > 0:
			$AnimationPlayer.play("roll")
		else:
			$AnimationPlayer.play("roll_left")
		stamina -= 25

func handle_attack(delta):
	if Input.is_action_just_pressed("light") and stamina >= 10:
		$AnimationPlayer.play("attack")
		stamina -= 10

func handle_heavy_attack(delta):
	if Input.is_action_just_pressed("heavy") and stamina >= 35:
		$AnimationPlayer.play("heavy_attack")
		stamina -= 35
	

func _physics_process(delta):
	var in_roll = $AnimationPlayer.current_animation == "roll" or $AnimationPlayer.current_animation == "roll_left"
	var in_attack = $AnimationPlayer.current_animation == "attack" or $AnimationPlayer.current_animation == "heavy_attack"
	var neutral = (not in_roll) and (not in_attack)

	handle_gravity(delta)

	if neutral:
		handle_movement(delta)
		handle_jump(delta)
		handle_roll(delta)
		handle_attack(delta)
		handle_heavy_attack(delta)
	elif in_roll:
		velocity.x = ROLL_SPEED * (-1 if $Sprite2D.flip_h else 1)
	elif in_attack:
		velocity.x = 0
	
	move_and_slide()
	
	
	if neutral and not started_jump:
		stamina += STAMINA_REGEN * delta
	
	stamina = clamp(stamina, 0, 100)
	
	if velocity.x > 0:
		$Hitbox.scale.x = 1
		$Sprite2D.flip_h = false
	elif velocity.x < 0:
		$Hitbox.scale.x = -1
		$Sprite2D.flip_h = true

	hit_iframes -= 1
	
	heal()
	
func heal():
	if Input.is_action_just_pressed("heal"):
		# learn about and statements
		if hp != MAX_HP and flasks > 0:
			hp += 30
			flasks -= 1
		# look at the clamp function
		hp = clamp(hp, 0, MAX_HP)


func _on_hitbox_area_entered(area):
	var body = area.get_parent()
	if $AnimationPlayer.current_animation == "attack" and body.is_in_group("enemy"):
		body.hp -= light_damage
	elif $AnimationPlayer.current_animation == "heavy_attack" and body.is_in_group("enemy"):
		body.hp -= heavy_damage
