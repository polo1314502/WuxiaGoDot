# 場景系統 UI 設置指南

## 需要在 main.tscn 中添加的節點

### 1. LocationPanel 面板

在 `UI` 節點下添加以下結構：

```
UI/
  LocationPanel (Panel)
    VBoxContainer
      LocationText (RichTextLabel)
        - custom_minimum_size: (600, 200)
        - bbcode_enabled: true
        - fit_content: true
      
      LocationList (VBoxContainer)
        - custom_minimum_size: (600, 300)
        - alignment: Begin
      
      BackButton (Button)
        - text: "返回"
        - visible: false  # 由代碼控制
```

### 2. TrainingPanel 添加探索按鈕

在 `TrainingPanel` 中添加：

```
TrainingPanel/
  VBoxContainer/
    ... (existing buttons)
    ExploreButton (Button)
      - text: "探索場景"
      - pressed signal -> _on_explore_locations_pressed()
```

### 3. 在 main.gd 中添加節點引用

```gdscript
@onready var location_panel = $UI/LocationPanel
```

### 4. 修改 show_training_mode()

```gdscript
func show_training_mode():
	in_battle = false
	if player_data.hp == 0:
		player_data.hp = 1
	stats_label.visible = true
	mode_label.text = "養成模式 - 第 %d 天" % days_passed
	training_panel.visible = true
	battle_panel.visible = false
	event_panel.visible = false
	location_panel.visible = false  # 添加這一行
	update_stats_display()
```

## 快速測試步驟

1. 在 Godot 編輯器中打開 `main.tscn`
2. 添加上述 UI 節點
3. 運行遊戲
4. 點擊"探索場景"按鈕
5. 選擇"洛陽" → "客棧" → "飲酒暢談"
6. 體驗完整的事件序列

## 可選：使用腳本快速創建 UI

如果你想用代碼動態創建 LocationPanel：

```gdscript
func _ready():
	# ... 其他初始化代碼
	
	# 創建 LocationPanel
	if not has_node("UI/LocationPanel"):
		create_location_panel()

func create_location_panel():
	var panel = Panel.new()
	panel.name = "LocationPanel"
	panel.visible = false
	panel.custom_minimum_size = Vector2(700, 500)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.offset_left = -350
	panel.offset_top = -250
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var location_text = RichTextLabel.new()
	location_text.name = "LocationText"
	location_text.custom_minimum_size = Vector2(600, 200)
	location_text.bbcode_enabled = true
	vbox.add_child(location_text)
	
	var location_list = VBoxContainer.new()
	location_list.name = "LocationList"
	location_list.custom_minimum_size = Vector2(600, 300)
	vbox.add_child(location_list)
	
	$UI.add_child(panel)
```

## 注意事項

- `LocationPanel` 需要在 `show_training_mode()` 和其他顯示函數中設置 `visible = false`
- 按鈕會由代碼動態生成，不需要預先創建
- 確保 `location_manager` 在 `_ready()` 中正確初始化
- 所有 `.tres` 資源文件需要在 Godot 中正確載入

## 測試事件序列

完整的"飲酒暢談"事件序列流程：

1. 進入客棧
2. 選擇"飲酒暢談"（消耗15文）
3. 事件1：開始飲酒（自動繼續）
4. 事件2：醉漢登場（自動繼續）
5. 事件3：選擇應對
   - 選項A：出手教訓他 → 觸發戰鬥
   - 選項B：扶他回房 → 獲得聲望+5，進入第二步，獲得攻擊+2和聲望+3
   - 選項C：悄悄離開 → 事件結束
6. 返回訓練模式，進入下一天

如果選擇"扶他回房"，玩家總共獲得：攻擊+2，聲望+8！
