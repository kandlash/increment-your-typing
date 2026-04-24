extends Node2D
class_name InputGoal

@onready var label: RichTextLabel = $label
@onready var area_2d: Area2D = $Area2D

var symbol := ""

func _ready():
	add_to_group("InputGoals")
	generate_symbol()

func generate_symbol():
	symbol = G.generate_symbol()
	label.text = symbol
