# inventory_ui.gd - 物品庫存UI
extends Control

var main_scene  # 主場景引用
@onready var inventory_list = $Panel/VBox/ContentHBox/LeftPanel/ScrollContainer/ItemList
@onready var item_info = $Panel/VBox/ContentHBox/RightPanel/ItemInfo
@onready var equipped_info = $Panel/VBox/EquippedPanel/EquippedInfo
@onready var use_button = $Panel/VBox/HBox/UseButton
@onready var equip_button = $Panel/VBox/HBox/EquipButton
@onready var sell_button = $Panel/VBox/HBox/SellButton
@onready var close_button = $Panel/VBox/CloseButton

var selected_item_id: String = ""

func _ready():
	main_scene = get_node("/root/Main")
	
	close_button.pressed.connect(_on_close_pressed)
	use_button.pressed.connect(_on_use_pressed)
	equip_button.pressed.connect(_on_equip_pressed)
	sell_button.pressed.connect(_on_sell_pressed)
	inventory_list.item_selected.connect(_on_item_selected)
	
	# 連接庫存變化信號
	if main_scene and main_scene.inventory_manager:
		main_scene.inventory_manager.inventory_changed.connect(_on_inventory_changed)

func show_inventory():
	print("show_inventory 被調用")
	print("main_scene: ", main_scene)
	print("inventory_manager: ", main_scene.inventory_manager if main_scene else "main_scene為null")
	refresh_inventory_list()
	refresh_equipped_display()
	visible = true
	main_scene.training_panel.visible = false
	print("庫存UI visible 設置為: ", visible)

func refresh_inventory_list():
	if not main_scene or not main_scene.inventory_manager:
		return
	
	inventory_list.clear()
	selected_item_id = ""
	item_info.text = ""
	_update_button_states()
	
	var inventory = main_scene.inventory_manager.get_inventory_list()
	for entry in inventory:
		var item: ItemData = entry["item"]
		var quantity: int = entry["quantity"]
		var display_text = "%s x%d" % [item.item_name, quantity]
		inventory_list.add_item(display_text)
		inventory_list.set_item_metadata(inventory_list.item_count - 1, item.item_id)

func _on_item_selected(index: int):
	selected_item_id = inventory_list.get_item_metadata(index)
	_update_item_info()
	_update_button_states()

func _update_item_info():
	if selected_item_id == "":
		item_info.text = ""
		return
	
	var item = main_scene.inventory_manager.get_item(selected_item_id)
	if item:
		item_info.text = item.get_tooltip_text()

func _update_button_states():
	if selected_item_id == "":
		use_button.disabled = true
		equip_button.disabled = true
		sell_button.disabled = true
		return
	
	var item = main_scene.inventory_manager.get_item(selected_item_id)
	if not item:
		use_button.disabled = true
		equip_button.disabled = true
		sell_button.disabled = true
		return
	
	# 根據物品類型啟用/禁用按鈕
	use_button.disabled = (item.item_type != "consumable")
	equip_button.disabled = (item.item_type != "equipment")
	sell_button.disabled = (item.sell_price <= 0)

func _on_use_pressed():
	if selected_item_id == "":
		return
	
	if main_scene.inventory_manager.use_item(selected_item_id):
		print("使用物品成功")
		refresh_inventory_list()
		main_scene.update_stats_display()

func _on_equip_pressed():
	if selected_item_id == "":
		return
	
	if main_scene.inventory_manager.equip_item(selected_item_id):
		print("裝備成功")
		main_scene.update_stats_display()
		refresh_equipped_display()
		_update_item_info()

func _on_sell_pressed():
	if selected_item_id == "":
		return
	
	if main_scene.inventory_manager.sell_item(selected_item_id, 1):
		print("出售成功")
		refresh_inventory_list()
		main_scene.update_stats_display()

func _on_close_pressed():
	main_scene.training_panel.visible = true
	visible = false

func _on_inventory_changed(_item_id: String, _quantity: int):
	refresh_inventory_list()

func refresh_equipped_display():
	if not main_scene or not main_scene.inventory_manager:
		return
	
	var weapon_item = main_scene.inventory_manager.get_equipped_item("weapon")
	var armor_item = main_scene.inventory_manager.get_equipped_item("armor")
	var accessory_item = main_scene.inventory_manager.get_equipped_item("accessory")
	
	var weapon_text = weapon_item.item_name if weapon_item else "無"
	var armor_text = armor_item.item_name if armor_item else "無"
	var accessory_text = accessory_item.item_name if accessory_item else "無"
	
	equipped_info.text = "武器：%s | 防具：%s | 飾品：%s" % [weapon_text, armor_text, accessory_text]
