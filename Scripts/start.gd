extends Control

@onready var label = $StartMonster/Label # Reference to the Label node
@onready var monster = $StartMonster  # Reference to the Monster node (formerly Monster2)

# Scaling parameters
var scale_speed = 0.5
var dark_threshold = 1.8

var pressed = false

func _ready():
	# Ensure the Label and Monster are valid nodes
	if label == null or monster == null:
		print("Error: Label or Monster node is missing.")
		return
	
	# Position the Monster in the center of the screen
	monster.position = get_viewport().size / 2

func _input(event):
	#if event.is_action_pressed("ui_accept"):  # Check if a key is pressed
	if event is InputEventMouseButton and event.pressed:
		pressed = true
	if event.is_action_pressed("ui_accept"):
		pressed = true 


func _process(delta):
	if pressed:
		# Scale the monster over time
		monster.scale += Vector2(scale_speed, scale_speed) * delta
		
		# Darken the monster as it scales
		if monster.scale.x >= dark_threshold:
			monster.modulate = Color(62, 64, 66)  # Turn black
			get_tree().change_scene_to_file("res://Scenes/intro_video.tscn")
