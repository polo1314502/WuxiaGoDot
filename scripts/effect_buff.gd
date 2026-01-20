# effect_buff.gd - 增益效果
class_name EffectBuff
extends SkillEffectAction

var attack_buff: int = 0
var defense_buff: int = 0
var speed_buff: int = 0
var buff_duration: int = 0

func setup(params: Dictionary):
	if params.has("attack_buff"):
		attack_buff = params.attack_buff
	if params.has("defense_buff"):
		defense_buff = params.defense_buff
	if params.has("speed_buff"):
		speed_buff = params.speed_buff
	if params.has("buff_duration"):
		buff_duration = params.buff_duration

func execute():
	if attack_buff > 0:
		player_data.attack += attack_buff
		result_logs.append("攻擊提升 %d" % attack_buff)
	
	if defense_buff > 0:
		player_data.defense += defense_buff
		result_logs.append("防禦提升 %d" % defense_buff)
	
	if speed_buff > 0:
		player_data.speed += speed_buff
		result_logs.append("速度提升 %d" % speed_buff)
