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
@onready var symbol_label: Label = $Camera2D/Control/symbol_label

func _ready() -> void:
	var text_template := next_symbol_label.text
	await get_tree().process_frame
	generate_grid()
	new_symbol()

	await get_tree().create_timer(0.5).timeout
	G.goal_finder.select_new_target()
	timer.start()

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

	G.input_manager.disable_typing()

	for goal in goals:
		if is_instance_valid(goal):
			goal.visible = false

	current_symbol = G.generate_symbol()

	await symbol_label.play_animation(current_symbol)

	for goal in goals:
		if is_instance_valid(goal):
			goal.visible = true
			goal.generate_symbol(current_symbol)

	update_next_symbol_label()

	G.goal_finder.select_new_target()

	timer.start()

func update_next_symbol_label():
	next_symbol_label.add_text(text_template.replace("#symbol", current_symbol)) 

func _on_timer_timeout() -> void:
	new_symbol()
