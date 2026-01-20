class_name ActionChangeStats
extends EventAction

var attack: int = 0
var defense: int = 0
var max_hp: int = 0
var speed: int = 0
var money: int = 0
var reputation: int = 0
var training_points: int = 0
var message: String = ""

func setup(params: Dictionary):
	if params.has("attack"): attack = params.attack
	if params.has("defense"): defense = params.defense
	if params.has("max_hp"): max_hp = params.max_hp
	if params.has("speed"): speed = params.speed
	if params.has("money"): money = params.money
	if params.has("reputation"): reputation = params.reputation
	if params.has("training_points"): training_points = params.training_points
	if params.has("message"): message = params.message
	
func can_execute() -> bool:
	if money < 0 :
		return player_data.money >= -(money)
	else:
		return true

func execute():
	player_data.attack += attack
	player_data.defense += defense
	player_data.max_hp += max_hp
	player_data.hp += max_hp
	player_data.speed += speed
	player_data.money += money
	player_data.reputation += reputation
	player_data.training_points += training_points
	
	var gains = []
	if attack > 0: gains.append("攻擊 +%d" % attack)
	if defense > 0: gains.append("防禦 +%d" % defense)
	if max_hp > 0: gains.append("最大生命 +%d" % max_hp)
	if speed > 0: gains.append("速度 +%d" % speed)
	if money > 0: gains.append("金錢 +%d" % money)
	if reputation > 0: gains.append("聲望 +%d" % reputation)
	if training_points > 0: gains.append("修練點數 +%d" % training_points)
	
	if attack < 0: gains.append("攻擊 %d" % attack)
	if defense < 0: gains.append("防禦 %d" % defense)
	if max_hp < 0: gains.append("最大生命 %d" % max_hp)
	if speed < 0: gains.append("速度 %d" % speed)
	if money < 0: gains.append("金錢 %d" % money)
	if reputation < 0: gains.append("聲望 %d" % reputation)
	if training_points < 0: gains.append("修練點數 %d" % training_points)
	
	result_text = message + "\n" + ", ".join(gains) if message else ", ".join(gains)
