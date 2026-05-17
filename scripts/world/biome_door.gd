extends StaticBody2D

@export var required_biome_id: String = "spring"

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_open := false

func _ready() -> void:
	MissionManager.mission_completed.connect(_on_mission_completed)

	if MissionManager.is_mission_complete(required_biome_id):
		open_door()

func _on_mission_completed(biome_id: String) -> void:
	if biome_id == required_biome_id:
		open_door()

func open_door() -> void:
	if is_open:
		return

	is_open = true

	collision_shape.set_deferred("disabled", true)

	if animation_player.has_animation("open"):
		animation_player.play("open")
	else:
		sprite.visible = false
