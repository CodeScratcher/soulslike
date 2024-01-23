extends CanvasLayer

@export var player: Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Gui/VBoxContainer/Health.value = player.hp / player.MAX_HP * 100
	$Gui/VBoxContainer/Stamina.value = player.stamina / player.MAX_STAMINA * 100
	$Gui/VBoxContainer/HBoxContainer/Flask.text = str(player.flasks)
