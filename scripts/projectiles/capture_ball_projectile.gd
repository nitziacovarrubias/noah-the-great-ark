extends Area2D

@export var speed := 380.0
@export var lifetime := 1.2

var direction := Vector2.RIGHT
var already_hit := false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

	await get_tree().create_timer(lifetime).timeout

	if is_inside_tree():
		queue_free()

func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	rotation += 12.0 * delta

func setup(new_direction: Vector2) -> void:
	if new_direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	else:
		direction = new_direction.normalized()

func _on_area_entered(area: Area2D) -> void:
	if already_hit:
		return

	if area.has_method("capture"):
		already_hit = true
		area.capture()
		queue_free()
