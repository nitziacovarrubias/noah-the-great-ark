extends Node

signal capture_ball_collected
signal respawn_point_changed(new_position: Vector2)

var has_capture_ball := false
var current_respawn_position := Vector2(70, -200)

func collect_capture_ball() -> void:
	has_capture_ball = true
	capture_ball_collected.emit()

func set_respawn_position(new_position: Vector2) -> void:
	current_respawn_position = new_position
	respawn_point_changed.emit(new_position)

func get_respawn_position() -> Vector2:
	return current_respawn_position
