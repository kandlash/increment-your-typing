extends Node2D

const INPUT_GOAL = preload("uid://cyump1h2d8sq8")

@export var grid_size := 30
@export var spacing := 48
var goals: Array = []

@onready var timer: Timer = $Timer
@onready var next_symbol_label: RichTextLabel = $Camera2D/Control/next_symbol_label
@onready var progress_bar: ProgressBar = $Camera2D/Control/ProgressBar
var current_symbol := ""
var text_template := ""

func _ready() -> void:
	var text_template := next_symbol_label.text
	await get_tree().process_frame
	generate_grid()
	new_symbol()

	await get_tree().create_timer(0.5).timeout
	G.goal_finder.select_new_target()

func _process(delta: float) -> void:
	if timer.is_stopped():
		return
	
	var total := timer.wait_time
	var left := timer.time_left
	
	var progress := (total - left) / total # 0 → 1
	
	progress_bar.value = progress * 100

func generate_grid():
	var start_pos := Vector2.ZERO
	for x in range(grid_size):
		for y in range(grid_size):

			var goal: InputGoal = INPUT_GOAL.instantiate()
			add_child(goal)
			goals.append(goal)

			goal.position = start_pos + Vector2(x * spacing, y * spacing)

func new_symbol():
	current_symbol = G.generate_symbol()

	for goal: InputGoal in goals:
		if not is_instance_valid(goal):
			continue
		goal.generate_symbol(current_symbol)

	update_next_symbol_label()

func update_next_symbol_label():
	next_symbol_label.add_text(text_template.replace("#symbol", current_symbol)) 

func _on_timer_timeout() -> void:
	new_symbol()
