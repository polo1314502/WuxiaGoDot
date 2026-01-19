class_name ActionGiveMoney
extends EventAction

var money: int = 10
var reputation_gain: int = 5

func setup(params: Dictionary):
	if params.has("money"):
		money = params.money
	if params.has("reputation"):
		reputation_gain = params.reputation

func can_execute() -> bool:
	return player_data.money >= money

func execute():
	player_data.money -= money
	player_data.reputation += reputation_gain
	result_text = "你給了%d兩銀子。\n聲望 +%d" % [money, reputation_gain]
