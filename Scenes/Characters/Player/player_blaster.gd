extends Node2D

@onready var blaster_sprite = $BlasterSprite
@onready var muzzle = $BlasterSprite/Muzzle

const BULLET_SCENE = preload("res://Scenes/Objects/bullet.tscn")

func _process(delta):
	blaster_sprite.rotation = get_local_mouse_position().angle()

func fire_bullet():
	var bullet = BULLET_SCENE.instantiate()
	var world = get_tree().current_scene
	bullet.rotation = blaster_sprite.rotation
	bullet.global_position = muzzle.global_position
	world.add_child(bullet)
