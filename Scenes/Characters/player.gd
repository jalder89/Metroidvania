extends CharacterBody2D

@export var acceleration = 512
@export var max_velocity = 64
@export var max_fall_velocity = 128
@export var friction = 256
@export var gravity = 200
@export var jump_force = 128

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

func _physics_process(delta):
	apply_gravity(delta)
	var input_axis = Input.get_axis("move_left", "move_right")
	if is_moving(input_axis):
		apply_acceleration(delta, input_axis)
	else:
		apply_friction(delta)
	jump()
	update_animations(input_axis)
	move_and_slide()


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)

func is_moving(input_axis):
	return input_axis != 0

func apply_acceleration(delta, input_axis):
	velocity.x = move_toward(velocity.x, input_axis * max_velocity, acceleration * delta)

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, friction * delta)

func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += -jump_force

func update_animations(input_axis):
	if is_moving(input_axis):
		animation_player.play("run")
		sprite_2d.scale.x = sign(input_axis)
	else:
		animation_player.play("idle")
	
	if not is_on_floor():
		if velocity.y < 0:
			animation_player.play("jump")
		elif velocity.y > 0:
			animation_player.play("fall")
