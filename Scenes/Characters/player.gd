extends CharacterBody2D

@export var acceleration = 512
@export var max_velocity = 64
@export var max_fall_velocity = 128
@export var friction = 256
@export var gravity = 200
@export var jump_force = 128

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const DUST_EFFECT_SCENE = preload("res://Assets/effects/dust_effect.tscn")

func _physics_process(delta):
	apply_gravity(delta)
	var input_axis = Input.get_axis("move_left", "move_right")
	if is_moving(input_axis):
		apply_acceleration(delta, input_axis)
	else:
		apply_friction(delta)
	jump()
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_edge:
		coyote_jump_timer.start()


func create_dust_effect():
	var dust_effect = DUST_EFFECT_SCENE.instantiate()
	var main = get_tree().current_scene
	dust_effect.global_position = global_position
	main.add_child(dust_effect)

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
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y += -jump_force
	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < -jump_force / 2:
			velocity.y = -jump_force / 2

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
