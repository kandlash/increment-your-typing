extends Node2D
class_name GoalFinder

@onready var area_2d: Area2D = $Area2D

var core_pos: Vector2
var anchor_pos: Vector2

var pull_speed := 5.0

var closest_goal: InputGoal = null
var next_goal: InputGoal = null

# ----------------------------------------------------
# TRAIL DATA (NO NODES)
# ----------------------------------------------------

var trail := [] # {pos: Vector2, life: float}
var last_trail_pos: Vector2

var trail_spacing := 8.0
var trail_fade_speed := 2.5
var trail_radius := 2.0

# ----------------------------------------------------

func _ready():

	core_pos = global_position
	anchor_pos = global_position

	G.goal_finder = self

	last_trail_pos = core_pos

# ----------------------------------------------------

func _process(delta):

	var dir = anchor_pos - core_pos

	if dir.length() > 5:
		core_pos += dir * delta * pull_speed

		handle_trail()

	global_position = core_pos

	update_trail(delta)
	queue_redraw()

# ----------------------------------------------------

func handle_trail():

	if last_trail_pos.distance_to(core_pos) < trail_spacing:
		return

	last_trail_pos = core_pos

	trail.append({
		"pos": to_local(core_pos),
		"life": 1.0
	})

# ----------------------------------------------------

func update_trail(delta):

	for i in range(trail.size()):
		trail[i]["life"] -= delta * trail_fade_speed

	# чистка
	while trail.size() > 0 and trail[0]["life"] <= 0:
		trail.pop_front()

# ----------------------------------------------------

func _draw():

	for p in trail:

		var alpha = clamp(p["life"], 0.0, 1.0)

		var radius = trail_radius + (1.0 - alpha) * 6.0

		draw_circle(
			p["pos"],
			radius,
			Color(1, 1, 1, alpha)
		)

# ----------------------------------------------------

func pick_random_from_nearest(origin: Vector2, exclude: InputGoal = null) -> InputGoal:

	var candidates := []

	for area in area_2d.get_overlapping_areas():

		if not area.is_in_group("InputGoals"):
			continue

		var goal: InputGoal = area.get_parent()

		if not is_instance_valid(goal):
			continue

		if goal == exclude:
			continue

		candidates.append(goal)

	if candidates.is_empty():
		return null

	return candidates[randi() % candidates.size()]

# ----------------------------------------------------

func select_new_target():

	if next_goal and is_instance_valid(next_goal):
		closest_goal = next_goal
	else:
		var chosen := pick_random_from_nearest(core_pos)
		if chosen == null:
			return
		closest_goal = chosen

	anchor_pos = closest_goal.global_position

	G.input_manager.start_typing(closest_goal)

	find_next_goal()

# ----------------------------------------------------

func find_next_goal():

	area_2d.global_position = anchor_pos
	await get_tree().physics_frame

	next_goal = pick_random_from_nearest(anchor_pos, closest_goal)

	area_2d.global_position = core_pos
