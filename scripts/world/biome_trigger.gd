extends Area2D

@export var biome_id: String = "summer"
@export var show_only_once := true
@export var respawn_marker: Marker2D

var already_shown := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if respawn_marker != null:
		GameState.set_respawn_position(respawn_marker.global_position)

	var mission_tracker_hud = get_tree().current_scene.get_node_or_null("MissionTrackerHUD")
	if mission_tracker_hud != null:
		mission_tracker_hud.set_biome(biome_id)

	if show_only_once and already_shown:
		return

	already_shown = true

	var mission_popup = get_tree().current_scene.get_node_or_null("MissionPopup")
	if mission_popup != null:
		mission_popup.show_mission(biome_id)
