# event_action.gd - 動作基類
class_name EventAction
extends RefCounted

var main_scene  # 對主場景的引用
var player_data: Dictionary
var result_text: String = ""
var triggers_battle: bool = false
var battle_params: Dictionary = {}
var choice_data = null  # 新增：存儲對應的 choice 對象

func _init(main, params: Dictionary = {}):
	main_scene = main
	player_data = main.player_data
	setup(params)

func setup(params: Dictionary):
	pass  # 子類覆寫以設置參數

func can_execute() -> bool:
	return true  # 子類可覆寫條件檢查

func execute():
	pass  # 子類必須實現

func get_result() -> String:
	return result_text
