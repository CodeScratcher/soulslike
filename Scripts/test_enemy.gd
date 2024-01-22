extends CharacterBody2D


@export var MAX_SPEED = 300.0
const SPEED = 75.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var hp = 30
var target = null

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if target:
		velocity.x = sign(global_position.direction_to(target.global_position).x) * SPEED
		
	move_and_slide()


func enemy_bonked(area):
	hp -= 10
	
	if hp <= 0:
		queue_free()

func _on_detect_radius_body_entered(body):
	print(body.name)
	if body.is_in_group("player"):
		target = body

func _on_detect_radius_body_exited(body):
	if body.is_in_group("player"):
		target = null
