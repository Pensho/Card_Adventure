class_name CardDisplay
extends PanelContainer

signal card_pressed(card: CardData)

var card_data: CardData:
	set(value):
		card_data = value
		_update_display()

@onready var _name_label: Label = $MarginContainer/VBox/CardName
@onready var _toll_label: Label = $MarginContainer/VBox/TollLabel
@onready var _desc_label: Label = $MarginContainer/VBox/DescLabel


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	_update_display()


func set_input_enabled(enabled: bool) -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			card_pressed.emit(card_data)


func _update_display() -> void:
	if not is_node_ready() or card_data == null:
		return
	_name_label.text = card_data.card_name
	_toll_label.text = _toll_text()
	_desc_label.text = card_data.description


func _toll_text() -> String:
	match card_data.toll_type:
		CardData.TollType.FREE:
			return "Free"
		CardData.TollType.HP:
			return "Cost: %d HP" % card_data.toll_value
		CardData.TollType.MOMENTUM:
			return "Cost: %d Momentum" % card_data.toll_value
		CardData.TollType.DISCARD:
			return "Discard %d" % card_data.toll_value
		CardData.TollType.PERFORMANCE:
			return "Cost: %d Performance" % card_data.toll_value
		_:
			return "Toll: %d" % card_data.toll_value
