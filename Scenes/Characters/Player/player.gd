extends CharacterBody2D

@export var acceleration = 512
@export var max_velocity = 64
@export var max_fall_velocity = 128
@export var friction = 256
@export var gravity = 200
@export var jump_force = 128
@export var player_name ="Jessica"

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var coyote_jump_timer = $Timers/CoyoteJumpTimer
@onready var player_blaster = $PlayerBlaster
@onready var fire_rate_timer = $Timers/FireRateTimer
@onready var drop_timer = $Timers/DropTimer
@onready var camera_2d = $Camera2D

const Speed = 100.0
const JumpVelocity = -200.0
const DustEffectScene = preload("res://Assets/effects/dust_effect.tscn")
const JumpEffectScene = preload("res://Assets/effects/jump_effect.tscn")

func _physics_process(delta):
	apply_gravity(delta)
	var input_axis = Input.get_axis("move_left", "move_right")
	if is_moving(input_axis):
		apply_acceleration(delta, input_axis)
	else:
		apply_friction(delta)
	if Input.is_action_pressed("fire") and fire_rate_timer.time_left == 0: 
		player_blaster.fire_bullet()
		fire_rate_timer.start()
	jump()
	if Input.is_action_pressed("crouch") and Input.is_action_just_pressed("jump"):
		set_collision_mask_value(2, false)
		drop_timer.start()
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_edge:
		coyote_jump_timer.start()


func create_dust_effect():
	Utils.instantiate_scene_on_world(DustEffectScene, global_position)

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
		if Input.is_action_just_pressed("jump") and not Input.is_action_pressed("crouch"):
			velocity.y += -jump_force
			Utils.instantiate_scene_on_world(JumpEffectScene, global_position)
	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < -jump_force / 2:
			velocity.y = -jump_force / 2

func update_animations(input_axis):
	sprite_2d.scale.x = sign(get_local_mouse_position().x)
	if abs(sprite_2d.scale.x) != 1: sprite_2d.scale.x = 1
	if is_moving(input_axis):
		animation_player.play("run")
		animation_player.speed_scale = input_axis * sprite_2d.scale.x
	else:
		animation_player.play("idle")
	
	if not is_on_floor():
		if velocity.y < 0:
			animation_player.play("jump")
		elif velocity.y > 0:
			animation_player.play("fall")


func _on_drop_timer_timeout():
	set_collision_mask_value(2, true) # Replace with function body.


func _on_hurtbox_hurt(hitbox, damage):
	Events.add_screenshake.emit(4, 0.2)
	camera_2d.reparent(hitbox)
	queue_free()
