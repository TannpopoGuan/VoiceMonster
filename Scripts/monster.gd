extends Sprite2D

var score = 0
# Monster scale and blinking properties
var scale_speed = 0.15  # Growth rate  
var blink_threshold = 0.3  # The scale at which the monster blinks red
var blink_duration = 0.2   # Duration of each blink
var blink_timer = 0.0      # Timer to control blinking

# Timer for countdown
var countdown_time = 5.0  # 5-second countdown


var monster_timer = 0.0   # Timer for current monster's life
signal monster_defeated(points)

@onready var countdown_label = $CountdownLabel 
#@onready var countdown_label = get_node("/root/Level1/GameManager/CountdownLabel")
#@onready var monster_text_label = $MonsterText  #Generating Words
@onready var monster_text_label = $MonsterText #Generating Words
@onready var feedback_label = get_node("/root/Level1/GameManager/FeedbackLabel")  # Reference to feedback label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countdown_label.text = "5"  # Reset countdown text for each new monster
	set_process_input(true)  # Enable input detection to check for key press
	# Set the random text
	if monster_text_label != null:
		monster_text_label.show_text()
	if countdown_label != null:
		countdown_label.start_countdown()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	monster_text_label.position = position + Vector2(-750,-200)
	
	monster_timer += delta
	countdown_label.text = str(ceil(5 - monster_timer))  # Update countdown timer
	if monster_timer >= 5:
		handle_defeat(false)  # Time expired without defeating the monster
		
	#text
	countdown_time -= delta
	if countdown_time <= 0:
		queue_free()  # Destroy the monster and its text label
		if monster_text_label != null:
			monster_text_label.hide_text()
		if countdown_label != null:
			countdown_label.stop_countdown()
	
	#scale
	scale += Vector2(scale_speed, scale_speed) * delta
	
	#angry blink
	if scale.x >= blink_threshold:
		blink_timer -= delta
		if blink_timer <= 0:
			modulate = Color(1, 0, 0) if modulate == Color(1, 1, 1) else Color(1, 1, 1)
			blink_timer = blink_duration  # Reset the timer
			
			
	
func _input(event):
	if event.is_action_pressed("ui_accept") and not feedback_label.text.begins_with("Game Over"):
		#emit_signal("monster_defeated", true)  # Emit defeat signal if monster is hit
		handle_defeat(true)
		queue_free()  # Destroy the monster after it is defeated

func handle_defeat(defeated_by_player: bool):
	if defeated_by_player:
		# Determine points based on time taken
		var points = 0
		if monster_timer < 1:
			points = 5
		elif monster_timer < 2:
			points = 3
		elif monster_timer < 4:
			points = 2
		elif monster_timer < 5:
			points = 1
		
		score += points
		countdown_label.visible = false  # Hide countdown
		emit_signal("monster_defeated", points)  # Emit points to GameManager
		
	queue_free()  # Remove the monster instance