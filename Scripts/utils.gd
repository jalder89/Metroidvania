extends Node2D

func instantiate_scene_on_world(scene : PackedScene, position : Vector2):
	var world = get_tree().current_scene
	var instance = scene.instantiate()
	instance.global_position = position
	world.add_child(instance)
	return instance
