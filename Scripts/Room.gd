extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("player"):
		var camera: Camera2D = body.get_node("Camera2D")
		var collision: CollisionShape2D = $CollisionShape2D
		var size = collision.shape.extents
		camera.limit_left = collision.global_position.x - size.x
		camera.limit_right = camera.limit_left + size.x * 2
		
		camera.limit_top = collision.global_position.y - size.y
		camera.limit_bottom = camera.limit_top + size.y * 2
		
