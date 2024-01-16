class_name Hurtbox
extends Area2D

signal hurt(hitbox : Hitbox, damage)

func take_hit(hitbox : Hitbox, damage):
	hurt.emit(hitbox, damage)
