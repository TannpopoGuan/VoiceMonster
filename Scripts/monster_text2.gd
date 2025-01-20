extends Label

var texts = ["さようなら","ソーダ","ビール","ドリンク","ドーナツ","グラス","ブルブル","こんにちは","おはよう","ぞくぞく","クリーム","コーヒー","オムライス","おはよう"]
#,
#,"コンピュータ","ありがとう","ペンギン","おめでとう","チョコレート","	ジュース","ソーダ","ビール","ウォッカ", "グラス","ジョッキ"
#"ヒヒーン","ぴったり","ぼうっと","ルンルン","パオーン","シャキシャキ","だぼだぼ","キンコンカンコン"
#"アタフタ","ギザギザ","ぎょろぎょろ","グビグビ","げっそり","てきぱき","むっちり","しわくちゃ"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# Set the initial properties of the text label
	self.scale = Vector2(2, 2)  # Keep text scale constant
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func show_text() -> void:
	text = texts[randi() % texts.size()]
	

# Function to hide the text (called when the monster is destroyed)
func hide_text() -> void:
	queue_free()  # Destroy the text label

func _process(delta: float) -> void:
# Function to display a random text above the monster
	pass
