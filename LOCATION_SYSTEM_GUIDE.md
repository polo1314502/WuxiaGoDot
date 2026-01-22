# LOCATION_SYSTEM_GUIDE.md
# 場景系統使用指南

## 概述

場景系統允許玩家在不同地點（如洛陽）中選擇不同場所（如茶館、客棧），並在每個場所執行不同動作，觸發事件或事件序列。

## 架構設計

### 三層結構

1. **LocationData（地點）** - 如"洛陽"
   - 包含多個子地點（SubLocation）
   - 可設置可用條件（如需要一定聲望才能進入）

2. **SubLocation（子地點）** - 如"茶館"、"客棧"
   - 包含多個動作（LocationAction）
   - 可設置可用條件

3. **LocationAction（動作）** - 如"打聽消息"、"租房休息"
   - 可觸發單個事件或事件序列
   - 可設置消耗（金錢、物品等）
   - 可設置冷卻時間和重複使用限制

### 類別說明

#### LocationData（地點資源）
```gdscript
class_name LocationData
extends Resource

@export var location_id: String = ""          # 唯一ID
@export var location_name: String = ""        # 地點名稱
@export var description: String = ""          # 描述
@export var available_conditions: Array[EventCondition] = []  # 可用條件
@export var sub_locations: Array[SubLocation] = []  # 子地點列表
@export var illustration_path: String = ""    # 圖片路徑（可選）
```

#### SubLocation（子地點資源）
```gdscript
class_name SubLocation
extends Resource

@export var sub_location_id: String = ""      # 唯一ID
@export var sub_location_name: String = ""    # 子地點名稱
@export var description: String = ""          # 描述
@export var available_conditions: Array[EventCondition] = []  # 可用條件
@export var actions: Array[LocationAction] = []  # 動作列表
@export var illustration_path: String = ""    # 圖片路徑（可選）
```

#### LocationAction（動作資源）
```gdscript
class_name LocationAction
extends Resource

@export var action_id: String = ""            # 唯一ID
@export var action_name: String = ""          # 動作名稱
@export var description: String = ""          # 描述
@export var available_conditions: Array[EventCondition] = []  # 可用條件
@export var trigger_event_id: String = ""     # 觸發的事件ID
@export var is_event_sequence: bool = false   # 是否為事件序列
@export var event_sequence: Array[String] = [] # 事件序列ID列表
@export var cost_money: int = 0               # 消耗金錢
@export var cost_items: Dictionary = {}       # 消耗物品
@export var repeatable: bool = true           # 是否可重複
@export var cooldown_days: int = 0            # 冷卻天數
```

## 創建示例場景

### 示例：洛陽城

#### 1. 創建地點資源

在 `locations/` 目錄下創建 `location_luoyang.tres`：

```
location_id: "luoyang"
location_name: "洛陽"
description: "中原繁華之地，武林高手雲集。"
sub_locations: [茶館資源, 客棧資源, 武館資源]
```

#### 2. 創建子地點資源

**茶館（locations/luoyang/sublocation_teahouse.tres）**：
```
sub_location_id: "teahouse"
sub_location_name: "茶館"
description: "人聲鼎沸的茶館，各種江湖消息在此流通。"
actions: [打聽消息, 與高手切磋, 聽說書]
```

**客棧（locations/luoyang/sublocation_inn.tres）**：
```
sub_location_id: "inn"
sub_location_name: "客棧"
description: "旅人休憩之所，常有江湖人士投宿。"
actions: [租房休息, 飲酒暢談, 打探敵情]
```

#### 3. 創建動作資源

**打聽消息（locations/luoyang/teahouse/action_gather_info.tres）**：
```
action_id: "gather_info"
action_name: "打聽消息"
description: "花點小錢向茶館老闆打聽江湖消息。"
cost_money: 10
trigger_event_id: "teahouse_rumor_event"
repeatable: true
cooldown_days: 3
```

**租房休息（locations/luoyang/inn/action_rent_room.tres）**：
```
action_id: "rent_room"
action_name: "租房休息"
description: "租一間客房好好休息。"
cost_money: 20
trigger_event_id: "inn_rest_event"
repeatable: true
```

**飲酒暢談（locations/luoyang/inn/action_drink.tres）**：
```
action_id: "drink_wine"
action_name: "飲酒暢談"
description: "與客棧中的江湖人士飲酒暢談，可能會觸發特殊事件。"
cost_money: 15
is_event_sequence: true
event_sequence: ["inn_drink_start", "inn_drunk_man", "inn_fight_or_help"]
repeatable: true
cooldown_days: 1
```

## 事件序列示例

### 客棧飲酒事件序列

這是一個三步事件序列，展示如何通過不同選擇影響後續事件：

#### 事件1：開始飲酒（inn_drink_start）
```gdscript
# events/inn/inn_drink_start.tres
event_id: "inn_drink_start"
title: "客棧飲酒"
steps: [
  EventStep {
    text: "你在客棧點了幾壺酒，開始與周圍的江湖人士閒聊。"
    choices: []  # 無選擇，自動繼續
  }
]
```

#### 事件2：醉漢登場（inn_drunk_man）
```gdscript
# events/inn/inn_drunk_man.tres
event_id: "inn_drunk_man"
title: "醉漢鬧事"
steps: [
  EventStep {
    text: "突然，一個醉漢闖進來，開始找人麻煩。他看起來武功不弱。"
    choices: []
  }
]
```

#### 事件3：選擇應對（inn_fight_or_help）
```gdscript
# events/inn/inn_fight_or_help.tres
event_id: "inn_fight_or_help"
title: "如何應對"
steps: [
  EventStep {
    text: "醉漢向你走來，你該如何應對？"
    choices: [
      EventChoice {
        choice_text: "出手教訓他"
        actions: [
          ActionTriggerBattle {
            battle_params: {enemy_id: "drunk_warrior"}
          }
        ]
      },
      EventChoice {
        choice_text: "扶他回房休息"
        actions: [
          ActionChangeStats {
            changes: {reputation: 5}
          }
        ],
        next_step: 1
      },
      EventChoice {
        choice_text: "悄悄離開"
        actions: []
      }
    ]
  },
  EventStep {
    text: "醉漢清醒後，感激你的幫助，贈送你一本武功秘籍。"
    choices: [
      EventChoice {
        choice_text: "收下秘籍"
        actions: [
          ActionLearnSkill {
            skill_id: "醉拳"
          }
        ]
      }
    ]
  }
]
```

## 條件系統集成

### 限制動作可用性

可以使用 `EventCondition` 來限制動作：

```gdscript
# 需要聲望 >= 50 才能使用的動作
action.available_conditions = [
  EventCondition {
    condition_type: STAT
    stat_name: "reputation"
    operator: GREATER_THAN_OR_EQUAL
    value: 50
  }
]

# 需要學會特定技能
action.available_conditions = [
  EventCondition {
    condition_type: HAS_SKILL
    skill_id: "輕功"
  }
]

# 需要完成特定事件
action.available_conditions = [
  EventCondition {
    condition_type: EVENT_COMPLETED
    event_id: "meet_master"
  }
]
```

## UI 集成

### 在 main.tscn 中添加 LocationPanel

需要在場景中添加以下節點結構：

```
UI/
  LocationPanel (Panel)
    LocationText (RichTextLabel) - 顯示地點/子地點描述
    LocationList (VBoxContainer) - 顯示按鈕列表
    BackButton (Button) - 返回按鈕（可選，由代碼動態生成）
```

### 在訓練面板添加按鈕

在 `TrainingPanel` 中添加一個"探索場景"按鈕：

```gdscript
# 在 main.tscn 的 TrainingPanel 中添加
ExploreButton (Button)
  text: "探索場景"
  pressed -> _on_explore_locations_pressed()
```

## 完整流程示例

### 玩家體驗流程

1. **訓練模式** → 點擊"探索場景"
2. **選擇地點** → 看到"洛陽"、"嵩山"等地點列表
3. **進入洛陽** → 看到"茶館"、"客棧"、"武館"
4. **進入客棧** → 看到"租房休息(20文)"、"飲酒暢談(15文)"、"打探敵情"
5. **選擇飲酒** → 觸發事件序列：
   - 事件1：開始飲酒（自動繼續）
   - 事件2：醉漢登場（自動繼續）
   - 事件3：選擇應對（三個選項）
6. **完成事件** → 返回訓練模式，進入下一天

### 代碼流程

```
玩家點擊"飲酒暢談"
  ↓
LocationManager.execute_action(action)
  → 檢查可用性（金錢、條件、冷卻）
  → 消耗金錢
  → 記錄使用歷史
  ↓
action.is_event_sequence == true
  ↓
LocationManager.start_event_sequence(["inn_drink_start", "inn_drunk_man", "inn_fight_or_help"])
  ↓
Main.start_event_sequence(event_ids)
  → 設置 event_sequence 和 event_sequence_index
  → 調用 trigger_next_event_in_sequence()
  ↓
觸發第一個事件
  ↓
事件完成後調用 on_event_sequence_step_completed()
  → event_sequence_index++
  → 觸發下一個事件
  ↓
序列結束 → 返回訓練模式
```

## 進階功能

### 動態生成子地點

可以根據遊戲進度動態添加子地點：

```gdscript
# 完成特定任務後，在洛陽添加"秘密武館"
var secret_dojo = SubLocation.new()
secret_dojo.sub_location_id = "secret_dojo"
secret_dojo.sub_location_name = "秘密武館"
secret_dojo.available_conditions = [
  EventCondition.create_event_completed("find_secret_dojo")
]

location_luoyang.sub_locations.append(secret_dojo)
```

### 時間敏感的動作

某些動作只在特定時間可用：

```gdscript
# 只在第20天後可用
action.available_conditions = [
  EventCondition {
    condition_type: DAY
    operator: GREATER_THAN_OR_EQUAL
    value: 20
  }
]
```

### 隨機事件池

一個動作可以從多個事件中隨機選擇：

```gdscript
# 在 LocationAction 中添加
@export var random_events: Array[String] = []

# 在 LocationManager.execute_action() 中
if not action.random_events.is_empty():
  var random_event_id = action.random_events[randi() % action.random_events.size()]
  trigger_event_by_id(random_event_id)
```

## 保存系統集成

需要在 `SaveManager` 中保存場景相關數據：

```gdscript
# save_manager.gd 中添加
func save_game(player_data, event_history, days_passed, location_history):
  var save_data = {
    "player_data": player_data,
    "event_history": event_history,
    "days_passed": days_passed,
    "location_history": location_history,  # 新增
    "action_history": main_scene.location_manager.action_history  # 新增
  }

func load_game():
  # 載入後恢復
  main_scene.location_manager.action_history = save_data.get("action_history", {})
```

## 測試檢查清單

- [ ] 能否正常進入和離開地點
- [ ] 子地點列表正確顯示
- [ ] 動作按鈕根據條件正確啟用/禁用
- [ ] 金錢消耗正確
- [ ] 單個事件觸發正常
- [ ] 事件序列按順序觸發
- [ ] 冷卻時間正確計算
- [ ] 不可重複動作只能使用一次
- [ ] 條件檢查正確（聲望、技能、事件完成等）
- [ ] 保存和載入後狀態正確

## 擴展建議

1. **物品系統集成**：動作可以消耗或獲得物品
2. **NPC系統**：特定NPC在特定地點，可以對話或交易
3. **時間系統**：某些地點只在特定時段開放（早、午、晚）
4. **天氣系統**：天氣影響某些動作的可用性
5. **聲望系統**：不同地點有不同派系聲望要求
6. **視覺升級**：為每個地點添加背景圖、場景切換動畫

## 常見問題

### Q: 如何讓事件序列中的某個事件根據條件跳過？

A: 在 `trigger_next_event_in_sequence()` 中添加條件檢查：
```gdscript
func trigger_next_event_in_sequence():
  if event_sequence_index >= event_sequence.size():
    # 序列結束
    return
  
  var event_id = event_sequence[event_sequence_index]
  var event = event_manager.get_event_by_id(event_id)
  
  # 檢查事件是否可觸發
  if event and event_manager.can_trigger_event(event):
    event_manager.trigger_event(event)
    show_event()
  else:
    # 跳過此事件
    event_sequence_index += 1
    trigger_next_event_in_sequence()
```

### Q: 如何讓動作直接改變玩家狀態而不觸發事件？

A: 添加 `direct_effects` 屬性：
```gdscript
# location_action.gd 中添加
@export var direct_effects: Dictionary = {}  # {stat_name: value}

# location_manager.gd execute_action() 中處理
for stat_name in action.direct_effects:
  main_scene.player_data[stat_name] += action.direct_effects[stat_name]
```

### Q: 如何實現"每天只能使用一次"的限制？

A: 設置 `cooldown_days = 1` 且 `repeatable = true`

## 總結

場景系統提供了靈活的地點導航和事件觸發機制，可以輕鬆創建複雜的場景互動。通過條件系統、事件序列和冷卻機制，可以設計出豐富的遊戲內容。
