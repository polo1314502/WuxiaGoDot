# item_data.gd - 物品資源數據
class_name ItemData
extends Resource

@export var item_id: String = ""  # 物品唯一ID
@export var item_name: String = ""  # 物品名稱
@export var description: String = ""  # 物品描述
@export_enum("consumable", "equipment", "quest", "material") var item_type: String = "consumable"  # 物品類型
@export var price: int = 0  # 購買價格
@export var sell_price: int = 0  # 出售價格
@export var max_stack: int = 99  # 最大堆疊數量
@export var icon_path: String = ""  # 圖標路徑

# 消耗品效果
@export var consumable_effects: Dictionary = {
	# 例如：{"hp": 50, "mp": 30}  恢復HP和MP
}

# 裝備屬性加成
@export_enum("weapon", "armor", "accessory", "none") var equipment_slot: String = "none"  # 裝備欄位
@export var equipment_stats: Dictionary = {
	# 例如：{"attack": 10, "defense": 5}
}

# 是否可使用
@export var usable: bool = true  # 是否可以使用
@export var use_in_battle: bool = false  # 是否可在戰鬥中使用

func _init(id: String = "", name: String = ""):
	item_id = id
	item_name = name
	if sell_price == 0 and price > 0:
		sell_price = price / 2  # 默認出售價格為購買價格的一半

func get_display_name() -> String:
	return item_name if item_name != "" else item_id

func get_tooltip_text() -> String:
	var tooltip = "[b]%s[/b]\n" % get_display_name()
	tooltip += description + "\n"
	
	match item_type:
		"consumable":
			tooltip += "\n[color=green]消耗品[/color]\n"
			if not consumable_effects.is_empty():
				for key in consumable_effects:
					var value = consumable_effects[key]
					var display_name = _get_stat_display_name(key)
					if value > 0:
						tooltip += "  %s +%d\n" % [display_name, value]
					else:
						tooltip += "  %s %d\n" % [display_name, value]
		"equipment":
			tooltip += "\n[color=yellow]裝備[/color] (%s)\n" % _get_slot_display_name(equipment_slot)
			if not equipment_stats.is_empty():
				for key in equipment_stats:
					var value = equipment_stats[key]
					var display_name = _get_stat_display_name(key)
					if value > 0:
						tooltip += "  %s +%d\n" % [display_name, value]
					else:
						tooltip += "  %s %d\n" % [display_name, value]
		"quest":
			tooltip += "\n[color=cyan]任務物品[/color]\n"
		"material":
			tooltip += "\n[color=gray]材料[/color]\n"
	
	tooltip += "\n價格: %d 銀兩" % price
	if sell_price > 0:
		tooltip += " (出售: %d)" % sell_price
	
	return tooltip

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

func _get_slot_display_name(slot: String) -> String:
	match slot:
		"weapon": return "武器"
		"armor": return "防具"
		"accessory": return "飾品"
		_: return slot
