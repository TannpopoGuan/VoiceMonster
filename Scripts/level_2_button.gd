extends Button


func _on_level2_pressed() -> void:
	print("222")
	get_tree().change_scene_to_file("res://Scenes/Level2.tscn")
