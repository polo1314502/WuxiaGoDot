# action_trigger_battle.gd - 觸發戰鬥動作
class_name ActionTriggerBattle
extends EventAction

var enemy_data_resource: EnemyData = null  # 敵人資源
var enemy_name: String = "敵人"
var enemy_hp: int = 80
var enemy_attack: int = 12
var enemy_defense: int = 8
var enemy_speed: int = 10
var enemy_skills: Array = []  # 新增：敵人技能列表
var pre_message: String = ""
var on_victory_event_id: String = ""  # 戰勝後觸發的事件ID
var on_defeat_event_id: String = ""   # 戰敗後觸發的事件ID

func setup(params: Dictionary):
	# 優先使用 EnemyData 資源
	if params.has("enemy_data") and params.enemy_data is EnemyData:
		enemy_data_resource = params.enemy_data
		pre_message = params.get("message", "遭遇 %s！" % enemy_data_resource.name)
	else:
		# 使用舊方式的參數
		if params.has("enemy_name"): enemy_name = params.enemy_name
		if params.has("enemy_hp"): enemy_hp = params.enemy_hp
		if params.has("enemy_attack"): enemy_attack = params.enemy_attack
		if params.has("enemy_defense"): enemy_defense = params.enemy_defense
		if params.has("enemy_speed"): enemy_speed = params.enemy_speed
		if params.has("enemy_skills"): enemy_skills = params.enemy_skills  # 新增
		if params.has("message"): pre_message = params.message
	
	# 讀取戰鬥後續事件ID
	if params.has("on_victory_event_id"): on_victory_event_id = params.on_victory_event_id
	if params.has("on_defeat_event_id"): on_defeat_event_id = params.on_defeat_event_id

func execute():
	triggers_battle = true
	
	if enemy_data_resource:
		# 使用 EnemyData 資源
		battle_params = {
			"enemy_data": enemy_data_resource,
			"on_victory_event_id": on_victory_event_id,
			"on_defeat_event_id": on_defeat_event_id
		}
	else:
		# 使用舊方式
		battle_params = {
			"name": enemy_name,
			"hp": enemy_hp,
			"attack": enemy_attack,
			"defense": enemy_defense,
			"speed": enemy_speed,
			"skills": enemy_skills,  # 新增
			"on_victory_event_id": on_victory_event_id,
			"on_defeat_event_id": on_defeat_event_id
		}
	
	result_text = pre_message
