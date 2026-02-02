# inventory_manager.gd - 物品庫存管理器
class_name InventoryManager
extends Node

signal inventory_changed(item_id: String, quantity: int)
signal item_used(item_id: String)
signal item_equipped(item_id: String, slot: String)
signal item_unequipped(slot: String)

var main_scene  # 主場景引用
var items: Dictionary = {}  # 所有物品數據 {item_id: ItemData}
var inventory: Dictionary = {}  # 玩家庫存 {item_id: quantity}
var equipped: Dictionary = {  # 已裝備物品 {slot: item_id}
	"weapon": "",
	"armor": "",
	"accessory": ""
}

func _init(main_ref):
	main_scene = main_ref

# 載入所有物品數據
func load_items_from_directory(path: String = "res://items/"):
	var dir = DirAccess.open(path)
	if dir == null:
		print("物品目錄不存在：", path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var item_path = path + file_name
			var item = load(item_path) as ItemData
			if item and item.item_id != "":
				items[item.item_id] = item
				print("已載入物品：", item.item_name, " (", item.item_id, ")")
		file_name = dir.get_next()
	
	dir.list_dir_end()
	print("共載入 %d 個物品" % items.size())

# 根據ID獲取物品數據
func get_item(item_id: String) -> ItemData:
	if items.has(item_id):
		return items[item_id]
	return null

# 添加物品到庫存
func add_item(item_id: String, quantity: int = 1) -> bool:
	var item = get_item(item_id)
	if item == null:
		print("物品不存在：", item_id)
		return false
	
	if inventory.has(item_id):
		# 檢查是否超過堆疊上限
		var new_quantity = inventory[item_id] + quantity
		if new_quantity > item.max_stack:
			print("物品已達堆疊上限")
			return false
		inventory[item_id] = new_quantity
	else:
		inventory[item_id] = quantity
	
	inventory_changed.emit(item_id, inventory[item_id])
	return true

# 移除物品
func remove_item(item_id: String, quantity: int = 1) -> bool:
	if not inventory.has(item_id):
		return false
	
	inventory[item_id] -= quantity
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	
	inventory_changed.emit(item_id, inventory.get(item_id, 0))
	return true

# 檢查是否擁有物品
func has_item(item_id: String, quantity: int = 1) -> bool:
	return inventory.get(item_id, 0) >= quantity

# 獲取物品數量
func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)

# 使用物品
func use_item(item_id: String) -> bool:
	var item = get_item(item_id)
	if item == null or not has_item(item_id):
		return false
	
	if not item.usable:
		print("此物品無法使用")
		return false
	
	# 執行物品效果
	match item.item_type:
		"consumable":
			_apply_consumable_effects(item)
			remove_item(item_id, 1)
			item_used.emit(item_id)
			return true
		"equipment":
			# 裝備物品邏輯在 equip_item 中處理
			return false
		_:
			print("此類型物品無法使用")
			return false

# 應用消耗品效果
func _apply_consumable_effects(item: ItemData):
	var player_data = main_scene.player_data
	var effects_log = []
	
	for key in item.consumable_effects:
		var value = item.consumable_effects[key]
		if player_data.has(key):
			var old_value = player_data[key]
			player_data[key] += value
			
			# 限制HP和MP不超過最大值
			if key == "hp" and player_data.has("max_hp"):
				player_data[key] = min(player_data[key], player_data["max_hp"])
			elif key == "mp" and player_data.has("max_mp"):
				player_data[key] = min(player_data[key], player_data["max_mp"])
			
			var actual_change = player_data[key] - old_value
			var display_name = _get_stat_display_name(key)
			if actual_change > 0:
				effects_log.append("%s +%d" % [display_name, actual_change])
			elif actual_change < 0:
				effects_log.append("%s %d" % [display_name, actual_change])
	
	if not effects_log.is_empty():
		print("使用 %s: %s" % [item.item_name, ", ".join(effects_log)])

# 裝備物品
func equip_item(item_id: String) -> bool:
	var item = get_item(item_id)
	if item == null or not has_item(item_id):
		return false
	
	if item.item_type != "equipment":
		print("此物品無法裝備")
		return false
	
	var slot = item.equipment_slot
	if slot == "none":
		return false
	
	# 如果該欄位已有裝備，先卸下
	if equipped.has(slot) and equipped[slot] != "":
		unequip_item(slot)
	
	# 裝備新物品
	equipped[slot] = item_id
	_apply_equipment_stats(item, true)
	item_equipped.emit(item_id, slot)
	print("已裝備：", item.item_name)
	return true

# 卸下裝備
func unequip_item(slot: String) -> bool:
	if not equipped.has(slot) or equipped[slot] == "":
		return false
	
	var item_id = equipped[slot]
	var item = get_item(item_id)
	if item:
		_apply_equipment_stats(item, false)
	
	equipped[slot] = ""
	item_unequipped.emit(slot)
	print("已卸下裝備：", item.item_name if item else item_id)
	return true

# 應用/移除裝備屬性
func _apply_equipment_stats(item: ItemData, apply: bool):
	var player_data = main_scene.player_data
	var multiplier = 1 if apply else -1
	
	for key in item.equipment_stats:
		var value = item.equipment_stats[key] * multiplier
		if player_data.has(key):
			player_data[key] += value

# 獲取已裝備的物品
func get_equipped_item(slot: String) -> ItemData:
	if equipped.has(slot) and equipped[slot] != "":
		return get_item(equipped[slot])
	return null

# 獲取所有庫存物品列表（用於UI顯示）
func get_inventory_list() -> Array:
	var list = []
	for item_id in inventory.keys():
		var item = get_item(item_id)
		if item:
			list.append({
				"item": item,
				"quantity": inventory[item_id]
			})
	return list

# 出售物品
func sell_item(item_id: String, quantity: int = 1) -> bool:
	var item = get_item(item_id)
	if item == null or not has_item(item_id, quantity):
		return false
	
	var total_price = item.sell_price * quantity
	main_scene.player_data.money += total_price
	remove_item(item_id, quantity)
	print("出售 %s x%d，獲得 %d 銀兩" % [item.item_name, quantity, total_price])
	return true

# 購買物品
func buy_item(item_id: String, quantity: int = 1) -> bool:
	var item = get_item(item_id)
	if item == null:
		return false
	
	var total_price = item.price * quantity
	if main_scene.player_data.money < total_price:
		print("銀兩不足")
		return false
	
	if not add_item(item_id, quantity):
		return false
	
	main_scene.player_data.money -= total_price
	print("購買 %s x%d，花費 %d 銀兩" % [item.item_name, quantity, total_price])
	return true

func _get_stat_display_name(key: String) -> String:
	match key:
		"hp": return "生命"
		"mp": return "內力"
		"attack": return "攻擊"
		"defense": return "防禦"
		"speed": return "速度"
		"max_hp": return "最大生命"
		"max_mp": return "最大內力"
		"reputation": return "聲望"
		"exp": return "經驗"
		_: return key

# 保存庫存數據
func get_save_data() -> Dictionary:
	return {
		"inventory": inventory.duplicate(),
		"equipped": equipped.duplicate()
	}

# 載入庫存數據
func load_save_data(data: Dictionary):
	if data.has("inventory"):
		inventory = data["inventory"].duplicate()
	if data.has("equipped"):
		equipped = data["equipped"].duplicate()
		# 重新應用已裝備物品的屬性加成
		for slot in equipped.keys():
			if equipped[slot] != "":
				var item = get_item(equipped[slot])
				if item:
					_apply_equipment_stats(item, true)
