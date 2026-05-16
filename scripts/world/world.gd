extends Node2D

@onready var mission_popup: CanvasLayer = $MissionPopup
@onready var mission_tracker_hud: CanvasLayer = $MissionTrackerHUD

func _ready() -> void:
	MissionManager.mission_completed.connect(_on_mission_completed)

	await get_tree().process_frame
	mission_tracker_hud.set_biome("spring")
	mission_popup.show_mission("spring")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mission"):
		mission_popup.show_mission("spring")

func _on_mission_completed(biome_id: String) -> void:
	if biome_id == "spring":
		print("Mission completed. The door is now open.")
