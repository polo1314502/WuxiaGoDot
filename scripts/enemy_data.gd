# enemy_data.gd - 敵人資源類
class_name EnemyData
extends Resource

@export var enemy_id: String = ""
@export var name: String = "敵人"
@export var description: String = ""

# 基礎屬性
@export var max_hp: int = 100
@export var attack: int = 10
@export var defense: int = 5
@export var speed: int = 10

# 戰鬥相關
@export var skills: Array[SkillData] = []  # 敵人的技能列表
@export var exp_reward: int = 50  # 擊敗後獲得的經驗
@export var money_reward: int = 100  # 擊敗後獲得的銀兩

# 運行時數據（戰鬥中使用）
var current_hp: int = 0

func _init():
	current_hp = max_hp

# 創建戰鬥實例
func create_battle_instance() -> Dictionary:
	return {
		"name": name,
		"hp": max_hp,
		"max_hp": max_hp,
		"attack": attack,
		"defense": defense,
		"speed": speed,
		"skills": _get_skill_ids(),
		"exp_reward": exp_reward,
		"money_reward": money_reward
	}

# 獲取技能ID列表
func _get_skill_ids() -> Array:
	var skill_ids = []
	for skill in skills:
		if skill:
			skill_ids.append(skill.skill_id)
	return skill_ids
