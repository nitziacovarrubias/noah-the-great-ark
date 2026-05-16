extends Area2D

@export var biome_id: String = "spring"
@export var item_id: String = "wood"
@export var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var collected := false
var idle_tween: Tween
var base_position := Vector2.ZERO
var base_scale := Vector2.ONE

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	base_position = sprite.position
	base_scale = sprite.scale

	start_idle_animation()

func start_idle_animation() -> void:
	idle_tween = create_tween()
	idle_tween.set_loops()

	idle_tween.tween_property(sprite, "position:y", base_position.y - 5, 0.45)
	idle_tween.tween_property(sprite, "position:y", base_position.y + 3, 0.45)
	idle_tween.tween_property(sprite, "position:y", base_position.y, 0.35)

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	if not body.is_in_group("player"):
		return

	collected = true

	var was_collected := MissionManager.add_item(biome_id, item_id, amount)

	if not was_collected:
		collected = false
		return

	collect_animation()

func collect_animation() -> void:
	if idle_tween:
		idle_tween.kill()

	set_deferred("monitoring", false)
	collision_shape.set_deferred("disabled", true)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(sprite, "position:y", sprite.position.y - 18, 0.25)
	tween.tween_property(sprite, "scale", base_scale * 1.35, 0.25)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.25)

	await tween.finished

	queue_free()
