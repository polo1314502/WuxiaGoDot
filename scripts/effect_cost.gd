# effect_cost.gd - 消耗效果
class_name EffectCost
extends SkillEffectAction

var hp_cost_percent: int = 0
var hp_cost_fixed: int = 0

func setup(params: Dictionary):
	if params.has("hp_cost_percent"):
		hp_cost_percent = params.hp_cost_percent
	if params.has("hp_cost_fixed"):
		hp_cost_fixed = params.hp_cost_fixed

func can_execute() -> bool:
	var cost = 0
	if hp_cost_percent > 0:
		cost = int(player_data.max_hp * hp_cost_percent / 100.0)
	elif hp_cost_fixed > 0:
		cost = hp_cost_fixed
	
	return player_data.hp > cost

func execute():
	var cost = 0
	if hp_cost_percent > 0:
		cost = int(player_data.max_hp * hp_cost_percent / 100.0)
	elif hp_cost_fixed > 0:
		cost = hp_cost_fixed
	
	if cost > 0:
		player_data.hp -= cost
		result_logs.append("消耗 %d 生命" % cost)
