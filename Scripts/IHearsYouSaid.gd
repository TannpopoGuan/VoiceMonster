extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# Set the initial properties of the text label
	self.scale = Vector2(0.5, 0.5)  # Keep text scale constant
	#self.modulate = Color(0, 0, 1)  # White color
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
# Function to display a random text above the monster
	pass
