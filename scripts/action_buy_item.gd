# action_buy_item.gd - 購買物品動作（使用物品系統）
class_name ActionBuyItem
extends EventAction

var item_id: String = ""  # 物品ID
var quantity: int = 1  # 購買數量
var cost: int = 0  # 自定義價格（如果不設置則使用物品默認價格）
var item_stats: Dictionary = {}  # 舊版本相容：直接修改屬性
var success_message: String = "購買成功！"
var use_inventory_system: bool = true  # 是否使用物品系統

func setup(params: Dictionary):
	# 新系統參數
	if params.has("item_id"):
		item_id = params.item_id
		use_inventory_system = true
	if params.has("quantity"):
		quantity = params.quantity
	
	# 舊系統參數（向後兼容）
	if params.has("cost"):
		cost = params.cost
	if params.has("stats"):
		item_stats = params.stats
		if item_id == "":
			use_inventory_system = false  # 如果沒有item_id，使用舊系統
	if params.has("message"):
		success_message = params.message

func can_execute() -> bool:
	if use_inventory_system and item_id != "":
		var inventory = main_scene.inventory_manager
		var item = inventory.get_item(item_id)
		if item == null:
			return false
		var actual_cost = cost if cost > 0 else (item.price * quantity)
		return player_data.money >= actual_cost
	else:
		# 舊系統
		return player_data.money >= cost

func execute():
	if use_inventory_system and item_id != "":
		# 使用新的物品系統
		var inventory = main_scene.inventory_manager
		var item = inventory.get_item(item_id)
		if item == null:
			result_text = "物品不存在！"
			return
		
		var actual_cost = cost if cost > 0 else (item.price * quantity)
		
		# 檢查金錢
		if player_data.money < actual_cost:
			result_text = "銀兩不足！"
			return
		
		# 購買物品
		if inventory.add_item(item_id, quantity):
			player_data.money -= actual_cost
			result_text = "購買 %s x%d 成功！\n花費 %d 銀兩" % [item.item_name, quantity, actual_cost]
		else:
			result_text = "購買失敗！（可能已達堆疊上限）"
	else:
		# 舊系統（向後兼容）
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
		"mp": return "內力"
		"money": return "銀兩"
		"reputation": return "聲望"
		_: return key
