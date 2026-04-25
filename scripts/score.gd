extends RichTextLabel 

@onready var input_manager: InputManager = G.input_manager

func _ready() -> void:
	input_manager.correct.connect(_on_correct)

func _on_correct():
	var score := int(text)
	score += 5
	text = str(score)
