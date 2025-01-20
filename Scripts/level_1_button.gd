extends Button


func _on_level1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level1.tscn")
