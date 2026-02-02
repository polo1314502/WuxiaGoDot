# 物品系統使用說明

## 概述

物品系統為遊戲添加了完整的道具和裝備功能，包括：
- 物品數據定義
- 庫存管理
- 物品使用和裝備
- 商店購買/出售

## 核心組件

### 1. ItemData（物品數據）
位置：`scripts/item_data.gd`

定義物品的所有屬性：
- **基本屬性**：ID、名稱、描述、價格
- **物品類型**：consumable（消耗品）、equipment（裝備）、quest（任務物品）、material（材料）
- **消耗品效果**：恢復HP/MP、增加屬性等
- **裝備屬性**：攻擊、防禦、速度等加成
- **裝備欄位**：weapon（武器）、armor（防具）、accessory（飾品）

### 2. InventoryManager（庫存管理器）
位置：`scripts/inventory_manager.gd`

管理玩家的物品庫存：
- 添加/移除物品
- 使用消耗品
- 裝備/卸下裝備
- 買賣物品
- 保存/讀取庫存數據

### 3. ActionBuyItem（購買物品動作）
位置：`scripts/action_buy_item.gd`

用於事件中的物品購買，支援：
- 新系統：使用 item_id 購買實際物品
- 舊系統：向後兼容直接修改屬性的方式

### 4. ActionUseItem（使用物品動作）
位置：`scripts/action_use_item.gd`

用於事件中使用物品。

## 創建新物品

### 步驟 1：創建物品資源文件

在 `items/` 目錄下創建 `.tres` 文件：

```gdscript
[gd_resource type="Resource" script_class="ItemData" load_steps=2 format=3 uid="uid://唯一ID"]

[ext_resource type="Script" path="res://scripts/item_data.gd" id="1_k3mf8"]

[resource]
script = ExtResource("1_k3mf8")
item_id = "物品ID"
item_name = "物品名稱"
description = "物品描述"
item_type = "consumable"  # 或 "equipment"
price = 100
sell_price = 50
max_stack = 99
consumable_effects = {
    "hp": 50,  # 恢復50點生命
    "mp": 30   # 恢復30點內力
}
# 或裝備屬性
equipment_slot = "weapon"  # weapon/armor/accessory
equipment_stats = {
    "attack": 10,
    "defense": 5
}
usable = true
use_in_battle = true
```

### 步驟 2：在事件中使用物品

#### 購買物品事件示例：

```gdscript
[sub_resource type="Resource" id="EventChoice_1"]
script = ExtResource("3_m5pg1")
choice_text = "購買療傷丹（50銀兩）"
action_type = "buy_item"
action_params = {
    "item_id": "healing_pill",  # 物品ID
    "quantity": 1               # 購買數量（可選，默認1）
}
next_step = -1
conditions = []
```

#### 使用物品事件示例：

```gdscript
[sub_resource type="Resource" id="EventChoice_2"]
script = ExtResource("3_m5pg1")
choice_text = "使用療傷丹"
action_type = "use_item"
action_params = {
    "item_id": "healing_pill"
}
next_step = -1
conditions = []
```

## 已創建的示例物品

### 消耗品
1. **療傷丹** (`healing_pill`)
   - 恢復50點生命
   - 價格：50銀兩

2. **回氣丹** (`energy_pill`)
   - 恢復30點內力
   - 價格：80銀兩

3. **大還丹** (`great_healing_pill`)
   - 恢復150點生命和50點內力
   - 價格：200銀兩

### 武器
1. **鐵劍** (`iron_sword`)
   - 攻擊 +10
   - 價格：150銀兩

2. **精鋼劍** (`steel_sword`)
   - 攻擊 +25、速度 +5
   - 價格：500銀兩

### 防具
1. **皮甲** (`leather_armor`)
   - 防禦 +8
   - 價格：120銀兩

2. **鐵甲** (`iron_armor`)
   - 防禦 +20、最大生命 +30
   - 價格：400銀兩

### 飾品
1. **玉佩** (`jade_pendant`)
   - 最大生命 +20、最大內力 +20
   - 價格：300銀兩

## 已創建的示例商店事件

1. **藥鋪** (`shop_medicine`) - 位於 `events/shop_medicine.tres`
   - 出售各種丹藥

2. **武器鋪** (`shop_weapon`) - 位於 `events/shop_weapon.tres`
   - 出售武器和防具

## 程式碼使用範例

### 在 GDScript 中使用

```gdscript
# 添加物品到庫存
main_scene.inventory_manager.add_item("healing_pill", 5)

# 檢查是否擁有物品
if main_scene.inventory_manager.has_item("healing_pill"):
    print("擁有療傷丹")

# 使用物品
main_scene.inventory_manager.use_item("healing_pill")

# 裝備物品
main_scene.inventory_manager.equip_item("iron_sword")

# 卸下裝備
main_scene.inventory_manager.unequip_item("weapon")

# 購買物品
main_scene.inventory_manager.buy_item("healing_pill", 3)

# 出售物品
main_scene.inventory_manager.sell_item("healing_pill", 1)

# 獲取物品數量
var count = main_scene.inventory_manager.get_item_count("healing_pill")

# 獲取庫存列表
var inventory_list = main_scene.inventory_manager.get_inventory_list()
for entry in inventory_list:
    var item: ItemData = entry["item"]
    var quantity: int = entry["quantity"]
    print("%s x%d" % [item.item_name, quantity])
```

## 存檔系統集成

庫存數據會自動保存和讀取。如果需要手動處理：

```gdscript
# 獲取存檔數據
var save_data = inventory_manager.get_save_data()

# 讀取存檔數據
inventory_manager.load_save_data(save_data)
```

## 擴展建議

1. **添加更多物品類型**
   - 技能書
   - 任務物品
   - 合成材料

2. **物品品質系統**
   - 普通、精良、史詩、傳說

3. **物品強化系統**
   - 裝備升級
   - 鑲嵌寶石

4. **套裝系統**
   - 收集同套裝備獲得額外加成

5. **物品效果擴展**
   - 臨時BUFF
   - 負面效果移除
   - 特殊技能觸發

## 注意事項

1. 每個物品必須有唯一的 `item_id`
2. 裝備會自動應用屬性加成
3. 消耗品使用後會從庫存中移除
4. 裝備不能堆疊（max_stack = 1）
5. HP和MP恢復會自動限制在最大值內
6. 出售物品默認價格為購買價格的一半

## 測試

啟動遊戲後：
1. 觸發 `shop_medicine` 或 `shop_weapon` 事件購買物品
2. 點擊底部的「物品庫存」按鈕打開庫存UI
3. 在庫存中：
   - 選擇物品查看詳細資訊
   - 使用消耗品恢復生命/內力
   - 裝備武器/防具/飾品
   - 出售不需要的物品
4. 查看已裝備物品顯示在UI底部

遊戲啟動時會自動添加一些測試物品（3個療傷丹、2個回氣丹）供你測試。

建議在 main.gd 的 _ready() 中添加更多測試物品：
```gdscript
# 測試：添加初始物品
inventory_manager.add_item("healing_pill", 3)
inventory_manager.add_item("iron_sword", 1)
```
