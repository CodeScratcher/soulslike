extends CharacterBody2D


@export var MAX_SPEED = 300.0
const SPEED = 75.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var hp = 30
var target = null
var player_in_range = false
var atk_cooldown = 2.0
var damage = 25

func _physics_process(delta):
	for x in $Hitbox.get_overlapping_areas():
		if x.name == "BlockArea" and x.visible:
			print("OK")
			$AnimationPlayer.play("RESET")
	
	for x in $Hitbox.get_overlapping_areas():
		var body = x.get_parent()
		var in_attack = $AnimationPlayer.current_animation == "attack" or $AnimationPlayer.current_animation == "attack_left"
		if in_attack and body.is_in_group("player") and body.hit_iframes <= 0:
			print("HURT")
			body.hp -= damage
			print(body.hit_iframes)
			body.hit_iframes = 2.0
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if target:
		velocity.x = sign(global_position.direction_to(target.global_position).x) * SPEED
	else:
		velocity.x = 0
	if velocity.x != 0:
		$Sprite2D.flip_h = sign(velocity.x) > 0
		$AttackArea.scale.x = sign(velocity.x)
		
	move_and_slide()
	
	atk_cooldown -= delta
	
	if player_in_range == true:
		if atk_cooldown <= 0.0:
			if velocity.x > 0:
				$AnimationPlayer.play("attack")
			else:
				$AnimationPlayer.play("attack_left")
			atk_cooldown = 2.0
	if hp <= 0:
			queue_free()


func _on_detect_radius_body_entered(body):
	print(body.name)
	if body.is_in_group("player"):
		target = body

func _on_detect_radius_body_exited(body):
	if body.is_in_group("player"):
		target = null


func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_attack_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false


