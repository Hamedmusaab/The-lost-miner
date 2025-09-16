extends Node2D

const Speed = 60

var direction = 1
@onready var ray_cast_2_dright: RayCast2D = $RayCast2Dright
@onready var ray_cast_2_dleft: RayCast2D = $RayCast2Dleft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta):
	if ray_cast_2_dright.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = false
	if ray_cast_2_dleft.is_colliding():
			direction = 1
			animated_sprite_2d.flip_h = true
	
	position.x += direction * Speed * delta
