extends CanvasLayer

@export var current_biome_id: String = "spring"

@onready var title_label: Label = $Root/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var rows_container: VBoxContainer = $Root/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/RowsContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	MissionManager.mission_updated.connect(_on_mission_updated)
	MissionManager.mission_completed.connect(_on_mission_completed)

	refresh_tracker()

func set_biome(biome_id: String) -> void:
	current_biome_id = biome_id
	refresh_tracker()

func refresh_tracker() -> void:
	for child in rows_container.get_children():
		child.queue_free()

	var mission_data := MissionManager.get_mission_data(current_biome_id)

	if mission_data.is_empty():
		title_label.text = "Mission"
		return

	title_label.text = mission_data["title"]

	var items: Dictionary = mission_data["items"]

	for item_id in items.keys():
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 28)

		var icon_rect := TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(24, 24)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.texture = MissionManager.get_item_icon(current_biome_id, item_id)

		var display_name: String = MissionManager.get_item_display_name(current_biome_id, item_id)
		var current_amount: int = MissionManager.get_item_progress(current_biome_id, item_id)
		var required_amount: int = MissionManager.get_item_required_amount(current_biome_id, item_id)

		var progress_label := Label.new()
		progress_label.text = display_name + ": " + str(current_amount) + "/" + str(required_amount)

		row.add_child(icon_rect)
		row.add_child(progress_label)

		rows_container.add_child(row)

func _on_mission_updated(biome_id: String) -> void:
	if biome_id == current_biome_id:
		refresh_tracker()

func _on_mission_completed(biome_id: String) -> void:
	if biome_id == current_biome_id:
		refresh_tracker()
