extends Node2D
class_name GoalFinder

@onready var area_2d: Area2D = $Area2D

var core_pos: Vector2
var anchor_pos: Vector2

var pull_speed := 5.0

var closest_goal = null
var next_goal = null

var circle: Line2D

signal label_entered


func _ready():

	core_pos = global_position
	anchor_pos = global_position

	G.goal_finder = self
	create_circle()



func create_circle():

	circle = Line2D.new()
	circle.width = 2
	add_child(circle)


func draw_goal_circle(center: Vector2, radius := 34.0):

	var points := []
	var steps := 32

	for i in range(steps + 1):

		var a = i * TAU / steps
		points.append(center + Vector2(cos(a), sin(a)) * radius)

	circle.points = points


func _process(delta):
	var dir = anchor_pos - core_pos

	if dir.length() > 5:
		core_pos += dir * delta * pull_speed

	global_position = core_pos

	# рисуем круг следующей цели
	if next_goal:
		draw_goal_circle(to_local(next_goal.global_position), 34.0)


func select_new_target():

	var candidates := []

	for area in area_2d.get_overlapping_areas():

		if not area.is_in_group("InputGoals"):
			continue

		var goal: InputGoal = area.get_parent()
		var dist := core_pos.distance_to(goal.global_position)

		candidates.append({
			"goal": goal,
			"dist": dist
		})

	if candidates.is_empty():
		return

	# сортируем по расстоянию
	candidates.sort_custom(func(a, b):
		return a["dist"] < b["dist"]
	)

	# берём максимум 5 ближайших
	var max_candidates = min(5, candidates.size())

	# выбираем случайную из них
	var random_index = randi() % max_candidates
	var chosen = candidates[random_index]["goal"]

	closest_goal = chosen
	anchor_pos = closest_goal.global_position

	# старт ввода
	G.input_manager.start_typing(closest_goal)

	find_next_goal()

func find_next_goal():

	# телепортируем сканер на первую цель
	area_2d.global_position = anchor_pos

	await get_tree().physics_frame

	var closest_dist := INF
	next_goal = null

	for area in area_2d.get_overlapping_areas():

		if not area.is_in_group("InputGoal"):
			continue

		var goal = area.get_parent()

		if goal == closest_goal:
			continue

		var dist = anchor_pos.distance_to(goal.global_position)

		if dist < closest_dist:
			closest_dist = dist
			next_goal = goal

	# возвращаем сенсор обратно к слизи
	area_2d.global_position = core_pos


func _on_word_done():

	await get_tree().create_timer(0.2).timeout
	select_new_target()
