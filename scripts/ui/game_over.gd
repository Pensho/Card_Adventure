extends Control

@onready var outcome_label: Label = $VBox/OutcomeLabel
@onready var detail_label: Label = $VBox/DetailLabel


func _ready() -> void:
	var victory: bool = SceneManager.incoming_data.get("victory", false)
	if victory:
		outcome_label.text = "The dungeon retreats."
		var cleared: int = SceneManager.incoming_data.get("completed_depth", GameState.current_depth - 1)
		detail_label.text = "Depth %d cleared." % cleared
	else:
		outcome_label.text = "The dungeon claims another."
		detail_label.text = "Reached depth %d." % GameState.current_depth


func _on_new_run_button_pressed() -> void:
	GameState.clear_run()
	SceneManager.go_to("res://scenes/ui/MainMenu.tscn")
