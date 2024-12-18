extends Button

func _on_level2_pressed() -> void:
	get_tree().change_scene_to_file("res://Monsters/monster.tscn")
