# action_use_item.gd - 使用物品動作
class_name ActionUseItem
extends EventAction

var item_id: String = ""

func setup(params: Dictionary):
	if params.has("item_id"):
		item_id = params.item_id

func can_execute() -> bool:
	if item_id == "":
		return false
	var inventory = main_scene.inventory_manager
	return inventory.has_item(item_id)

func execute():
	var inventory = main_scene.inventory_manager
	var item = inventory.get_item(item_id)
	
	if item == null:
		result_text = "物品不存在！"
		return
	
	if not inventory.has_item(item_id):
		result_text = "你沒有 %s！" % item.item_name
		return
	
	if inventory.use_item(item_id):
		result_text = "使用了 %s" % item.item_name
	else:
		result_text = "無法使用 %s" % item.item_name
