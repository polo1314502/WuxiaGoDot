# event_choice.gd - 事件選項資源類（必須先定義）
class_name EventChoice
extends Resource

enum ActionType {
	GIVE_MONEY,
	GAIN_STATS,
	TRIGGER_BATTLE,
	CHANGE_REPUTATION,
	BUY_ITEM
}

@export var text: String = ""
@export_enum("give_money", "gain_stats", "trigger_battle", "change_reputation", "buy_item") var action_type: String = ""
@export var action_params: Dictionary = {
	"attack": 0,
	"defense": 0,
	"max_hp": 0,
	"speed": 0,
	"enemy_name" : "",
	"enemy_hp" : 0,
	"enemy_attack": 0,
	"enemy_defense": 0,
	"enemy_speed": 0,
	"money" : 0,
	"reputation": 0,
	"message": ""
}
