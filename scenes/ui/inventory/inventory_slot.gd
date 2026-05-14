extends TextureButton

signal slot_pressed(item_data)

@onready var icon: TextureRect = $Icon
@onready var amount_label: Label = $AmountLabel

var item_data: Resource = null
var amount: int = 0

func _ready() -> void:
	pressed.connect(_on_pressed)
	clear_slot()

func set_item(new_item: Resource, new_amount: int = 1) -> void:
	item_data = new_item
	amount = new_amount

	if item_data != null and item_data.icon != null:
		icon.texture = item_data.icon
		icon.visible = true
	else:
		icon.texture = null
		icon.visible = false

	if amount > 1:
		amount_label.text = str(amount)
	else:
		amount_label.text = ""

func clear_slot() -> void:
	item_data = null
	amount = 0
	icon.texture = null
	icon.visible = false
	amount_label.text = ""

func _on_pressed() -> void:
	if item_data != null:
		slot_pressed.emit(item_data)
