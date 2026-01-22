# event_manager.gd
class_name EventManager
extends Node

signal event_started(event_id: String)
signal event_completed(event_id: String)
signal choice_made(choice_index: int)
signal battle_triggered(battle_params: Dictionary)
signal auto_event_triggered(event: EventData)  # 新增：自動觸發事件信號

var main_scene
var current_event: EventData = null
var current_step_index: int = 0
var event_history: Dictionary = {}  # 記錄已觸發的事件
var available_events: Array = []

func _init(main):
	main_scene = main

func load_events_from_directory(path: String = "res://events/"):
	available_events.clear()
	_scan_directory(path)

func trigger_random_event():
	if available_events.is_empty():
		return null
	
	# 過濾出可以觸發的事件
	var valid_events = get_valid_events()
	
	if valid_events.is_empty():
		return null
	
	# 按優先級排序
	valid_events.sort_custom(func(a, b): return a.priority > b.priority)
	
	# 如果有高優先級事件，優先觸發
	if valid_events.size() > 0 and valid_events[0].priority > 0:
		trigger_event(valid_events[0])
		return valid_events[0]
	
	# 否則隨機選擇
	var event = valid_events[randi() % valid_events.size()]
	trigger_event(event)
	return event

func get_valid_events() -> Array:
	var valid = []
	
	for event in available_events:
		if can_trigger_event(event):
			valid.append(event)
	
	return valid

func can_trigger_event(event: EventData) -> bool:
	# 檢查是否可重複
	if not event.can_repeat:
		if event_history.has(event.event_id) and event_history[event.event_id].size() > 0:
			return false
	
	# 檢查觸發條件
	if event.trigger_conditions.is_empty():
		return true  # 沒有觸發條件，總是可觸發
	
	# 所有觸發條件都要滿足
	for condition in event.trigger_conditions:
		if condition is EventCondition:
			if not condition.check(main_scene):
				return false
	
	return true

func check_auto_trigger_events():
	
	for event in available_events:
		
		if event.trigger_conditions.is_empty():
			continue
		
		if can_trigger_event(event):
			trigger_event(event)
			auto_event_triggered.emit(event)
			return event
		
	return null

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
	
	# 如果有 EnemyData 資源，直接使用
	if choice.enemy_data:
		choice.action_params["enemy_data"] = choice.enemy_data
	
	var action = ActionFactory.create_action(main_scene, choice.action_type, choice.action_params)
	
	if action and action.can_execute():
		action.execute()
		choice_made.emit(choice_index)
		
		if action.triggers_battle:
			battle_triggered.emit(action.battle_params)
		
		# 將 choice 對象也返回，讓主場景知道是否要繼續事件
		action.choice_data = choice
		return action
	else:
		# 無法執行（如銀兩不足）
		var fail_action = EventAction.new(main_scene, {})
		fail_action.result_text = "你無法完成這個選擇..."
		fail_action.choice_data = choice
		return fail_action

func complete_event():
	if current_event:
		event_completed.emit(current_event.event_id)
	current_event = null
	current_step_index = 0

## 根據 event_id 獲取事件
func get_event_by_id(event_id: String) -> EventData:
	for event in available_events:
		if event.event_id == event_id:
			return event
	return null
	
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
