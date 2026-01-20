# effect_damage.gd - 傷害效果
class_name EffectDamage
extends SkillEffectAction

var ignore_defense_percent: int = 0
var fixed_damage: int = 0

func setup(params: Dictionary):
	if params.has("ignore_defense_percent"):
		ignore_defense_percent = params.ignore_defense_percent
	if params.has("fixed_damage"):
		fixed_damage = params.fixed_damage

func execute():
	if fixed_damage > 0:
		total_damage = fixed_damage
		enemy_data.hp -= total_damage
		result_logs.append("造成 %d 點固定傷害" % total_damage)
	elif skill_data.hits > 0:
		var base_damage = player_data.attack
		var enemy_def = enemy_data.defense
		
		if ignore_defense_percent > 0:
			enemy_def = int(enemy_def * (100 - ignore_defense_percent) / 100.0)
			result_logs.append("破甲 %d%%" % ignore_defense_percent)
		
		var hit_damages = []
		for i in range(skill_data.hits):
			var damage = max(1, int(base_damage * skill_data.damage_multiplier) - enemy_def)
			total_damage += damage
			enemy_data.hp -= damage
			hit_damages.append(damage)
		
		if skill_data.hits == 1:
			result_logs.append("造成 %d 傷害" % total_damage)
		else:
			result_logs.append("攻擊 %d 次，造成 %s 傷害（總計 %d）" % [
				skill_data.hits,
				" + ".join(hit_damages.map(func(d): return str(d))),
				total_damage
			])
