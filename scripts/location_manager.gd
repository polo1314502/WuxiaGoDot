# location_manager.gd - 地點管理器
class_name LocationManager
extends Node

signal location_changed(location: LocationData)
signal sub_location_entered(sub_location: SubLocation)
signal action_executed(action: LocationAction)

var main_scene
var condition_checker: ConditionChecker

## 當前所在地點
var current_location: LocationData = null

## 當前所在子地點
var current_sub_location: SubLocation = null

## 所有可用地點
var all_locations: Array[LocationData] = []

## 動作歷史記錄 {action_id: {last_used_day: int, use_count: int}}
var action_history: Dictionary = {}

func _init(main):
	main_scene = main
	condition_checker = ConditionChecker.new(main_scene)

## 載入所有地點資源
func load_locations_from_directory(path: String = "res://locations/"):
	all_locations.clear()
	_scan_directory(path)
	print("已載入 %d 個地點" % all_locations.size())

func _scan_directory(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			var file_path = path + file_name
			
			if dir.current_is_dir():
				if not file_name.begins_with("."):
					_scan_directory(file_path + "/")
			elif file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var resource = load(file_path)
				if resource is LocationData:
					all_locations.append(resource)
					print("已載入地點：", resource.location_name)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()

## 獲取可用地點列表
func get_available_locations() -> Array[LocationData]:
	var available: Array[LocationData] = []
	for location in all_locations:
		if is_location_available(location):
			available.append(location)
	return available

## 檢查地點是否可用
func is_location_available(location: LocationData) -> bool:
	if location.available_conditions.is_empty():
		return true
	return condition_checker.check_all_conditions(location.available_conditions)

## 進入地點
func enter_location(location: LocationData):
	current_location = location
	current_sub_location = null
	location_changed.emit(location)
	print("進入地點：", location.location_name)

## 獲取當前地點的可用子地點
func get_available_sub_locations() -> Array[SubLocation]:
	if not current_location:
		return []
	
	var available: Array[SubLocation] = []
	for sub_loc in current_location.sub_locations:
		if is_sub_location_available(sub_loc):
			available.append(sub_loc)
	return available

## 檢查子地點是否可用
func is_sub_location_available(sub_location: SubLocation) -> bool:
	if sub_location.available_conditions.is_empty():
		return true
	return condition_checker.check_all_conditions(sub_location.available_conditions)

## 進入子地點
func enter_sub_location(sub_location: SubLocation):
	current_sub_location = sub_location
	sub_location_entered.emit(sub_location)
	print("進入子地點：", sub_location.sub_location_name)

## 獲取當前子地點的可用動作
func get_available_actions() -> Array[LocationAction]:
	if not current_sub_location:
		return []
	
	var available: Array[LocationAction] = []
	for action in current_sub_location.actions:
		if is_action_available(action):
			available.append(action)
	return available

## 檢查動作是否可用
func is_action_available(action: LocationAction) -> bool:
	# 檢查條件
	if action.available_conditions.is_empty():
		return true
	return condition_checker.check_all_conditions(action.available_conditions)

## 執行動作
func execute_action(action: LocationAction) -> bool:
	if not is_action_available(action):
		return false
	
	# 記錄使用歷史
	if not action_history.has(action.action_id):
		action_history[action.action_id] = {}
	
	action_history[action.action_id]["last_used_day"] = main_scene.days_passed
	action_history[action.action_id]["use_count"] = action_history[action.action_id].get("use_count", 0) + 1
	
	# 觸發事件
	trigger_event_by_id(action.trigger_event_id)
	
	action_executed.emit(action)
	return true

## 觸發單個事件
func trigger_event_by_id(event_id: String):
	var event = main_scene.event_manager.get_event_by_id(event_id)
	if event:
		main_scene.event_triggered_from_location = true  # 標記事件從場景模式觸發
		main_scene.event_manager.trigger_event(event)
		main_scene.show_event()
	else:
		print("警告：找不到事件 ID: ", event_id)

## 開始事件序列
func start_event_sequence(event_ids: Array[String]):
	if event_ids.is_empty():
		return
	
	main_scene.event_triggered_from_location = true  # 標記事件序列從場景模式觸發
	# 將事件序列存儲到主場景中，逐個觸發
	main_scene.start_event_sequence(event_ids)

## 離開當前子地點
func leave_sub_location():
	current_sub_location = null

## 離開當前地點
func leave_location():
	current_location = null
	current_sub_location = null

## 獲取動作的描述文本（包含冷卻和消耗資訊）
func get_action_display_text(action: LocationAction) -> String:
	var text = action.action_name
	return text
