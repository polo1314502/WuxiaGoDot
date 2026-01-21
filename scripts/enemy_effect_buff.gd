# enemy_effect_buff.gd - 敵人增益效果
class_name EnemyEffectBuff
extends SkillEffectAction

var attack_buff: int = 0
var defense_buff: int = 0
var speed_buff: int = 0
var duration: int = 0  # 持續回合數（暫未實現）

func setup(params: Dictionary):
	if params.has("attack_buff"):
		attack_buff = params.attack_buff
	if params.has("defense_buff"):
		defense_buff = params.defense_buff
	if params.has("speed_buff"):
		speed_buff = params.speed_buff
	if params.has("duration"):
		duration = params.duration

func can_execute() -> bool:
	return true

func execute():
	if attack_buff != 0:
		enemy_data.attack += attack_buff
		result_logs.append("攻擊力 %s %d" % ["增加" if attack_buff > 0 else "減少", abs(attack_buff)])
	
	if defense_buff != 0:
		enemy_data.defense += defense_buff
		result_logs.append("防禦力 %s %d" % ["增加" if defense_buff > 0 else "減少", abs(defense_buff)])
	
	if speed_buff != 0:
		enemy_data.speed += speed_buff
		result_logs.append("速度 %s %d" % ["增加" if speed_buff > 0 else "減少", abs(speed_buff)])
