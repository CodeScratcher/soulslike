extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var hp = 30
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	move_and_slide()


func enemy_bonked(area):
	hp -= 10
	
	if hp <= 0:
		queue_free()
