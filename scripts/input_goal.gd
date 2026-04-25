extends Node2D
class_name InputGoal

@onready var label: RichTextLabel = $label
@onready var area_2d: Area2D = $Area2D

var symbol := ""

func _ready():
	add_to_group("InputGoals")

func generate_symbol(new_symbol: String):
	symbol = new_symbol 
	label.bbcode_enabled = true
	label.text = symbol

# ----------------------------------------------------
# VISUAL STATE
# ----------------------------------------------------

func set_active(is_active: bool):

	label.bbcode_enabled = true

	if is_active:
		label.text = "[color=white][wave amp=12 freq=4]%s[/wave][/color]" % symbol
	else:
		label.text = symbol
