extends CanvasLayer

@onready var root: Control = $Root
@onready var title_label: Label = $Root/TextureRect/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $Root/TextureRect/VBoxContainer/SubtitleLabel
@onready var description_label: Label = $Root/TextureRect/VBoxContainer/DescriptionLabel
@onready var objective_label: Label = $Root/TextureRect/VBoxContainer/ObjectiveLabel
@onready var items_list: VBoxContainer = $Root/TextureRect/VBoxContainer/ItemsList
@onready var continue_button: Button = $Root/TextureRect/VBoxContainer/ContinueButton

var current_biome_id := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	continue_button.pressed.connect(close_popup)
	MissionManager.mission_updated.connect(_on_mission_updated)

	root.visible = false

func show_mission(biome_id: String) -> void:
	current_biome_id = biome_id

	var mission_data := MissionManager.get_mission_data(biome_id)

	if mission_data.is_empty():
		return

	title_label.text = mission_data["title"]
	subtitle_label.text = mission_data["subtitle"]
	description_label.text = mission_data["description"]
	objective_label.text = "Required resources:"

	update_items_list(biome_id)

	root.visible = true
	get_tree().paused = true
	continue_button.grab_focus()

func close_popup() -> void:
	root.visible = false
	get_tree().paused = false

func update_items_list(biome_id: String) -> void:
	for child in items_list.get_children():
		child.queue_free()

	var mission_data := MissionManager.get_mission_data(biome_id)

	if mission_data.is_empty():
		return

	var items: Dictionary = mission_data["items"]

	for item_id in items.keys():
		var display_name: String = MissionManager.get_item_display_name(biome_id, item_id)
		var required_amount: int = MissionManager.get_item_required_amount(biome_id, item_id)
		var current_amount: int = MissionManager.get_item_progress(biome_id, item_id)

		var label := Label.new()
		label.text = "- " + display_name + " " + str(current_amount) + "/" + str(required_amount)

		label.add_theme_color_override(
			"font_color",
			Color("#1e3a5f")
		)

		items_list.add_child(label)

func _on_mission_updated(biome_id: String) -> void:
	if root.visible and biome_id == current_biome_id:
		update_items_list(biome_id)
		
func _unhandled_input(event: InputEvent) -> void:
	if not root.visible:
		return

	if event.is_action_pressed("ui_accept"):
		close_popup()
		get_viewport().set_input_as_handled()
