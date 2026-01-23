# ============================================
# 場景模式腳本（獨立模式）
# ============================================

extends Panel

# 信號定義
signal action_executed(action: LocationAction)
signal return_to_training_requested()

# UI 節點引用
@onready var location_text = $VBoxContainer/LocationText
@onready var location_list = $VBoxContainer/LocationList
@onready var back_button = $VBoxContainer/BackButton

# 外部依賴（由Main傳入）
var main_node: Node = null
var location_manager: LocationManager = null
var player_data: Dictionary = {}
var event_triggered_from_location: bool = true

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)

func initialize(main_ref: Node, loc_manager: LocationManager, p_data: Dictionary):
	"""初始化場景模式"""
	main_node = main_ref
	location_manager = loc_manager
	player_data = p_data

func show_location_selection():
	"""顯示場景選擇UI"""
	if not location_manager:
		push_error("LocationManager 未初始化！")
		return
	
	var available_locations = location_manager.get_available_locations()
	update_location_list(available_locations)
	location_text.text = "\n選擇你想探索的地點："

func update_location_list(locations: Array[LocationData]):
	"""更新地點列表"""
	# 清空現有按鈕
	for child in location_list.get_children():
		child.queue_free()
	
	# 創建地點按鈕
	for location in locations:
		var btn = Button.new()
		btn.text = location.location_name
		btn.pressed.connect(func(): enter_location(location))
		location_list.add_child(btn)
	
	# 添加返回按鈕（只在第一天之後顯示）
	if main_node and main_node.days_passed != 0:
		var back_btn = Button.new()
		back_btn.text = "返回養成模式"
		back_btn.pressed.connect(_on_return_to_training)
		location_list.add_child(back_btn)

func enter_location(location: LocationData):
	"""進入地點，顯示子地點列表"""
	if not location_manager:
		return
		
	location_manager.enter_location(location)
	
	var sub_locations = location_manager.get_available_sub_locations()
	if sub_locations.is_empty():
		location_text.text = "\n" + location.location_name + " - 暫無可用場所"
		return
	
	# 顯示子地點選擇
	location_text.text = "\n" + location.description
	
	# 清空現有按鈕
	for child in location_list.get_children():
		child.queue_free()
	
	# 創建子地點按鈕
	for sub_loc in sub_locations:
		var btn = Button.new()
		btn.text = sub_loc.sub_location_name
		btn.pressed.connect(func(): enter_sub_location(sub_loc))
		location_list.add_child(btn)
	
	# 添加返回按鈕
	var back_btn = Button.new()
	back_btn.text = "離開"
	back_btn.pressed.connect(show_location_selection)
	location_list.add_child(back_btn)

func enter_sub_location(sub_location: SubLocation):
	"""進入子地點，顯示動作列表"""
	if not location_manager:
		return
		
	location_manager.enter_sub_location(sub_location)
	
	var actions = location_manager.get_available_actions()
	
	# 顯示子地點描述和動作
	location_text.text = "\n" + sub_location.description
	
	# 清空現有按鈕
	for child in location_list.get_children():
		child.queue_free()
	
	# 創建動作按鈕
	for action in actions:
		var btn = Button.new()
		btn.text = location_manager.get_action_display_text(action)
		btn.disabled = not location_manager.is_action_available(action)
		btn.pressed.connect(func(): execute_location_action(action))
		location_list.add_child(btn)
	
	# 添加返回按鈕
	var back_btn = Button.new()
	back_btn.text = "離開"
	back_btn.pressed.connect(func(): enter_location(location_manager.current_location))
	location_list.add_child(back_btn)

func execute_location_action(action: LocationAction):
	"""執行地點動作"""
	if location_manager and location_manager.execute_action(action):
		# 動作執行成功，發送信號
		action_executed.emit(action)

func return_to_current_view():
	"""返回當前視圖（在事件結束後調用）"""
	if location_manager.current_sub_location:
		# 在子地點，返回子地點視圖
		enter_sub_location(location_manager.current_sub_location)
	elif location_manager.current_location:
		# 在主地點，返回主地點視圖
		enter_location(location_manager.current_location)
	else:
		# 都不在，返回地點選擇
		show_location_selection()

func _on_back_button_pressed():
	"""返回按鈕處理"""
	show_location_selection()

func _on_return_to_training():
	"""返回養成模式"""
	return_to_training_requested.emit()
