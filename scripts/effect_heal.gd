# effect_heal.gd - 治療效果
class_name EffectHeal
extends SkillEffectAction

var restore_hp: int = 0
var restore_mp: int = 0
var lifesteal_percent: int = 0

func setup(params: Dictionary):
	if params.has("restore_hp"):
		restore_hp = params.restore_hp
	if params.has("restore_mp"):
		restore_mp = params.restore_mp
	if params.has("lifesteal_percent"):
		lifesteal_percent = params.lifesteal_percent

func execute():
	if restore_hp > 0:
		var healed = min(restore_hp, player_data.max_hp - player_data.hp)
		player_data.hp += healed
		total_heal = healed
		result_logs.append("回復 %d 生命" % healed)
	
	if restore_mp > 0:
		var restored = min(restore_mp, player_data.max_mp - player_data.mp)
		player_data.mp += restored
		result_logs.append("回復 %d 內力" % restored)
	
	if lifesteal_percent > 0:
		# 需要先執行傷害效果才能吸血，這個在 SkillExecutor 中處理
		pass
