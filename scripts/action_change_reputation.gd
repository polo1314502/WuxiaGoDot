# action_change_reputation.gd - 改變聲望動作
class_name ActionChangeReputation
extends EventAction

var amount: int = 0
var custom_message: String = ""

func setup(params: Dictionary):
	if params.has("amount"):
		amount = params.amount
	if params.has("message"):
		custom_message = params.message

func execute():
	player_data.reputation += amount
	
	if custom_message:
		result_text = custom_message
	else:
		result_text = "聲望 %s%d" % ["+" if amount >= 0 else "", amount]
