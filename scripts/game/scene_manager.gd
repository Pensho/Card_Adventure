extends Node

signal transition_started
signal transition_finished

var incoming_data: Dictionary = {}

var _canvas: CanvasLayer
var _overlay: ColorRect


func _ready() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 100
	add_child(_canvas)

	_overlay = ColorRect.new()
	_overlay.color = Color.BLACK
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.modulate.a = 0.0
	_canvas.add_child(_overlay)


func go_to(scene_path: String, data: Dictionary = {}) -> void:
	incoming_data = data
	transition_started.emit()

	var fade_out := create_tween()
	fade_out.tween_property(_overlay, "modulate:a", 1.0, 0.2)
	await fade_out.finished

	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame

	var fade_in := create_tween()
	fade_in.tween_property(_overlay, "modulate:a", 0.0, 0.2)
	await fade_in.finished

	transition_finished.emit()
	incoming_data = {}
