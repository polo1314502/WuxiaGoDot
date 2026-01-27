# ============================================
# 事件地點選擇模式腳本（獨立模式）
# ============================================

extends Panel

# 信號定義
signal location_selected(folder_name: String)
signal back_pressed()

# UI 節點引用
@onready var title_label = $VBoxContainer/TitleLabel
@onready var locations_container = $VBoxContainer/LocationsContainer
@onready var forest_btn = $VBoxContainer/LocationsContainer/ForestBtn
@onready var town_btn = $VBoxContainer/LocationsContainer/TownBtn
@onready var sect_btn = $VBoxContainer/LocationsContainer/SectBtn
@onready var lakeside_btn = $VBoxContainer/LocationsContainer/LakesideBtn
@onready var back_btn = $VBoxContainer/LocationsContainer/BackBtn

# 外部依賴（由Main傳入）
var main_node: Node = null

func _ready():
	# 連接按鈕信號
	forest_btn.pressed.connect(func(): _on_location_selected("forest"))
	town_btn.pressed.connect(func(): _on_location_selected("town"))
	sect_btn.pressed.connect(func(): _on_location_selected("sect"))
	lakeside_btn.pressed.connect(func(): _on_location_selected("lakeside"))
	back_btn.pressed.connect(_on_back_pressed)

func initialize(main_ref: Node):
	"""初始化事件地點選擇模式"""
	main_node = main_ref

func show_location_selection():
	"""顯示地點選擇UI"""
	title_label.text = "選擇探索地點"
	visible = true

func _on_location_selected(folder_name: String):
	"""處理地點選擇"""
	location_selected.emit(folder_name)

func _on_back_pressed():
	"""返回按鈕"""
	back_pressed.emit()
