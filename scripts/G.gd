extends Node

var level := 1

var input_manager: InputManager
var goal_finder: GoalFinder

var symbols: Array = [
	'j', 't', 'x', 'm'
]

func generate_symbol():
	return symbols.pick_random()
