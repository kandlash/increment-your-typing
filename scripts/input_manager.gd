extends Node
class_name InputManager

@onready var line_edit: LineEdit = $"../Camera2D/Control/LineEdit"

signal correct
signal incorrect

var current_goal: InputGoal = null
var typing_allowed := false

func _ready():
	G.input_manager = self
	_disable_typing()

# ----------------------------------------------------
# START TYPING
# ----------------------------------------------------

func start_typing(goal: InputGoal):

	# сбрасываем предыдущую цель
	if current_goal:
		current_goal.set_active(false)

	current_goal = goal
	typing_allowed = true

	# включаем wave
	current_goal.set_active(true)

	line_edit.clear()
	line_edit.grab_focus()

# ----------------------------------------------------
# STOP
# ----------------------------------------------------

func disable_typing():
	line_edit.clear()
	typing_allowed = false
	current_goal = null

# ----------------------------------------------------
# INPUT
# ----------------------------------------------------

func _input(event: InputEvent):

	if not typing_allowed:
		return

	if event is InputEventKey:

		if not event.pressed:
			return

		if event.echo:
			return

		if event.unicode == 0:
			return

		var ch := char(event.unicode)
		_process_char(ch)

# ----------------------------------------------------
# CORE LOGIC
# ----------------------------------------------------

func _process_char(ch: String):

	if current_goal == null:
		return

	var correct_symbol := current_goal.symbol

	if ch == correct_symbol:
		_handle_success()
	else:
		_handle_mistake()

# ----------------------------------------------------
# RESULTS
# ----------------------------------------------------

func _handle_success():
	print("correct!")
	emit_signal("correct")
	_finish_goal()

func _handle_mistake():
	print("mistake!")
	emit_signal("incorrect")
	_finish_goal()

# ----------------------------------------------------
# FINISH FLOW
# ----------------------------------------------------

func _finish_goal():

	typing_allowed = false

	var goal := current_goal
	current_goal = null

	if goal:
		goal.set_active(false)
		goal.area_2d.monitorable = false

		await get_tree().create_timer(0.1).timeout
		$"..".goals.erase(goal)
		goal.queue_free()

	await get_tree().physics_frame
	G.goal_finder.select_new_target()
