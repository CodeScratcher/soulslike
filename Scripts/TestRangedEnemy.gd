extends CharacterBody2D


@export var MAX_SPEED = 200.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var hp = 30
var target = null
var player_in_range = false
var atk_cooldown = 2.0
var damage = 25

