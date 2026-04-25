extends Control

@onready var outcome_label: Label = $VBox/OutcomeLabel
@onready var detail_label: Label = $VBox/DetailLabel


func _ready() -> void:
	var victory: bool = SceneManager.incoming_data.get("victory", false)
	if victory:
		outcome_label.text = "The dungeon retreats."
		detail_label.text = "Depth %d cleared." % GameState.current_depth
	else:
		outcome_label.text = "The dungeon claims another."
		detail_label.text = "Reached depth %d." % GameState.current_depth


func _on_new_run_button_pressed() -> void:
	GameState.clear_run()
	SceneManager.go_to("res://scenes/ui/MainMenu.tscn")
