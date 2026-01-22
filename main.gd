# ============================================
# 主場景腳本（重構版）
# ============================================

# Main.gd
extends Node2D

var player_data = {
	"name": "主角",
	"level": 1,
	"exp": 0,
	"hp": 100,
	"max_hp": 100,
	"mp": 50,  # 新增：內力值
	"max_mp": 50,
	"attack": 15,
	"defense": 10,
	"speed": 12,
	"money": 100,
	"reputation": 0,
	"skills": ["普通攻擊"], # 技能ID列表
	"training_points": 10
}

var days_passed = 0

@onready var mode_label = $UI/ModeLabel
@onready var training_panel = $UI/TrainingPanel
@onready var battle_panel = $UI/BattlePanel
@onready var event_panel = $UI/EventPanel
@onready var stats_label = $UI/StatsLabel
@onready var location_panel = $UI/LocationPanel

var in_battle = false
var enemy_data = {}
var battle_turn = "player"
var battle_log = []

# 新系統
var event_manager: EventManager
var event_state_machine: EventStateMachine
var save_manager: SaveManager
var skill_manager: SkillManager
var enemy_manager: EnemyManager  # 新增：敵人管理器
var location_manager: LocationManager  # 新增：場景管理器
var current_action_result = null  # 新增：儲存當前動作結果
var event_sequence: Array[String] = []  # 事件序列
var event_sequence_index: int = 0  # 當前事件序列索引
var event_triggered_from_location: bool = false  # 記錄事件是否從場景模式觸發

func _ready():
	# 初始化系統
	event_manager = EventManager.new(self)
	event_manager.load_events_from_directory()
	
	event_state_machine = EventStateMachine.new(self, event_manager)
	event_state_machine.result_ready.connect(_on_event_result_ready)
	event_state_machine.state_changed.connect(_on_event_state_changed)
	
	event_manager.battle_triggered.connect(_on_battle_triggered)
	
	save_manager = SaveManager.new()
	
	skill_manager = SkillManager.new(self)  # 新增：初始化技能管理器
	skill_manager.load_skills_from_directory()
	
	enemy_manager = EnemyManager.new(self)  # 新增：初始化敵人管理器
	enemy_manager.load_enemies_from_directory()
	
	location_manager = LocationManager.new(self)  # 新增：初始化場景管理器
	location_manager.load_locations_from_directory()
	location_manager.action_executed.connect(_on_location_action_executed)
	
	# 嘗試讀取存檔
	if save_manager.has_save():
		var save_data = save_manager.load_game()
		if not save_data.is_empty():
			player_data = save_data.player_data
			event_manager.event_history = save_data.event_history
			days_passed = save_data.days_passed
	
	show_training_mode()
	update_stats_display()

func show_training_mode():
	in_battle = false
	if player_data.hp == 0:
		player_data.hp = 1
	stats_label.visible = true
	mode_label.text = "養成模式 - 第 %d 天" % days_passed
	training_panel.visible = true
	battle_panel.visible = false
	event_panel.visible = false
	location_panel.visible = false  # 添加這一行
	update_stats_display()

func return_to_location_mode():
	event_panel.visible = false
	battle_panel.visible = false
	location_panel.visible = true
	if location_manager.current_sub_location or location_manager.current_location:
		# 如果在主地點或子地點，返回主地點界面
		enter_location(location_manager.current_location)
	else:
		# 都不在，返回地點選擇
		show_location_selection()

func _on_train_attack_pressed():
	if player_data.training_points > 0:
		player_data.attack += 2
		player_data.training_points -= 1
		advance_day()

func _on_train_defense_pressed():
	if player_data.training_points > 0:
		player_data.defense += 2
		player_data.training_points -= 1
		advance_day()

func _on_train_hp_pressed():
	if player_data.training_points > 0:
		player_data.max_hp += 10
		player_data.hp = player_data.max_hp
		player_data.training_points -= 1
		advance_day()

func _on_rest_pressed():
	player_data.hp = player_data.max_hp
	player_data.training_points += 5
	advance_day()

func _on_trigger_event_pressed():
	event_triggered_from_location = false  # 從養成模式觸發
	var event = event_manager.trigger_random_event()
	if event:
		show_event()

func _on_explore_locations_pressed():
	"""新增：打開場景選擇界面"""
	show_location_selection()

func show_location_selection():
	"""顯示場景選擇UI"""
	mode_label.text = "選擇地點"
	stats_label.visible = false
	training_panel.visible = false
	battle_panel.visible = false
	event_panel.visible = false
	location_panel.visible = true
	
	var available_locations = location_manager.get_available_locations()
	update_location_list(available_locations)

func update_location_list(locations: Array[LocationData]):
	"""更新地點列表"""
	var location_list = $UI/LocationPanel/VBoxContainer/LocationList
	
	# 清空現有按鈕
	for child in location_list.get_children():
		child.queue_free()
	
	# 創建地點按鈕
	for location in locations:
		var btn = Button.new()
		btn.text = location.location_name
		btn.pressed.connect(func(): enter_location(location))
		location_list.add_child(btn)
	
	# 添加返回按鈕
	var back_btn = Button.new()
	back_btn.text = "返回"
	back_btn.pressed.connect(show_training_mode)
	location_list.add_child(back_btn)

func enter_location(location: LocationData):
	"""進入地點，顯示子地點列表"""
	location_manager.enter_location(location)
	mode_label.text = location.location_name
	
	var sub_locations = location_manager.get_available_sub_locations()
	if sub_locations.is_empty():
		mode_label.text = location.location_name + " - 暫無可用場所"
		return
	
	# 顯示子地點選擇
	var location_text = $UI/LocationPanel/VBoxContainer/LocationText
	location_text.text = "\n" + location.description
	
	var location_list = $UI/LocationPanel/VBoxContainer/LocationList
	
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
	location_manager.enter_sub_location(sub_location)
	mode_label.text = location_manager.current_location.location_name + " - " + sub_location.sub_location_name
	
	var actions = location_manager.get_available_actions()
	
	# 顯示子地點描述和動作
	var location_text = $UI/LocationPanel/VBoxContainer/LocationText
	location_text.text = "\n" + sub_location.description
	
	var location_list = $UI/LocationPanel/VBoxContainer/LocationList
	
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
	if location_manager.execute_action(action):
		# 動作執行成功，事件會自動觸發
		pass

func _on_location_action_executed(action: LocationAction):
	"""處理動作執行後的回調"""
	print("執行動作：", action.action_name)

func start_event_sequence(event_ids: Array[String]):
	"""開始事件序列"""
	event_sequence = event_ids
	event_sequence_index = 0
	trigger_next_event_in_sequence()

func trigger_next_event_in_sequence():
	"""觸發事件序列中的下一個事件"""
	if event_sequence_index >= event_sequence.size():
		# 序列結束
		event_sequence.clear()
		event_sequence_index = 0
		# 根據觸發來源返回相應模式
		if event_triggered_from_location:
			return_to_location_mode()
		else:
			show_training_mode()
		return
	
	var event_id = event_sequence[event_sequence_index]
	var event = event_manager.get_event_by_id(event_id)
	if event:
		event_manager.trigger_event(event)
		show_event()
	else:
		# 事件不存在，跳過
		event_sequence_index += 1
		trigger_next_event_in_sequence()

func on_event_sequence_step_completed():
	"""事件序列中的一個事件完成"""
	event_sequence_index += 1
	if event_sequence_index < event_sequence.size():
		# 還有下一個事件
		trigger_next_event_in_sequence()
	else:
		# 序列結束
		event_sequence.clear()
		event_sequence_index = 0

func _on_save_game_pressed():
	if save_manager.save_game(player_data, event_manager.event_history, days_passed):
		mode_label.text = "遊戲已保存！"

func advance_day():
	days_passed += 1
	mode_label.text = "養成模式 - 第 %d 天" % days_passed
	update_stats_display()
	
	# 自動保存
	save_manager.save_game(player_data, event_manager.event_history, days_passed)
	
	# 檢查是否有自動觸發的事件
	var auto_event = event_manager.check_auto_trigger_events()
	if auto_event:
		# 延遲一下再觸發事件，讓玩家看到日期變化
		await get_tree().create_timer(0.5).timeout
		show_event()

func _on_auto_event_triggered(event: EventData):
	"""處理自動觸發的事件"""
	mode_label.text = "第 %d 天 - %s" % [days_passed, event.title]

# === 事件系統 UI ===
func show_event():
	var step = event_manager.get_current_step()
	if not step:
		return
	
	mode_label.text = "事件：" + event_manager.current_event.title
	training_panel.visible = false
	battle_panel.visible = false
	location_panel.visible = false
	event_panel.visible = true
	
	$UI/EventPanel/EventText.text = step.text
	
	# 清除舊按鈕
	for child in $UI/EventPanel/ChoicesContainer.get_children():
		child.queue_free()
	
	# 檢查是否有選項
	if step.choices.is_empty():
		# 無選項事件 - 只顯示繼續按鈕
		var continue_btn = Button.new()
		continue_btn.text = "繼續"
		continue_btn.custom_minimum_size = Vector2(200, 40)
		continue_btn.pressed.connect(func():
			# 檢查是否還有下一步
			if event_manager.has_next_step():
				event_manager.next_step()
				show_event()
			else:
				# 事件結束
				event_state_machine.complete_event()
				
				# 檢查是否在事件序列中
				if not event_sequence.is_empty():
					on_event_sequence_step_completed()
				else:
					# 根據觸發來源返回相應模式
					if event_triggered_from_location:
						return_to_location_mode()
					else:
						advance_day()
						show_training_mode()
		)
		$UI/EventPanel/ChoicesContainer.add_child(continue_btn)
	else:
		# 有選項 - 創建選項按鈕
		for i in range(step.choices.size()):
			var choice = step.choices[i]
			var btn = Button.new()
			btn.text = choice.text
			btn.custom_minimum_size = Vector2(300, 40)
			btn.pressed.connect(_on_event_choice_pressed.bind(i))
			$UI/EventPanel/ChoicesContainer.add_child(btn)
	
	event_state_machine.show_current_step()

func _on_event_choice_pressed(choice_index: int):
	event_state_machine.handle_choice(choice_index)
	
func _handle_action_result(action):
	current_action_result = action

func _on_event_result_ready(result_text: String):
	$UI/EventPanel/EventText.text = result_text
	
	# 清除選項
	for child in $UI/EventPanel/ChoicesContainer.get_children():
		child.queue_free()
	
	# 添加繼續按鈕
	if event_state_machine.current_state != EventStateMachine.State.BATTLE_PENDING:
		var continue_btn = Button.new()
		continue_btn.text = "繼續"
		continue_btn.custom_minimum_size = Vector2(200, 40)
		continue_btn.pressed.connect(func():
			# 檢查這個選擇是否要求立即結束事件
			var should_end = false
			if current_action_result and current_action_result.choice_data:
				should_end = current_action_result.choice_data.end_event
			
			current_action_result = null  # 清除暫存
			
			if should_end:
				# 立即結束事件
				event_state_machine.complete_event()
				advance_day()
				# 根據觸發來源返回相應模式
				if event_triggered_from_location:
					return_to_location_mode()
				else:
					show_training_mode()
			elif event_manager.has_next_step():
				# 繼續到下一步
				event_manager.next_step()
				show_event()
			else:
				# 沒有下一步了，結束事件
				event_state_machine.complete_event()
				advance_day()
				# 根據觸發來源返回相應模式
				if event_triggered_from_location:
					return_to_location_mode()
				else:
					show_training_mode()
		)
		$UI/EventPanel/ChoicesContainer.add_child(continue_btn)
	
	update_stats_display()

func _on_event_state_changed(new_state: int):
	pass  # 可用於 Debug 或顯示狀態

func _on_battle_triggered(battle_params: Dictionary):
	# 縮短等待時間，讓玩家可以更快看到戰鬥文字後進入戰鬥
	await get_tree().create_timer(0.5).timeout
	
	# 檢查是否使用 EnemyData 資源
	if battle_params.has("enemy_data") and battle_params.enemy_data is EnemyData:
		start_battle_with_enemy(battle_params.enemy_data)
	else:
		# 使用舊方式
		start_battle(
			battle_params.get("name", "敵人"),
			battle_params.get("hp", 80),
			battle_params.get("attack", 12),
			battle_params.get("defense", 8),
			battle_params.get("speed", 10),
			battle_params.get("skills", [])  # 新增：敵人技能列表
		)

# === 戰鬥系統 ===
func _on_start_battle_pressed():
	# 測試：使用敵人ID創建戰鬥
	var enemy = enemy_manager.get_enemy_by_id("山賊")
	if enemy:
		start_battle_with_enemy(enemy)
	else:
		# 如果找不到敵人資源，使用舊方法
		start_battle("山賊", 80, 12, 8, 10, ["普通攻擊", "重擊"])

# 使用 EnemyData 創建戰鬥
func start_battle_with_enemy(enemy: EnemyData):
	var battle_data = enemy.create_battle_instance()
	start_battle(
		battle_data.name,
		battle_data.hp,
		battle_data.attack,
		battle_data.defense,
		battle_data.speed,
		battle_data.skills
	)
	# 保存獎勵數據
	enemy_data["exp_reward"] = battle_data.exp_reward
	enemy_data["money_reward"] = battle_data.money_reward

func start_battle(enemy_name: String, hp: int, atk: int, def: int, spd: int, skills: Array = []):
	in_battle = true
	stats_label.visible = false
	enemy_data = {
		"name": enemy_name,
		"hp": hp,
		"max_hp": hp,
		"attack": atk,
		"defense": def,
		"speed": spd,
		"skills": skills  # 敵人技能列表（技能ID）
	}
	
	battle_log.clear()
	battle_turn = "player" if player_data.speed >= enemy_data.speed else "enemy"
	
	mode_label.text = "戰鬥模式"
	training_panel.visible = false
	event_panel.visible = false
	battle_panel.visible = true
	
	# 清除舊的技能按鈕
	for child in $UI/BattlePanel/SkillsContainer.get_children():
		child.queue_free()
	
	# 動態生成技能按鈕
	for skill_id in player_data.skills:
		var skill = skill_manager.get_skill_by_id(skill_id)
		if skill:
			var btn = Button.new()
			if skill.mp_cost == 0:
				btn.text = skill.name
			else:
				btn.text = "%s (內力:%d)" % [skill.name, skill.mp_cost]
			btn.custom_minimum_size = Vector2(150, 40)
			btn.pressed.connect(_on_skill_used.bind(skill_id))
			$UI/BattlePanel/SkillsContainer.add_child(btn)
	
	add_battle_log("遭遇 %s！" % enemy_data.name)
	update_battle_display()
	
	if battle_turn == "enemy":
		await get_tree().create_timer(1.0).timeout
		enemy_turn()
		
func _on_skill_used(skill_id: String):
	if battle_turn != "player" or not in_battle or player_data.hp <= 0 or enemy_data.hp <= 0:
		return
	
	var executor = skill_manager.execute_skill(skill_id)
	
	if not executor:
		add_battle_log("無法使用技能！")
		return
	
	# 輸出所有戰鬥日誌
	for log in executor.get_logs():
		add_battle_log(log)
	
	if in_battle:
		battle_turn = "enemy"
		update_battle_display()
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

func enemy_turn():
	if not in_battle:
		return
	
	if enemy_data.hp > 0:
		# 敵人選擇技能
		var used_skill = false
		
		if enemy_data.skills.size() > 0:
			# 隨機選擇一個技能
			var skill_id = enemy_data.skills[randi() % enemy_data.skills.size()]
			var skill = skill_manager.get_skill_by_id(skill_id)
			
			if skill:
				# 使用統一的 SkillExecutor，傳入 enemy_mode = true
				var executor = SkillExecutor.new(self, skill, true)
				if executor.can_execute():
					executor.execute()
					for log in executor.get_logs():
						add_battle_log(log)
					used_skill = true
		
		# 如果沒有技能或無法使用技能，使用普通攻擊
		if not used_skill:
			var damage = max(1, enemy_data.attack - player_data.defense)
			player_data.hp -= damage
			add_battle_log("%s 攻擊你，造成 %d 傷害" % [enemy_data.name, damage])
	
	check_battle_end()
	if in_battle:
		battle_turn = "player"
		update_battle_display()

func check_battle_end():
	if enemy_data.hp <= 0:
		add_battle_log("你獲勝了！")
		# 使用敵人數據中的獎勵，如果沒有則使用默認值
		var exp_gain = enemy_data.get("exp_reward", 50)
		var money_gain = enemy_data.get("money_reward", 100)
		player_data.exp += exp_gain
		player_data.money += money_gain
		add_battle_log("獲得 %d 經驗，%d 銀兩" % [exp_gain, money_gain])
		
		if player_data.exp >= player_data.level * 100:
			level_up()
		
		await get_tree().create_timer(2.0).timeout
		
		# 檢查戰鬥後是否還有後續事件
		if event_manager.current_event and event_manager.has_next_step():
			# 有後續事件，繼續顯示
			event_manager.next_step()
			advance_day()
			show_event()
		else:
			# 沒有後續事件，正常結束
			event_state_machine.complete_event()
			advance_day()
			# 根據觸發來源返回相應模式
			if event_triggered_from_location:
				return_to_location_mode()
			else:
				show_training_mode()
			
	elif player_data.hp <= 0:
		add_battle_log("你被擊敗了...")
		player_data.hp = 0
		
		# 戰敗也結束事件
		event_state_machine.complete_event()
		await get_tree().create_timer(2.0).timeout
		advance_day()
		# 根據觸發來源返回相應模式
		if event_triggered_from_location:
			return_to_location_mode()
		else:
			show_training_mode()

func level_up():
	player_data.level += 1
	player_data.max_hp += 20
	player_data.hp = player_data.max_hp
	player_data.attack += 3
	player_data.defense += 2
	add_battle_log("升級了！等級提升至 %d" % player_data.level)

func update_stats_display():
	stats_label.text = """
	%s Lv.%d (經驗: %d/%d)
	生命: %d/%d
	攻擊: %d | 防禦: %d | 速度: %d
	銀兩: %d | 聲望: %d
	修煉點數: %d
	""" % [
		player_data.name, player_data.level,
		player_data.exp, player_data.level * 100,
		player_data.hp, player_data.max_hp,
		player_data.attack, player_data.defense, player_data.speed,
		player_data.money, player_data.reputation,
		player_data.training_points
	]

func update_battle_display():
	var enemy_mp_text = ""
	if enemy_data.has("mp") and enemy_data.has("max_mp"):
		enemy_mp_text = " | MP: %d/%d" % [enemy_data.mp, enemy_data.max_mp]
	
	var battle_info = """
	=== 戰鬥中 ===
	【我方】%s 
	  HP: %d/%d | MP: %d/%d
	【敵方】%s 
	  HP: %d/%d%s
	
	當前回合: %s
	
	--- 戰鬥記錄 ---
	%s
	""" % [
		player_data.name, 
		player_data.hp, player_data.max_hp,
		player_data.mp, player_data.max_mp,
		enemy_data.name, 
		enemy_data.hp, enemy_data.max_hp,
		enemy_mp_text,
		"玩家" if battle_turn == "player" else "敵人",
		"\n".join(battle_log.slice(-6))
	]
	$UI/BattlePanel/BattleInfo.text = battle_info

func add_battle_log(text: String):
	battle_log.append(text)
	update_battle_display()


# ============================================
# 如何創建新事件（.tres 文件範例）
# ============================================
# 在 Godot 編輯器中:
# 1. 創建 res://events/ 資料夾
# 2. 右鍵 -> 新建資源 -> EventData
# 3. 設置事件屬性
# 4. 保存為 .tres 文件
#
# 或在代碼中創建並導出:
# var new_event = EventData.new()
# new_event.event_id = "test_event"
# new_event.title = "測試事件"
# ResourceSaver.save(new_event, "res://events/test_event.tres")


# ============================================
# 場景樹結構
# ============================================
# Main (Node2D)
# └── UI (CanvasLayer)
#     ├── ModeLabel (Label)
#     ├── StatsLabel (Label)
#     ├── TrainingPanel (Panel)
#     │   ├── TrainAttackBtn (Button)
#     │   ├── TrainDefenseBtn (Button)
#     │   ├── TrainHPBtn (Button)
#     │   ├── RestBtn (Button)
#     │   ├── TriggerEventBtn (Button)
#     │   ├── StartBattleBtn (Button)
#     │   └── SaveGameBtn (Button)
#     ├── EventPanel (Panel)
#     │   ├── EventText (Label)
#     │   └── ChoicesContainer (VBoxContainer)
#     └── BattlePanel (Panel)
#         ├── BattleInfo (Label)
#         └── SkillsContainer (HBoxContainer) [新增：技能按鈕容器]
