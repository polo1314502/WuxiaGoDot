# 場景系統快速參考

## 文件結構

```
scripts/
  location_data.gd          # 地點資源類
  sub_location.gd           # 子地點資源類
  location_action.gd        # 動作資源類
  location_manager.gd       # 場景管理器

locations/
  location_luoyang.tres     # 洛陽地點
  luoyang/
    sublocation_teahouse.tres    # 茶館子地點
    sublocation_inn.tres         # 客棧子地點
    teahouse/
      action_gather_info.tres    # 打聽消息動作
      action_duel.tres           # 切磋動作
    inn/
      action_rent_room.tres      # 租房動作
      action_drink.tres          # 飲酒動作

events/
  teahouse/
    teahouse_rumor_event.tres    # 江湖傳聞事件
    teahouse_duel_event.tres     # 茶館切磋事件
  inn/
    inn_rest_event.tres          # 休息事件
    inn_drink_start.tres         # 飲酒序列-1
    inn_drunk_man.tres           # 飲酒序列-2
    inn_fight_or_help.tres       # 飲酒序列-3
```

## 核心概念

### 1. 地點層級
```
地點（Location）
  └─ 子地點（SubLocation）
      └─ 動作（Action）
          └─ 事件/事件序列（Event/Sequence）
```

### 2. 事件序列
動作可以觸發：
- **單個事件**: `trigger_event_id = "event_id"`
- **事件序列**: `is_event_sequence = true`, `event_sequence = ["event1", "event2", "event3"]`

### 3. 動作屬性
- `cost_money`: 消耗金錢
- `repeatable`: 是否可重複
- `cooldown_days`: 冷卻天數
- `available_conditions`: 可用條件（聲望、技能、事件完成等）

## 使用流程

### 創建新地點

1. **創建地點資源**
```gdscript
# locations/location_new_city.tres
location_id: "new_city"
location_name: "新城市"
description: "城市描述"
sub_locations: [子地點1, 子地點2]
```

2. **創建子地點**
```gdscript
# locations/new_city/sublocation_market.tres
sub_location_id: "market"
sub_location_name: "市集"
actions: [動作1, 動作2]
```

3. **創建動作**
```gdscript
# locations/new_city/market/action_buy.tres
action_id: "buy_item"
action_name: "購買物品"
cost_money: 50
trigger_event_id: "buy_event"
```

4. **創建對應事件**
```gdscript
# events/market/buy_event.tres
event_id: "buy_event"
title: "購買物品"
steps: [...]
```

### 創建事件序列

```gdscript
# 動作配置
action_id: "special_quest"
is_event_sequence: true
event_sequence: ["quest_start", "quest_middle", "quest_end"]

# 創建三個獨立的事件文件
# events/quest/quest_start.tres
# events/quest/quest_middle.tres
# events/quest/quest_end.tres
```

## 常用條件配置

### 需要金錢
```gdscript
# 直接使用 cost_money
action.cost_money = 100
```

### 需要聲望
```gdscript
available_conditions = [
  EventCondition {
    condition_type: STAT
    stat_name: "reputation"
    operator: GREATER_THAN_OR_EQUAL
    value: 50
  }
]
```

### 需要完成特定事件
```gdscript
available_conditions = [
  EventCondition {
    condition_type: EVENT_COMPLETED
    event_id: "main_quest_1"
  }
]
```

### 需要學會技能
```gdscript
available_conditions = [
  EventCondition {
    condition_type: HAS_SKILL
    skill_id: "輕功"
  }
]
```

## 動作效果類型

### 1. 觸發單個事件
```gdscript
trigger_event_id: "my_event"
is_event_sequence: false
```

### 2. 觸發事件序列
```gdscript
is_event_sequence: true
event_sequence: ["event1", "event2", "event3"]
```

### 3. 每日限制
```gdscript
repeatable: true
cooldown_days: 1  # 每天只能用一次
```

### 4. 一次性動作
```gdscript
repeatable: false
cooldown_days: 0
```

### 5. 多天冷卻
```gdscript
repeatable: true
cooldown_days: 5  # 每5天可用一次
```

## 調試技巧

### 查看已加載的地點
```gdscript
print("已載入地點數量：", location_manager.all_locations.size())
for loc in location_manager.all_locations:
    print("- ", loc.location_name)
```

### 查看動作歷史
```gdscript
print("動作歷史：", location_manager.action_history)
```

### 手動觸發事件
```gdscript
var event = event_manager.get_event_by_id("my_event")
if event:
    event_manager.trigger_event(event)
    show_event()
```

### 重置動作冷卻
```gdscript
location_manager.action_history["action_id"]["last_used_day"] = -999
```

## 常見問題解決

### Q: 動作按鈕顯示為禁用
**檢查項目**:
- 金錢是否足夠
- 條件是否滿足
- 是否在冷卻中
- 不可重複動作是否已使用

### Q: 事件序列沒有自動繼續
**檢查項目**:
- `is_event_sequence` 是否為 true
- `event_sequence` 數組是否正確
- 事件ID是否存在
- 事件完成後是否調用 `on_event_sequence_step_completed()`

### Q: 地點列表為空
**檢查項目**:
- `location_manager.load_locations_from_directory()` 是否被調用
- `.tres` 文件是否在 `locations/` 目錄下
- 資源文件是否正確配置 script 屬性

### Q: 事件無法觸發
**檢查項目**:
- 事件ID是否與動作中的 `trigger_event_id` 匹配
- 事件文件是否在 `events/` 目錄下
- `event_manager.load_events_from_directory()` 是否被調用

## 擴展示例

### 添加時間系統
```gdscript
# 在 SubLocation 中添加
@export var available_times: Array[String] = []  # ["morning", "afternoon", "night"]

# 在 LocationManager.is_sub_location_available() 中檢查
if not sub_location.available_times.is_empty():
    if not main_scene.current_time in sub_location.available_times:
        return false
```

### 添加隨機事件池
```gdscript
# 在 LocationAction 中添加
@export var random_event_pool: Array[String] = []

# 在 execute_action() 中
if not action.random_event_pool.is_empty():
    var random_event = action.random_event_pool[randi() % action.random_event_pool.size()]
    trigger_event_by_id(random_event)
```

### 添加物品消耗
```gdscript
# 在 LocationAction 中已有
@export var cost_items: Dictionary = {}  # {"物品ID": 數量}

# 在 is_action_available() 中檢查
for item_id in action.cost_items:
    if not main_scene.player_data.items.has(item_id):
        return false
    if main_scene.player_data.items[item_id] < action.cost_items[item_id]:
        return false
```

## 性能優化建議

1. **延遲加載**: 只在需要時載入地點資源
2. **緩存檢查**: 緩存條件檢查結果，避免重複計算
3. **按需生成按鈕**: 只為當前可見的動作生成按鈕
4. **資源預載入**: 在遊戲啟動時預載入常用地點

## 未來擴展方向

- [ ] 地點解鎖系統（劇情進度）
- [ ] NPC互動系統
- [ ] 隨機事件池
- [ ] 時間系統（早中晚）
- [ ] 天氣系統
- [ ] 物品商店系統
- [ ] 聲望等級影響
- [ ] 地點視覺效果（背景圖、動畫）
