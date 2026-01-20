# save_manager.gd
class_name SaveManager
extends Node

const SAVE_PATH = "res://savegame.tres"

func save_game(player_data: Dictionary, event_history: Dictionary, days_passed: int) -> bool:
	var save_data = {
		"player_data": player_data.duplicate(),
		"event_history": event_history.duplicate(true),
		"days_passed": days_passed,
		"timestamp": Time.get_datetime_dict_from_system()
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		return true
	return false

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()
		return data
	return {}

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
