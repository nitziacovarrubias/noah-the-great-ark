extends CanvasLayer

@export var slot_scene: PackedScene
@export var test_items: Array[InventoryItem] = []

@onready var root: Control = $Root
@onready var close_button: Button = $Root/CenterContainer/InventoryPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var grid_container: GridContainer = $Root/CenterContainer/InventoryPanel/MarginContainer/VBoxContainer/Content/SlotsPanel/GridContainer
@onready var item_name_label: Label = $Root/CenterContainer/InventoryPanel/MarginContainer/VBoxContainer/Content/InfoPanel/ItemNameLabel
@onready var item_description_label: Label = $Root/CenterContainer/InventoryPanel/MarginContainer/VBoxContainer/Content/InfoPanel/ItemDescriptionLabel

var is_open := false
var slot_count := 20

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(close_inventory)
	create_slots()
	close_inventory()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory() -> void:
	if is_open:
		close_inventory()
	else:
		open_inventory()

func open_inventory() -> void:
	is_open = true
	root.visible = true
	get_tree().paused = true

func close_inventory() -> void:
	is_open = false
	root.visible = false
	get_tree().paused = false

func create_slots() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	for i in range(slot_count):
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)

		if i < test_items.size():
			slot.set_item(test_items[i], 1)
		else:
			slot.clear_slot()

		slot.slot_pressed.connect(_on_slot_pressed)

func _on_slot_pressed(item_data: InventoryItem) -> void:
	item_name_label.text = item_data.item_name
	item_description_label.text = item_data.description
