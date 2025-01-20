extends Sprite2D

var score = 0
# Monster scale and blinking properties
var scale_speed = 0.12  # Growth rate  
var blink_threshold = 0.3  # The scale at which the monster blinks red
var blink_duration = 0.2   # Duration of each blink
var blink_timer = 0.0      # Timer to control blinking
var is_defeated = false   # Flag to check if the monster is defeated
# Timer for countdown
var countdown_time = 5.0  # 5-second countdown


var monster_timer = 0.0   # Timer for current monster's life
signal monster_defeated(points)

@onready var countdown_label = $CountdownLabel 
#@onready var countdown_label = get_node("/root/Level1/GameManager/CountdownLabel")
#@onready var monster_text_label = $MonsterText  #Generating Words
@onready var monster_text_label = $MonsterText #Generating Words
@onready var IHeardYouSaid_label = $IHeardYouSaid #Generating Words
@onready var feedback_label = get_node("/root/Level1/GameManager/FeedbackLabel")  # Reference to feedback label
var SpeechRecognizer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SpeechRecognizer = get_node("/root/Level1/GameManager/SpeechRecognizer")
	countdown_label.text = "5"  # Reset countdown text for each new monster
	countdown_label.position = position + Vector2(-720,-1100)
	set_process_input(true)  # Enable input detection to check for key press
	# Set the random text
	if monster_text_label != null:
		monster_text_label.show_text()
	if countdown_label != null:
		countdown_label.start_countdown()
	
	SpeechRecognizer.StartSpeechRecognition()
	SpeechRecognizer.connect("OnPartialResult", Callable(self, "_on_partial_result"))
	SpeechRecognizer.connect("OnFinalResult", Callable(self, "_on_final_result") )
	
# if get signal from voice rec 
#     -> check same string or not
#	     if true: defeat
func to_hiragana(text: String) -> String:
	
	var katakana_to_hiragana = {
		"ア": "あ", "イ": "い", "ウ": "う", "エ": "え", "オ": "お",
		"カ": "か", "キ": "き", "ク": "く", "ケ": "け", "コ": "こ",
		"サ": "さ", "シ": "し", "ス": "す", "セ": "せ", "ソ": "そ",
		"タ": "た", "チ": "ち", "ツ": "つ", "テ": "て", "ト": "と",
		"ナ": "な", "ニ": "に", "ヌ": "ぬ", "ネ": "ね", "ノ": "の",
		"ハ": "は", "ヒ": "ひ", "フ": "ふ", "ヘ": "へ", "ホ": "ほ",
		"マ": "ま", "ミ": "み", "ム": "む", "メ": "め", "モ": "も",
		"ヤ": "や", "ユ": "ゆ", "ヨ": "よ",
		"ラ": "ら", "リ": "り", "ル": "る", "レ": "れ", "ロ": "ろ",
		"ワ": "わ", "ヲ": "を", "ン": "ん",
		"ガ": "が", "ギ": "ぎ", "グ": "ぐ", "ゲ": "げ", "ゴ": "ご",
		"ザ": "ざ", "ジ": "じ", "ズ": "ず", "ゼ": "ぜ", "ゾ": "ぞ",
		"ダ": "だ", "ヂ": "ぢ", "ヅ": "づ", "デ": "で", "ド": "ど",
		"バ": "ば", "ビ": "び", "ブ": "ぶ", "ベ": "べ", "ボ": "ぼ",
		"パ": "ぱ", "ピ": "ぴ", "プ": "ぷ", "ペ": "ぺ", "ポ": "ぽ",
		"ャ": "ゃ", "ュ": "ゅ", "ョ": "ょ", "ッ": "っ", "ー": "ー" 
	}

	var hiragana_text = ""
	for char in text:
		if char in katakana_to_hiragana:
			hiragana_text += katakana_to_hiragana[char]
		else:
			hiragana_text += char  # 非片假名字符直接保留
	return hiragana_text
	
func _on_partial_result(partial_result):
	
	partial_result = partial_result.replace(" ", "").replace("\t", "")
	var monster_text_hiragana = to_hiragana(monster_text_label.text)
	var partial_result_hiragana = to_hiragana(partial_result)
	print("I heard:", partial_result_hiragana)
	if monster_text_hiragana in partial_result_hiragana:
		handle_defeat(true)
	IHeardYouSaid_label.text = partial_result_hiragana +"?"
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_defeated:
		return
	#monster_text_label.position = position + Vector2(-1050,-250)
	
	monster_timer += delta
	countdown_label.text = str(ceil(5 - monster_timer))  # Update countdown timer
	if monster_timer >= 5:
		handle_defeat(false)  # Time expired without defeating the monster
		
	#text
	countdown_time -= delta
	if countdown_time <= 0:
		queue_free()  # Destroy the monster and its text label
		#if monster_text_label != null:
		#	monster_text_label.hide_text()
		#if countdown_label != null:
		#	countdown_label.stop_countdown()
	
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
		#queue_free()  # Destroy the monster after it is defeated

func handle_defeat(defeated_by_player: bool):
	if is_defeated:
		return
	is_defeated = true  
	SpeechRecognizer.StopSpeechRecoginition()
	var points = 0
	if defeated_by_player:
		# Determine points based on time taken
		
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
	print("handle_defeat")
	emit_signal("monster_defeated", points)  # Emit points to GameManager
	await get_tree().create_timer(1.0).timeout
	queue_free()  # Remove the monster instance
