extends VideoStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func _input(event):
	if event.is_action_pressed("ui_accept"):
		#emit_signal("monster_defeated", true)  # Emit defeat signal if monster is hit
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")

func _on_finished() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn") #change to according scnene file
