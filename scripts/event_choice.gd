# event_choice.gd - 事件選項資源類（必須先定義）
class_name EventChoice
extends Resource

@export var text: String = ""
@export_enum("change_stats", "trigger_battle", "buy_item", "learn_skill") var action_type: String = ""
@export var action_params: Dictionary = {
	"attack": 0,
	"defense": 0,
	"max_hp": 0,
	"speed": 0,
	"money" : 0,
	"reputation": 0,
	"training_points": 0,
	"skill_id": "",
	"skill_name": "",
	"message": ""
}
@export var enemy_data: EnemyData  # 直接使用 EnemyData 資源（包含技能列表）
@export var end_event: bool = false  # 新增：選擇後是否立即結束事件

# 戰鬥後續事件（新增）
@export var on_victory_event_id: String = ""  # 戰勝後觸發的事件ID
@export var on_defeat_event_id: String = ""   # 戰敗後觸發的事件ID

# 顯示條件（新增）
@export var display_conditions: Array[EventCondition] = []  # 顯示此選項需要滿足的條件

# 檢查此選項是否應該顯示
func should_display(main_scene) -> bool:
	# 如果沒有條件，則總是顯示
	if display_conditions.is_empty():
		return true
	
	# 所有條件都必須滿足
	for condition in display_conditions:
		if not condition.check(main_scene):
			return false
	
	return true
