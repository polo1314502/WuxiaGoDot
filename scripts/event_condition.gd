# event_condition.gd - 事件條件資源類
class_name EventCondition
extends Resource

@export_enum("turn_equals", "turn_greater", "turn_less", "stat_greater", "stat_less", "stat_equals", "completed_event", "has_skill", "random_chance") var condition_type: String = ""
@export var condition_params: Dictionary = {}

# 輔助函數：檢查條件是否滿足
func check(main_scene) -> bool:
	var player_data = main_scene.player_data
	var turns = main_scene.turns_passed
	var event_history = main_scene.event_manager.event_history
	
	match condition_type:
		"turn_equals":
			return turns == condition_params.get("turn", 0)
		
		"turn_greater":
			return turns >= condition_params.get("turn", 0)
		
		"turn_less":
			return turns <= condition_params.get("turn", 0)
		
		"stat_greater":
			var stat_name = condition_params.get("stat", "attack")
			var value = condition_params.get("value", 0)
			if player_data.has(stat_name):
				return player_data[stat_name] >= value
			return false
		
		"stat_less":
			var stat_name = condition_params.get("stat", "attack")
			var value = condition_params.get("value", 0)
			if player_data.has(stat_name):
				return player_data[stat_name] <= value
			return false
		
		"stat_equals":
			var stat_name = condition_params.get("stat", "attack")
			var value = condition_params.get("value", 0)
			if player_data.has(stat_name):
				return player_data[stat_name] == value
			return false
		
		"has_skill":
			var skill_id = condition_params.get("skill_id", "")
			return skill_id in player_data.skills
		
		"completed_event":
			var event_id = condition_params.get("event_id", "")
			return event_history.has(event_id) and event_history[event_id].size() > 0
		
		"random_chance":
			var chance = condition_params.get("chance", 50)  # 0-100
			return randf() * 100 < chance
		
		_:
			return false
