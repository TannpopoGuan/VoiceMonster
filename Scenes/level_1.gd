extends Node2D

var paused = false
var esc_cooldown = false
@onready var pause_board = $PauseBoard #Generating Words
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if not paused and not esc_cooldown and event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed == false:
		pause_board.show()
		esc_cooldown = true  # 啟用冷卻時間
		paused = true  # 切換 paused 狀態
		get_tree().paused = paused

		print(event)
		print(paused)
		start_cooldown()
	if not esc_cooldown and paused and event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed == false:
		pause_board.hide()
		paused = false  # 切換 paused 狀態
		get_tree().paused = paused

		print(event)
		print(paused)
		start_cooldown()

		
func start_cooldown():
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true 
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(timer) 
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()
	
func _on_timer_timeout():
	print(1231331331)
	esc_cooldown = false  # 重置冷卻狀態
