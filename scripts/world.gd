extends Node2D

const INPUT_GOAL = preload("uid://cyump1h2d8sq8")

@export var grid_size := 30
@export var spacing := 48
var goals: Array = []
func _ready() -> void:

	await get_tree().process_frame
	generate_grid()
	new_symbol()

	await get_tree().create_timer(0.5).timeout
	G.goal_finder.select_new_target()


func generate_grid():
	var start_pos := Vector2.ZERO
	for x in range(grid_size):
		for y in range(grid_size):

			var goal: InputGoal = INPUT_GOAL.instantiate()
			add_child(goal)
			goals.append(goal)

			goal.position = start_pos + Vector2(x * spacing, y * spacing)

func new_symbol():
	var symbol = G.generate_symbol()

	for goal: InputGoal in goals:
		if not is_instance_valid(goal):
			continue
		goal.generate_symbol(symbol)

func _on_timer_timeout() -> void:
	new_symbol()
