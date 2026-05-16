extends CanvasLayer

@export var current_biome_id: String = "spring"

@onready var title_label: Label = $Root/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var rows_container: VBoxContainer = $Root/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/RowsContainer

const FEMALE_SUFFIX := "_female"
const MALE_SUFFIX := "_male"

const ANIMAL_NAMES := {
	"cow": "Cows",
	"horse": "Horses",
	"pig": "Pigs",
	"Goat": "Goats",
	"Donkey": "Donkeys",
	"Duck": "Ducks",
	"Chicken": "Chickens"
}

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
	var processed_bases: Array[String] = []

	var item_keys := items.keys()
	item_keys.sort()

	for raw_item_id in item_keys:
		var item_id := String(raw_item_id)


		if _is_pair_item(item_id):
			var base_id := _get_pair_base_id(item_id)

			if processed_bases.has(base_id):
				continue

			var female_id := base_id + FEMALE_SUFFIX
			var male_id := base_id + MALE_SUFFIX

			if items.has(female_id) and items.has(male_id):
				_create_pair_row(base_id, female_id, male_id)
				processed_bases.append(base_id)
			else:
				_create_single_item_row(item_id)
		else:
			_create_single_item_row(item_id)

func _create_pair_row(base_id: String, female_id: String, male_id: String) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 28)
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", 6)

	var name_label := Label.new()
	name_label.text = _get_animal_display_name(base_id) + ":"
	name_label.custom_minimum_size = Vector2(95, 0)

	var female_icon := TextureRect.new()
	female_icon.custom_minimum_size = Vector2(24, 24)
	female_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	female_icon.texture = MissionManager.get_item_icon(current_biome_id, female_id)

	var female_current: int = MissionManager.get_item_progress(current_biome_id, female_id)
	var female_required: int = MissionManager.get_item_required_amount(current_biome_id, female_id)

	var female_label := Label.new()
	female_label.text = str(female_current) + "/" + str(female_required)

	var male_icon := TextureRect.new()
	male_icon.custom_minimum_size = Vector2(24, 24)
	male_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	male_icon.texture = MissionManager.get_item_icon(current_biome_id, male_id)

	var male_current: int = MissionManager.get_item_progress(current_biome_id, male_id)
	var male_required: int = MissionManager.get_item_required_amount(current_biome_id, male_id)

	var male_label := Label.new()
	male_label.text = str(male_current) + "/" + str(male_required)

	row.add_child(name_label)
	row.add_child(female_icon)
	row.add_child(female_label)
	row.add_child(male_icon)
	row.add_child(male_label)

	rows_container.add_child(row)

func _create_single_item_row(item_id: String) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 28)
	row.add_theme_constant_override("separation", 6)

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

func _is_pair_item(item_id: String) -> bool:
	return item_id.ends_with(FEMALE_SUFFIX) or item_id.ends_with(MALE_SUFFIX)

func _get_pair_base_id(item_id: String) -> String:
	if item_id.ends_with(FEMALE_SUFFIX):
		return item_id.substr(0, item_id.length() - FEMALE_SUFFIX.length())

	if item_id.ends_with(MALE_SUFFIX):
		return item_id.substr(0, item_id.length() - MALE_SUFFIX.length())

	return item_id

func _get_animal_display_name(base_id: String) -> String:
	if ANIMAL_NAMES.has(base_id):
		return ANIMAL_NAMES[base_id]

	return base_id.replace("_", " ").capitalize()

func _on_mission_updated(biome_id: String) -> void:
	if biome_id == current_biome_id:
		refresh_tracker()

func _on_mission_completed(biome_id: String) -> void:
	if biome_id == current_biome_id:
		refresh_tracker()
