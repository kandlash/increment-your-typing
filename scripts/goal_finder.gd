extends Node2D
class_name GoalFinder

@onready var area_2d: Area2D = $Area2D

var core_pos: Vector2
var anchor_pos: Vector2

var pull_speed := 5.0

var closest_goal: InputGoal = null
var next_goal: InputGoal = null

var circle: Line2D
var line: Line2D

signal label_entered


func _ready():

	core_pos = global_position
	anchor_pos = global_position

	G.goal_finder = self

	create_visuals()


# ----------------------------------------------------
# VISUALS
# ----------------------------------------------------

func create_visuals():

	circle = Line2D.new()
	circle.width = 1
	circle.default_color = Color(1, 1, 1, 0.6)
	add_child(circle)

	line = Line2D.new()
	line.width = 1.5
	line.default_color = Color(1, 1, 1, 0.4)
	add_child(line)


# ----------------------------------------------------
# DRAWING
# ----------------------------------------------------

func draw_goal_circle(center: Vector2, radius := 15.0):

	var points := []
	var steps := 32

	for i in range(steps + 1):
		var a = i * TAU / steps
		points.append(center + Vector2(cos(a), sin(a)) * radius)

	circle.points = points


func draw_target_line(from: Vector2, to: Vector2):

	line.points = [from, to]


# ----------------------------------------------------
# PROCESS
# ----------------------------------------------------

func _process(delta):

	var dir = anchor_pos - core_pos

	if dir.length() > 5:
		core_pos += dir * delta * pull_speed

	global_position = core_pos

	# защита от удалённых целей
	if closest_goal and not is_instance_valid(closest_goal):
		closest_goal = null

	if next_goal and not is_instance_valid(next_goal):
		next_goal = null

	# визуализация
	if closest_goal and next_goal:

		var from := to_local(closest_goal.global_position)
		var to := to_local(next_goal.global_position)

		draw_target_line(from, to)
		draw_goal_circle(from, 15.0)

	else:
		line.clear_points()
		circle.clear_points()


# ----------------------------------------------------
# SHARED PICK LOGIC
# ----------------------------------------------------

func pick_random_from_nearest(origin: Vector2, exclude: InputGoal = null) -> InputGoal:

	var candidates := []

	for area in area_2d.get_overlapping_areas():

		if not area.is_in_group("InputGoals"):
			continue

		var goal: InputGoal = area.get_parent()

		# 🔥 FIX: защита от freed объектов
		if not is_instance_valid(goal):
			continue

		if goal == exclude:
			continue

		var dist := origin.distance_to(goal.global_position)

		candidates.append({
			"goal": goal,
			"dist": dist
		})

	if candidates.is_empty():
		return null

	candidates.sort_custom(func(a, b):
		return a["dist"] < b["dist"]
	)

	var max_candidates = min(5, candidates.size())
	var random_index = randi() % max_candidates

	return candidates[random_index]["goal"]


# ----------------------------------------------------
# TARGET SELECTION
# ----------------------------------------------------

func select_new_target():

	# если уже есть next → используем его
	if next_goal and is_instance_valid(next_goal):

		closest_goal = next_goal
		anchor_pos = closest_goal.global_position

		G.input_manager.start_typing(closest_goal)

		find_next_goal()
		return

	# иначе выбираем новую
	var chosen := pick_random_from_nearest(core_pos)

	if chosen == null:
		return

	closest_goal = chosen
	anchor_pos = closest_goal.global_position

	G.input_manager.start_typing(closest_goal)

	find_next_goal()


# ----------------------------------------------------
# NEXT TARGET
# ----------------------------------------------------

func find_next_goal():

	area_2d.global_position = anchor_pos

	await get_tree().physics_frame

	next_goal = pick_random_from_nearest(anchor_pos, closest_goal)

	area_2d.global_position = core_pos


# ----------------------------------------------------
# EXTERNAL TRIGGER
# ----------------------------------------------------

func _on_word_done():

	await get_tree().create_timer(0.2).timeout
	select_new_target()
