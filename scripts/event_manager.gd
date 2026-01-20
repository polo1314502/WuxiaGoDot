# event_manager.gd
class_name EventManager
extends Node

signal event_started(event_id: String)
signal event_completed(event_id: String)
signal choice_made(choice_index: int)
signal battle_triggered(battle_params: Dictionary)

var main_scene
var current_event: EventData = null
var current_step_index: int = 0
var event_history: Dictionary = {}  # 記錄已觸發的事件
var available_events: Array[EventData] = []

func _init(main):
	main_scene = main

func load_events_from_directory(path: String = "res://events/"):
	available_events.clear()
	# 在實際專案中，這裡會掃描目錄並載入所有 .tres 文件
	# 現在我們用代碼生成範例事件
	#_generate_sample_events()
	_scan_directory(path)

func _generate_sample_events():
	# 乞丐事件
	var beggar_event = EventData.new()
	beggar_event.event_id = "beggar"
	beggar_event.title = "乞丐求助"
	
	var step1 = EventStep.new()
	step1.text = "路邊有個乞丐攔住了你：「少俠，能否施捨點銀兩？」"
	
	var choice1 = EventChoice.new()
	choice1.text = "給他10兩銀子"
	choice1.action_type = "change_stats"
	choice1.action_params = {"money": -10, "reputation": 5}
	
	var choice2 = EventChoice.new()
	choice2.text = "給他100兩銀子"
	choice2.action_type = "change_stats"
	choice2.action_params = {
		"max_hp": 20,
		"money": -100,
		"reputation": 20,
		"message": "你慷慨解囊！乞丐感激涕零：「少俠大恩，小人傳你一套養生功法！」\n聲望 +20"
	}
	
	var choice3 = EventChoice.new()
	choice3.text = "無視離開"
	choice3.action_type = "change_stats"
	choice3.action_params = {"reputation": -2}
	
	step1.choices = [choice1, choice2, choice3]
	beggar_event.steps = [step1]
	available_events.append(beggar_event)
	
	# 惡霸事件
	var bully_event = EventData.new()
	bully_event.event_id = "bully"
	bully_event.title = "惡霸欺人"
	
	var bully_step = EventStep.new()
	bully_step.text = "你看到幾個惡霸正在欺負一個小孩。"
	
	var bully_c1 = EventChoice.new()
	bully_c1.text = "上前制止"
	bully_c1.action_type = "trigger_battle"
	bully_c1.action_params = {
		"enemy_name": "惡霸",
		"hp": 60,
		"attack": 10,
		"defense": 6,
		"speed": 8,
		"message": "你決定路見不平！\n聲望 +10"
	}
	
	var bully_c2 = EventChoice.new()
	bully_c2.text = "暗中觀察"
	bully_c2.action_type = "change_stats"
	bully_c2.action_params = {"speed": 2, "message": "你暗中觀察學習到了身法技巧。"}
	
	bully_step.choices = [bully_c1, bully_c2]
	bully_event.steps = [bully_step]
	available_events.append(bully_event)

func trigger_random_event():
	if available_events.is_empty():
		return null
	
	var event = available_events[randi() % available_events.size()]
	trigger_event(event)
	return event

func trigger_event(event: EventData):
	current_event = event
	current_step_index = 0
	
	# 記錄到歷史
	if not event_history.has(event.event_id):
		event_history[event.event_id] = []
	event_history[event.event_id].append({
		"timestamp": Time.get_ticks_msec(),
		"day": main_scene.days_passed
	})
	
	event_started.emit(event.event_id)

func get_current_step() -> EventStep:
	if current_event and current_step_index < current_event.steps.size():
		return current_event.steps[current_step_index]
	return null
	
func has_next_step() -> bool:
	if current_event:
		return current_step_index + 1 < current_event.steps.size()
	return false

func next_step():
	if has_next_step():
		current_step_index += 1

func process_choice(choice_index: int):
	var step = get_current_step()
	if not step or choice_index >= step.choices.size():
		return
	
	var choice = step.choices[choice_index]
	var action = ActionFactory.create_action(main_scene, choice.action_type, choice.action_params)
	
	if action and action.can_execute():
		action.execute()
		choice_made.emit(choice_index)
		
		if action.triggers_battle:
			battle_triggered.emit(action.battle_params)
		
		return action
	else:
		# 無法執行（如銀兩不足）
		var fail_action = EventAction.new(main_scene, {})
		fail_action.result_text = "你無法完成這個選擇..."
		return fail_action

func complete_event():
	if current_event:
		event_completed.emit(current_event.event_id)
	current_event = null
	current_step_index = 0
	
func _scan_directory(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var full_path = path + file_name
				var resource = load(full_path)
				if resource is EventData:
					available_events.append(resource)
			file_name = dir.get_next()
		dir.list_dir_end()
