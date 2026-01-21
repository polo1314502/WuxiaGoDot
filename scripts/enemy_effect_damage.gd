# enemy_effect_damage.gd - 敵人傷害效果（對玩家造成傷害）
class_name EnemyEffectDamage
extends SkillEffectAction

var ignore_defense_percent: int = 0

func setup(params: Dictionary):
	if params.has("ignore_defense_percent"):
		ignore_defense_percent = params.ignore_defense_percent

func can_execute() -> bool:
	return player_data.hp > 0

func execute():
	var player_def = player_data.defense
	
	# 忽視防禦
	if ignore_defense_percent > 0:
		player_def = int(player_def * (100 - ignore_defense_percent) / 100.0)
	
	# 計算每次攻擊
	for i in range(skill_data.hits):
		var base_damage = enemy_data.attack
		var damage = max(1, int(base_damage * skill_data.damage_multiplier) - player_def)
		
		player_data.hp -= damage
		total_damage += damage
		
		if skill_data.hits > 1:
			result_logs.append("對 %s 造成 %d 傷害（第 %d 擊）" % [player_data.name, damage, i + 1])
		else:
			result_logs.append("對 %s 造成 %d 傷害" % [player_data.name, damage])
