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
	"attack": 15,
	"defense": 10,
	"speed": 12,
	"money": 100,
	"reputation": 0,
	"skills": ["普通攻擊", "連擊"],
	"training_points": 10
}

var days_passed = 0

@onready var mode_label = $UI/ModeLabel
@onready var training_panel = $UI/TrainingPanel
@onready var battle_panel = $UI/BattlePanel
@onready var event_panel = $UI/EventPanel
@onready var stats_label = $UI/StatsLabel

var in_battle = false
var enemy_data = {}
var battle_turn = "player"
var battle_log = []

# 新系統
var event_manager: EventManager
var event_state_machine: EventStateMachine
var save_manager: SaveManager

func _ready():
	# 初始化系統
	event_manager = EventManager.new(self)
	event_manager.load_events_from_directory()
	
	event_state_machine = EventStateMachine.new(self, event_manager)
	event_state_machine.result_ready.connect(_on_event_result_ready)
	event_state_machine.state_changed.connect(_on_event_state_changed)
	
	event_manager.battle_triggered.connect(_on_battle_triggered)
	
	save_manager = SaveManager.new()
	
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
	stats_label.visible = true
	mode_label.text = "養成模式 - 第 %d 天" % days_passed
	training_panel.visible = true
	battle_panel.visible = false
	event_panel.visible = false
	update_stats_display()

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
	var event = event_manager.trigger_random_event()
	if event:
		show_event()

func _on_save_game_pressed():
	if save_manager.save_game(player_data, event_manager.event_history, days_passed):
		mode_label.text = "遊戲已保存！"

func advance_day():
	days_passed += 1
	mode_label.text = "養成模式 - 第 %d 天" % days_passed
	update_stats_display()
	# 自動保存
	save_manager.save_game(player_data, event_manager.event_history, days_passed)

# === 事件系統 UI ===
func show_event():
	var step = event_manager.get_current_step()
	if not step:
		return
	
	mode_label.text = "事件：" + event_manager.current_event.title
	training_panel.visible = false
	battle_panel.visible = false
	event_panel.visible = true
	
	$UI/EventPanel/EventText.text = step.text
	
	# 清除舊按鈕
	for child in $UI/EventPanel/ChoicesContainer.get_children():
		child.queue_free()
	
	# 創建選項按鈕
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
			event_state_machine.complete_event()
			advance_day()
			show_training_mode()
		)
		$UI/EventPanel/ChoicesContainer.add_child(continue_btn)
	
	update_stats_display()

func _on_event_state_changed(new_state: int):
	pass  # 可用於 Debug 或顯示狀態

func _on_battle_triggered(battle_params: Dictionary):
	# 等待玩家看到結果文字
	await get_tree().create_timer(2.0).timeout
	start_battle(
		battle_params.get("name", "敵人"),
		battle_params.get("hp", 80),
		battle_params.get("attack", 12),
		battle_params.get("defense", 8),
		battle_params.get("speed", 10)
	)

# === 戰鬥系統（保持原樣）===
func _on_start_battle_pressed():
	start_battle("山賊", 80, 12, 8, 10)

func start_battle(enemy_name: String, hp: int, atk: int, def: int, spd: int):
	in_battle = true
	stats_label.visible = false
	enemy_data = {
		"name": enemy_name,
		"hp": hp,
		"max_hp": hp,
		"attack": atk,
		"defense": def,
		"speed": spd
	}
	
	battle_log.clear()
	battle_turn = "player" if player_data.speed >= enemy_data.speed else "enemy"
	
	mode_label.text = "戰鬥模式"
	training_panel.visible = false
	event_panel.visible = false
	battle_panel.visible = true
	
	add_battle_log("遭遇 %s！" % enemy_data.name)
	update_battle_display()
	
	if battle_turn == "enemy":
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

func _on_attack_pressed():
	if battle_turn != "player" or not in_battle:
		return
	
	var damage = max(1, player_data.attack - enemy_data.defense)
	enemy_data.hp -= damage
	add_battle_log("你攻擊 %s，造成 %d 傷害" % [enemy_data.name, damage])
	
	if in_battle:
		battle_turn = "enemy"
		update_battle_display()
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

func _on_combo_pressed():
	if battle_turn != "player" or not in_battle:
		return
	
	var damage1 = max(1, int(player_data.attack * 0.7) - enemy_data.defense)
	var damage2 = max(1, int(player_data.attack * 0.7) - enemy_data.defense)
	enemy_data.hp -= damage1 + damage2
	add_battle_log("你使用連擊，造成 %d + %d 傷害" % [damage1, damage2])
	
	if in_battle:
		battle_turn = "enemy"
		update_battle_display()
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

func _on_defend_pressed():
	if battle_turn != "player" or not in_battle:
		return
	
	add_battle_log("你擺出防禦姿態")
	player_data.defense += 5
	
	battle_turn = "enemy"
	update_battle_display()
	await get_tree().create_timer(1.0).timeout
	enemy_turn()
	player_data.defense -= 5

func enemy_turn():
	if not in_battle:
		return
	
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
		var exp_gain = 50
		var money_gain = 100
		player_data.exp += exp_gain
		player_data.money += money_gain
		add_battle_log("獲得 %d 經驗，%d 銀兩" % [exp_gain, money_gain])
		
		if player_data.exp >= player_data.level * 100:
			level_up()
		
		event_state_machine.complete_event()
		await get_tree().create_timer(2.0).timeout
		advance_day()
		show_training_mode()
	elif player_data.hp <= 0:
		add_battle_log("你被擊敗了...")
		player_data.hp = int(player_data.max_hp / 2)
		player_data.money = max(0, player_data.money - 20)
		
		event_state_machine.complete_event()
		await get_tree().create_timer(2.0).timeout
		advance_day()
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
	var battle_info = """
	=== 戰鬥中 ===
	【我方】%s HP: %d/%d
	【敵方】%s HP: %d/%d
	
	當前回合: %s
	
	--- 戰鬥記錄 ---
	%s
	""" % [
		player_data.name, player_data.hp, player_data.max_hp,
		enemy_data.name, enemy_data.hp, enemy_data.max_hp,
		"玩家" if battle_turn == "player" else "敵人",
		"\n".join(battle_log.slice(-5))
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
#     │   └── SaveGameBtn (Button) [新增]
#     ├── EventPanel (Panel)
#     │   ├── EventText (Label)
#     │   └── ChoicesContainer (VBoxContainer)
#     └── BattlePanel (Panel)
#         ├── BattleInfo (Label)
#         ├── AttackBtn (Button)
#         ├── ComboBtn (Button)
#         └── DefendBtn (Button)
