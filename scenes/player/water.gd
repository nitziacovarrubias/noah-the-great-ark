extends Area2D

@export var respawn_point: NodePath

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var marker = get_node(respawn_point)

		body.global_position = marker.global_position
		body.velocity = Vector2.ZERO
