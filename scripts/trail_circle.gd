extends Node2D
class_name TrialCircle

var radius := 2.0
var growth := 25.0
var fade_speed := 2.5

var alpha := 1.0

func _process(delta):

	radius += growth * delta
	alpha -= fade_speed * delta

	if alpha <= 0:
		queue_free()

	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, radius, Color(1, 1, 1, alpha))
