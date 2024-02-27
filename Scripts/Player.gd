extends CharacterBody2D

@onready var progression = get_node("/root/Progression")

@export var MAX_SPEED = 200.0
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

@onready var MAX_HP = progression.max_hp
@onready var MAX_STAMINA = progression.max_stamina

@onready var physical_damage = progression.physical_damage

@onready var hp = MAX_HP
@onready var stamina = MAX_STAMINA

var hit_iframes = 0
var flasks = 4

var light_damage = 5
var heavy_damage = 25

var stamina_cooldown = 0.0

enum PlayerState {
	NEUTRAL,
	JUMP,
	ATTACK,
	ROLL,
	BLOCK,
	RECOVER
}

var state = PlayerState.NEUTRAL

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
		stamina_cooldown = 1.0
		
		# Coyote time
		if not started_jump:
			started_jump = true
			jump_timer = 0.0
		state = PlayerState.JUMP

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
		stamina_cooldown = 1.0
		state = PlayerState.ROLL

func handle_attack(delta):
	if Input.is_action_just_pressed("light") and stamina >= 10:
		$AnimationPlayer.play("attack")
		$Hitbox/HeavyAttack.visible = false
		$Hitbox/LightAttack.visible = true
		stamina -= 10
		stamina_cooldown = 1.0
		state = PlayerState.ATTACK

func handle_heavy_attack(delta):
	if Input.is_action_just_pressed("heavy") and stamina >= 35:
		$AnimationPlayer.play("heavy_attack")
		$Hitbox/HeavyAttack.visible = true
		$Hitbox/LightAttack.visible = false
		stamina -= 35
		stamina_cooldown = 1.0
		state = PlayerState.ATTACK
	



func _physics_process(delta):
	if stamina <= 0 and state != PlayerState.ATTACK and state != PlayerState.ROLL:
		state = PlayerState.RECOVER
		$BlockArea.visible = false
		$BlockArea/CollisionShape2D.disabled = true
		MAX_SPEED = 150.0
	if not ($AnimationPlayer.current_animation == "attack" or $AnimationPlayer.current_animation == "heavy_attack" or $AnimationPlayer.current_animation == "roll" or $BlockArea.visible) and is_on_floor() and not state == PlayerState.RECOVER:
		state = PlayerState.NEUTRAL

	handle_gravity(delta)

	if state == PlayerState.NEUTRAL or state == PlayerState.JUMP:
		handle_movement(delta)
		handle_jump(delta)
		handle_roll(delta)
		handle_attack(delta)
		handle_heavy_attack(delta)
		block()
		heal()
	elif state == PlayerState.ROLL:
		velocity.x = ROLL_SPEED * (-1 if $Sprite2D.flip_h else 1)
	elif state == PlayerState.ATTACK:
		velocity.x = 0
	elif state == PlayerState.BLOCK:
		handle_movement(delta)
		handle_jump(delta)
		block()
	elif state == PlayerState.RECOVER:
		handle_movement(delta)
		if stamina >= MAX_STAMINA * 0.5:
			state = PlayerState.NEUTRAL
			MAX_SPEED = 300.0
		heal()
	move_and_slide()
	
	if state == PlayerState.NEUTRAL or state == PlayerState.RECOVER:
		stamina_cooldown -= delta
		
	if stamina_cooldown <= 0.0  and not started_jump:
		stamina += STAMINA_REGEN * delta
	
	stamina = clamp(stamina, 0, 100)
	
	if not state == PlayerState.BLOCK:
		if velocity.x > 0:
			$Hitbox.scale.x = 1
			$BlockArea.scale.x = 1
			$Sprite2D.flip_h = false
		elif velocity.x < 0:
			$Hitbox.scale.x = -1
			$BlockArea.scale.x = -1
			$Sprite2D.flip_h = true
	
	

	hit_iframes -= delta
	
	
	
	if hp <= 0:
		get_tree().reload_current_scene()
	
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
		body.hp -= light_damage * physical_damage
	elif $AnimationPlayer.current_animation == "heavy_attack" and body.is_in_group("enemy"):
		body.hp -= heavy_damage * physical_damage

func block():
	if Input.is_action_pressed("block"):
		$BlockArea.visible = true
		$BlockArea/CollisionShape2D.disabled = false
		state = PlayerState.BLOCK
		stamina -= 0.3
		stamina_cooldown = 1.0
		MAX_SPEED = 150.0
	else:
		$BlockArea.visible = false
		$BlockArea/CollisionShape2D.disabled = true
		MAX_SPEED = 300.0
