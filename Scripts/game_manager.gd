extends Control


#Solution: Define game manager as global script

var score = 0
#spawn monsters
var spawn_count = 0       # Tracks the number of spawned monsters
var total_monsters = 10   # Total number of monsters
var finalscore = 0             # Total score
var progress_string = "?".repeat(total_monsters)  # Initializes with 'S' for pending monsters



var monster_scene = preload("res://Monsters/monster.tscn")

@onready var feedback_label = %FeedbackLabel  
@onready var progress_label = %ProgressLabel 
@onready var vbox_container = $VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vbox_container.visible = false
	if ReadyTracker.ready_set == true:
		print("GameManager ready already executed, skipping.")
		return
	ReadyTracker.ready_set = true
	#score
	# Your one-time initialization code here
	print("Ready is running for the first time.")

	$MainTimer.start(300)
	$MainTimerLabel.position = position + Vector2(20,60)
	$ScoreLabel.text = "Score: " + str(score)
	$ScoreLabel.position = position + Vector2(20,80)

	print("game manager _ready")

	spawn_monster()
	
	pass
	

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $MainTimer.is_stopped() == false:
		$MainTimerLabel.text = "Main Timer: " + str(floor($MainTimer.time_left/60)) + "m " + str(floor($MainTimer.time_left - floor(($MainTimer.time_left/60))*60)) + "s" 
	else:
		$MainTimerLabel.text = "Main Timer: 0"
	pass
	
func update_progress(defeated):
	# Replace current monster's symbol based on outcome
	
	var current_status = "0" if defeated else "X"
	
	progress_string = progress_string.substr(0, spawn_count-1) + current_status + progress_string.substr(spawn_count)
	
	progress_label.text = progress_string
	#spawn_count += 1  # Increment spawn_count only after processing the monster
	

func spawn_monster():
	#######
	print("spawn_monster")
	await get_tree().create_timer(0.5).timeout
	if spawn_count >= total_monsters:
		$FeedbackLabel.position = position + Vector2(610,300)
		feedback_label.text = "Game Over!\nFinal Score: %d" % score
		$MainTimer.stop()
		vbox_container.visible = true
		return  # Stop spawning if the game is over
		
	 # Check if a monster already exists in the scene
	#if get_node_or_null("Monster") != null:
	#	print("A monster is already in the scene. Skipping spawn.")
	#	return
		
	#add a new monster
	spawn_count += 1
	print(spawn_count)
	
	if spawn_count <= total_monsters:
		#var new_monster = preload("res://Scenes/monster_scene.tscn").instantiate()  

		var new_monster = monster_scene.instantiate()
		add_child(new_monster)
	 # Debugging: Confirm the type and available signals of the monster
	#print("Instantiated monster type: ", new_monster)
	#print("Available signals: ", new_monster.get_signal_list())
	
	 # Safely connect the signal, ensuring it exists
		if new_monster.has_signal("monster_defeated"):
			new_monster.connect("monster_defeated", Callable(self, "_on_monster_defeated"))
		else:
			print("Error: Signal 'monster_defeated' not found on monster instance.")

		progress_label.text = progress_string  # Update progress display
		#feedback_label.text = "Monster %d spawned!" % spawn_count  # Show feedback on spawn
		#$FeedbackLabel.position = position + Vector2(0,60)

	
	

	


func _on_monster_defeated(points: Variant) -> void:
	
	print("Game Manager: _on_monster_defeated")
	score += points

	$ScoreLabel.text = "Score: " + str(score)
	# Remove the defeated monster from the scene
	#if $Monster != null:  # Check if the monster exists
	#	$Monster.queue_free()  # Remove the current monster from the scene
	if points > 0:
		feedback_label.text = "Points earned: %d" % points
		update_progress(true)  # Mark monster as defeated (0)
	else:
		feedback_label.text = "No points. Time up!"
		update_progress(false)  # Mark monster as not defeated (X)
	# Update progress string
	await get_tree().create_timer(0.5).timeout
	
	spawn_monster()  # Proceed to next monster if available
	pass # Replace with function body.


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
	pass # Replace with function body.
