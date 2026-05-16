extends Node

signal mission_updated(biome_id: String)
signal mission_completed(biome_id: String)

var missions := {
	"spring": {
		"title": "Spring Biome",
		"subtitle": "The Ark Begins",
		"description": "Collect natural resources to begin building the Ark.",
		"items": {
			"wood": {
				"display_name": "Wood",
				"required": 10,
				"icon": preload("res://assets/sprites/items/spring/wood.png")
			},
			"rope": {
				"display_name": "Rope",
				"required": 4,
				"icon": preload("res://assets/sprites/items/spring/rope.png")
			},
			"pitch": {
				"display_name": "Pitch",
				"required": 3,
				"icon": preload("res://assets/sprites/items/spring/pitch.png")
			},
			"stone": {
				"display_name": "Stone",
				"required": 5,
				"icon": preload("res://assets/sprites/items/spring/stone.png")
			}
		}
	}
}

var progress := {}
var completed_missions := {}

func _ready() -> void:
	initialize_missions()

func initialize_missions() -> void:
	for biome_id in missions.keys():
		progress[biome_id] = {}
		completed_missions[biome_id] = false

		var items: Dictionary = missions[biome_id]["items"]

		for item_id in items.keys():
			progress[biome_id][item_id] = 0

func add_item(biome_id: String, item_id: String, amount: int = 1) -> bool:
	if not missions.has(biome_id):
		print("Biome does not exist: ", biome_id)
		return false

	var items: Dictionary = missions[biome_id]["items"]

	if not items.has(item_id):
		print("Item does not exist in this biome: ", item_id)
		return false

	var required_amount: int = items[item_id]["required"]
	var current_amount: int = progress[biome_id].get(item_id, 0)

	if current_amount >= required_amount:
		return false

	progress[biome_id][item_id] = min(current_amount + amount, required_amount)

	mission_updated.emit(biome_id)

	if is_mission_complete(biome_id) and completed_missions[biome_id] == false:
		completed_missions[biome_id] = true
		mission_completed.emit(biome_id)

	return true

func is_mission_complete(biome_id: String) -> bool:
	if not missions.has(biome_id):
		return false

	var items: Dictionary = missions[biome_id]["items"]

	for item_id in items.keys():
		var required_amount: int = items[item_id]["required"]
		var current_amount: int = progress[biome_id].get(item_id, 0)

		if current_amount < required_amount:
			return false

	return true

func get_mission_data(biome_id: String) -> Dictionary:
	if not missions.has(biome_id):
		return {}

	return missions[biome_id]

func get_item_progress(biome_id: String, item_id: String) -> int:
	if not progress.has(biome_id):
		return 0

	return progress[biome_id].get(item_id, 0)

func get_item_required_amount(biome_id: String, item_id: String) -> int:
	if not missions.has(biome_id):
		return 0

	var items: Dictionary = missions[biome_id]["items"]

	if not items.has(item_id):
		return 0

	return items[item_id]["required"]

func get_item_display_name(biome_id: String, item_id: String) -> String:
	if not missions.has(biome_id):
		return item_id

	var items: Dictionary = missions[biome_id]["items"]

	if not items.has(item_id):
		return item_id

	return items[item_id]["display_name"]
	

func get_item_icon(biome_id: String, item_id: String) -> Texture2D:
	if not missions.has(biome_id):
		return null

	var items: Dictionary = missions[biome_id]["items"]

	if not items.has(item_id):
		return null

	return items[item_id].get("icon", null)
