class_name Hitbox
extends Area2D

@export var damage = 1

func _on_area_entered(hurtbox : Hurtbox):
	hurtbox.take_hit(self, damage)
