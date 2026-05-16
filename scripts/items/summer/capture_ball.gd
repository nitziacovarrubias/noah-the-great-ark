extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label

var collected := false
var idle_tween: Tween

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	start_idle_animation()

func start_idle_animation() -> void:
	idle_tween = create_tween()
	idle_tween.set_loops()

	idle_tween.tween_property(sprite, "position:y", -6, 0.45)
	idle_tween.tween_property(sprite, "position:y", 0, 0.45)

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	if not body.is_in_group("player"):
		return

	collected = true
	GameState.collect_capture_ball()

	if idle_tween:
		idle_tween.kill()

	set_deferred("monitoring", false)
	collision_shape.set_deferred("disabled", true)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", sprite.scale * 1.4, 0.25)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.25)
	tween.tween_property(label, "modulate:a", 0.0, 0.25)

	await tween.finished
	queue_free()
