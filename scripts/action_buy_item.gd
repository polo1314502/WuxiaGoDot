# action_buy_item.gd - 購買物品動作
class_name ActionBuyItem
extends EventAction

var cost: int = 0
var item_stats: Dictionary = {}
var success_message: String = "購買成功！"

func setup(params: Dictionary):
	if params.has("cost"):
		cost = params.cost
	if params.has("stats"):
		item_stats = params.stats
	if params.has("message"):
		success_message = params.message

func can_execute() -> bool:
	return player_data.money >= cost

func execute():
	player_data.money -= cost
	
	var gains = []
	for key in item_stats:
		if player_data.has(key):
			player_data[key] += item_stats[key]
			# 友好的屬性名稱顯示
			var stat_name = _get_stat_display_name(key)
			gains.append("%s +%d" % [stat_name, item_stats[key]])
	
	result_text = success_message
	if not gains.is_empty():
		result_text += "\n" + ", ".join(gains)

func _get_stat_display_name(key: String) -> String:
	match key:
		"attack": return "攻擊"
		"defense": return "防禦"
		"max_hp": return "最大生命"
		"speed": return "速度"
		"hp": return "生命"
		"money": return "銀兩"
		"reputation": return "聲望"
		_: return key
