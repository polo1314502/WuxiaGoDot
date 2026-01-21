# enemy_effect_heal.gd - 敵人治療效果
class_name EnemyEffectHeal
extends SkillEffectAction

var heal_amount: int = 0
var heal_percent: int = 0
var lifesteal_percent: int = 0  # 吸血百分比

func setup(params: Dictionary):
	if params.has("heal_amount"):
		heal_amount = params.heal_amount
	if params.has("heal_percent"):
		heal_percent = params.heal_percent
	if params.has("lifesteal_percent"):
		lifesteal_percent = params.lifesteal_percent

func can_execute() -> bool:
	return enemy_data.hp > 0

func execute():
	var total_heal = heal_amount
	
	# 百分比治療
	if heal_percent > 0:
		total_heal += int(enemy_data.max_hp * heal_percent / 100.0)
	
	# 實際治療
	if total_heal > 0:
		var before_hp = enemy_data.hp
		enemy_data.hp = min(enemy_data.max_hp, enemy_data.hp + total_heal)
		var actual_heal = enemy_data.hp - before_hp
		
		result_logs.append("回復了 %d 生命" % actual_heal)
	
	# 注意：吸血效果在 EnemySkillExecutor 中處理
