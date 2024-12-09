extends Node2D

var score = 0
var monsters = ["res://mouse_plurk.png", "res://icon.svg"]

func _ready():
	$MonsterTimer.start(5)
	$MainTimer.start(300)
	$ScoreLabel.text = "Score: " + str(score)
	$Sprite2D.visible = true

#timer labels
func _process(delta):
	if $MonsterTimer.is_stopped() == false:
		$MonsterTimerLabel.text = "Monster Timer: " + str(floor($MonsterTimer.time_left))
	else:
		$MonsterTimerLabel.text = "Monster Timer: 0"
	
	if $MainTimer.is_stopped() == false:
		$MainTimerLabel.text = "Main Timer: " + str(floor($MainTimer.time_left/60)) + "m " + str(floor($MainTimer.time_left - floor(($MainTimer.time_left/60))*60)) + "s" 
	else:
		$MainTimerLabel.text = "Main Timer: 0"

func process_correct_word():
	var remaining_time = $MonsterTimer.time_left
	var points = calculate_points(remaining_time)
	$Sprite2D.visible = false
	$MonsterTimer.stop()
	monster_defeated_logic(points)
	reset_for_new_monster()

func monster_defeated_logic(points):
	score += points
	$ScoreLabel.text = "Score: " + str(score)

func calculate_points(remaining_time: float) -> int:
	if remaining_time > 4:
		return 5
	elif remaining_time > 3:
		return 3
	elif remaining_time > 1:
		return 2
	elif remaining_time > 0:
		return 1
	return 0

func reset_for_new_monster():
	$MonsterTimer.stop()
	$Sprite2D.visible = true
	var random_monster = monsters[randi() % monsters.size()]
	$Sprite2D.texture = load(random_monster)
	$Sprite2D.visible = true  # Show the new monster
	$MonsterTimer.start()  # Optionally start a new cycle

func _on_MonsterTimer_timeout():
	$Sprite2D.visible = false
	reset_for_new_monster()

func is_word_correct():
	process_correct_word()

func _on_correct_word_button_pressed():
	process_correct_word()
