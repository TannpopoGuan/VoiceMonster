extends Control

#score
var score = 0
#spawn monsters
var spawn_count = 0       # Tracks the number of spawned monsters
var total_monsters = 10   # Total number of monsters
var finalscore = 0             # Total score
var progress_string = "S".repeat(total_monsters)  # Initializes with 'S' for pending monsters

@onready var feedback_label = %FeedbackLabel  
@onready var progress_label = %ProgressLabel 
@onready var countdown_label = %CountdownLabel 



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if spawn_count == 0 :
		spawn_count +=1 #Ready gets called to many time. How can I ensure it gets only called once? and variable values don't reset
		print("222222")
		spawn_monster()
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_progress(defeated):
	# Replace current monster's symbol based on outcome
	var current_status = "0" if defeated else "X"
	progress_string = progress_string.substr(0, spawn_count) + current_status + progress_string.substr(spawn_count + 1)
	progress_label.text = progress_string
	spawn_count += 1  # Increment spawn_count only after processing the monster
	

func spawn_monster():
	#######
	await get_tree().create_timer(0.5).timeout
	if spawn_count >= total_monsters:
		feedback_label.text = "Game Over! Final Score: %d" % score
		
		return  # Stop spawning if the game is over
		
	 # Check if a monster already exists in the scene
	#if get_node_or_null("Monster") != null:
	#	print("A monster is already in the scene. Skipping spawn.")
	#	return
		
	#add a new monster
	spawn_count += 1
	
	if spawn_count <= total_monsters:
		var new_monster = preload("res://Scenes/monster_scene.tscn").instantiate()
		add_child(new_monster)
	 # Debugging: Confirm the type and available signals of the monster
	#print("Instantiated monster type: ", new_monster)
	#print("Available signals: ", new_monster.get_signal_list())
	
	 # Safely connect the signal, ensuring it exists
	#if new_monster.has_signal("monster_defeated"):
		#new_monster.connect("monster_defeated", self, "on_monster_defeated")
	#else:
	#	print("Error: Signal 'monster_defeated' not found on monster instance.")

		new_monster.connect("monster_defeated", Callable(self, "on_monster_defeated"))  # Connect signal once
		
		progress_label.text = progress_string  # Update progress display
		feedback_label.text = "Monster %d spawned!" % spawn_count  # Show feedback on spawn

	
	
func on_monster_defeated(points):
	score += points
	# Remove the defeated monster from the scene
	#if $Monster != null:  # Check if the monster exists
	#	$Monster.queue_free()  # Remove the current monster from the scene
	if points > 0:
		feedback_label.text = "Points earned: %d" % points
		var current_status = "0"
		progress_string = progress_string.substr(0, spawn_count) + current_status + progress_string.substr(spawn_count + 1)
		progress_label.text = progress_string
		update_progress(true)  # Mark monster as defeated (0)
	else:
		feedback_label.text = "No points. Time up!"
		var current_status = "X"
		progress_string = progress_string.substr(0, spawn_count) + current_status + progress_string.substr(spawn_count + 1)
		progress_label.text = progress_string
		update_progress(false)  # Mark monster as not defeated (X)
	# Update progress string
	await get_tree().create_timer(0.5).timeout
	
	spawn_monster()  # Proceed to next monster if available
