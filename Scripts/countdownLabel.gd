extends Label

var countdown_time = 5.0  # Countdown duration (5 seconds)
var countdown_label = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector2(get_viewport_rect().size.x / 2 - self.size.x / 2, 30)
	self.scale = Vector2(1, 1)  # Keep countdown scale constant
	self.modulate = Color(1, 1, 1)  # White color
	pass # Replace with function body.


# Function to start the countdown and update the label
func start_countdown() -> void:
	countdown_time = 5.0  # Reset countdown to 5 seconds
	_process(0)  # Initialize the countdown display

# Function to stop the countdown
func stop_countdown() -> void:
	countdown_time = 0  # Stop countdown
	text = "0"  # Set countdown text to 0


# Update countdown every frame
func _process(delta) -> void:
	if countdown_time > 0:
		countdown_time -= delta
		text = str(ceil(countdown_time))  # Update countdown display
	else:
		text = "0"  # Final display when countdown reaches 0
