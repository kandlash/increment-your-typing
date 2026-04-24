extends Node2D

const INPUT_GOAL = preload("uid://cyump1h2d8sq8")

@export var grid_size := 30
@export var spacing := 32

func _ready() -> void:

	await get_tree().process_frame
	generate_grid()

	await get_tree().create_timer(0.5).timeout
	G.goal_finder.select_new_target()


func generate_grid():

	var start_pos := Vector2.ZERO

	for x in range(grid_size):
		for y in range(grid_size):

			var goal: InputGoal = INPUT_GOAL.instantiate()
			add_child(goal)

			goal.position = start_pos + Vector2(x * spacing, y * spacing)
