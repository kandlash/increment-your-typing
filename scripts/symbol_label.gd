extends Label
class_name SymbolLabel

# ----------------------------------------------------
# ANIMATION SETTINGS
# ----------------------------------------------------
var is_animating = false
@export_category("Fade")
@export var fade_in_time: float = 0.1
@export var fade_out_time: float = 0.2

@export_category("Scale")
@export var start_scale: float = 0.5
@export var pop_scale: float = 1.4
@export var settle_scale: float = 1.2
@export var pop_time: float = 0.15
@export var settle_time: float = 0.1

@export_category("Shake")
@export var shake_enabled: bool = true
@export var shake_count: int = 4
@export var shake_strength_deg: float = 5.0
@export var shake_time: float = 0.05
@export var shake_start_delay: float = 0.1

@export_category("Timing")
@export var pulse_delay: float = 0.15
@export var fade_out_delay: float = 0.35

# ----------------------------------------------------

var tween: Tween

func _ready() -> void:
	visible = false
	modulate.a = 0.0
	scale = Vector2.ONE


func play_animation(symbol: String) -> void:
	is_animating = true
	text = symbol
	visible = true

	# reset state
	modulate.a = 0.0
	scale = Vector2(start_scale, start_scale)
	rotation = 0

	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)

	# ------------------------------------------------
	# FADE IN
	# ------------------------------------------------
	tween.tween_property(self, "modulate:a", 1.0, fade_in_time)

	# ------------------------------------------------
	# POP SCALE
	# ------------------------------------------------
	tween.tween_property(self, "scale", Vector2(pop_scale, pop_scale), pop_time)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	# ------------------------------------------------
	# SETTLE SCALE (pulse)
	# ------------------------------------------------
	tween.tween_property(self, "scale", Vector2(settle_scale, settle_scale), settle_time)\
		.set_delay(pulse_delay)

	# ------------------------------------------------
	# SHAKE
	# ------------------------------------------------
	if shake_enabled:
		for i in range(shake_count):
			tween.tween_property(
				self,
				"rotation",
				deg_to_rad(randf_range(-shake_strength_deg, shake_strength_deg)),
				shake_time
			).set_delay(shake_start_delay + i * shake_time)

	# ------------------------------------------------
	# FADE OUT
	# ------------------------------------------------
	tween.tween_property(self, "modulate:a", 0.0, fade_out_time)\
		.set_delay(fade_out_delay)

	await tween.finished
	print('finished!')
	visible = false
	is_animating = false
