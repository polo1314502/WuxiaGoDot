# 武俠遊戲視覺化升級方案

## 📋 目標功能
1. ✅ 戰鬥時顯示玩家和敵人立繪/精靈圖
2. ✅ 技能使用時播放動畫效果
3. ✅ 事件中顯示插圖
4. ✅ 保持現有數據結構和存檔系統
5. ✅ 向後兼容，逐步升級

---

## 🏗️ 架構設計：混合方案

### 核心原則
- **數據層**：保持 Dictionary + Resource（邏輯、存檔）
- **視覺層**：使用 Scene（立繪、動畫、特效）
- **分離關注點**：邏輯和視覺完全解耦

### 架構圖
```
┌─────────────────────────────────────────┐
│         Main Scene (主場景)              │
├─────────────────────────────────────────┤
│  邏輯層 (現有)                           │
│  - player_data: Dictionary              │
│  - enemy_data: Dictionary               │
│  - SkillManager, EventManager           │
├─────────────────────────────────────────┤
│  視覺層 (新增)                           │
│  - BattleVisuals (戰鬥視覺管理器)        │
│    ├── PlayerSprite (玩家立繪)          │
│    ├── EnemySprite (敵人立繪)           │
│    └── SkillEffects (技能特效)          │
│  - EventVisuals (事件視覺管理器)         │
│    └── EventIllustration (事件插圖)     │
└─────────────────────────────────────────┘
```

---

## 🎨 實施步驟

### 階段 1：創建視覺管理器 (不影響現有代碼)

#### 1.1 戰鬥視覺管理器
```gdscript
# battle_visuals.gd
class_name BattleVisuals
extends Node2D

signal animation_finished
signal damage_dealt(target: String, amount: int)

@onready var player_sprite = $PlayerSprite
@onready var enemy_sprite = $EnemySprite
@onready var skill_effects = $SkillEffects
@onready var animation_player = $AnimationPlayer

var is_visible: bool = false

# 顯示戰鬥場景
func show_battle(player_data: Dictionary, enemy_data: Dictionary):
    is_visible = true
    visible = true
    
    # 設置玩家立繪
    _setup_player_sprite(player_data)
    
    # 設置敵人立繪
    _setup_enemy_sprite(enemy_data)
    
    # 播放進場動畫
    animation_player.play("battle_start")

# 隱藏戰鬥場景
func hide_battle():
    animation_player.play("battle_end")
    await animation_player.animation_finished
    visible = false
    is_visible = false

# 播放技能動畫
func play_skill_animation(skill_id: String, is_enemy: bool):
    var anim_name = "skill_" + skill_id
    
    if animation_player.has_animation(anim_name):
        animation_player.play(anim_name)
        await animation_player.animation_finished
    
    animation_finished.emit()

# 更新血量顯示（可選：血條動畫）
func update_hp(target: String, current_hp: int, max_hp: int):
    if target == "player":
        player_sprite.update_hp_bar(current_hp, max_hp)
    else:
        enemy_sprite.update_hp_bar(current_hp, max_hp)

# 播放受擊動畫
func play_hit_effect(target: String, damage: int):
    var sprite = enemy_sprite if target == "enemy" else player_sprite
    
    # 閃爍效果
    var tween = create_tween()
    tween.tween_property(sprite, "modulate", Color.RED, 0.1)
    tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
    tween.tween_property(sprite, "modulate", Color.RED, 0.1)
    tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
    
    # 顯示傷害數字
    _spawn_damage_number(sprite.global_position, damage)
    
    await tween.finished
    damage_dealt.emit(target, damage)

# 私有：設置玩家精靈
func _setup_player_sprite(data: Dictionary):
    # 根據玩家數據設置立繪
    # 可以根據等級、裝備等改變外觀
    player_sprite.set_character_data(data)

# 私有：設置敵人精靈
func _setup_enemy_sprite(data: Dictionary):
    # 根據敵人ID載入對應的立繪
    var sprite_path = "res://sprites/enemies/%s.png" % data.get("enemy_id", "default")
    if ResourceLoader.exists(sprite_path):
        enemy_sprite.texture = load(sprite_path)

# 私有：生成傷害數字特效
func _spawn_damage_number(position: Vector2, damage: int):
    var label = Label.new()
    label.text = str(damage)
    label.add_theme_font_size_override("font_size", 32)
    label.add_theme_color_override("font_color", Color.YELLOW)
    label.global_position = position
    add_child(label)
    
    # 彈出動畫
    var tween = create_tween()
    tween.tween_property(label, "position:y", position.y - 50, 0.5)
    tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5)
    await tween.finished
    label.queue_free()
```

#### 1.2 角色精靈腳本
```gdscript
# character_sprite.gd
class_name CharacterSprite
extends Node2D

@onready var sprite = $Sprite2D
@onready var hp_bar = $HPBar
@onready var animation_player = $AnimationPlayer

var character_data: Dictionary = {}

func set_character_data(data: Dictionary):
    character_data = data
    _load_sprite()
    update_hp_bar(data.hp, data.max_hp)

func _load_sprite():
    # 根據角色數據載入對應精靈
    var sprite_id = character_data.get("sprite_id", "default")
    var sprite_path = "res://sprites/characters/%s.png" % sprite_id
    
    if ResourceLoader.exists(sprite_path):
        sprite.texture = load(sprite_path)

func update_hp_bar(current: int, maximum: int):
    if hp_bar:
        hp_bar.max_value = maximum
        hp_bar.value = current

func play_idle():
    if animation_player.has_animation("idle"):
        animation_player.play("idle")

func play_attack():
    if animation_player.has_animation("attack"):
        animation_player.play("attack")
        await animation_player.animation_finished

func play_hurt():
    if animation_player.has_animation("hurt"):
        animation_player.play("hurt")
        await animation_player.animation_finished
```

---

### 階段 2：整合到現有系統

#### 2.1 在 main.tscn 中添加視覺節點
```
Main (Node2D)
├── UI (CanvasLayer) [現有]
└── Visuals (Node2D) [新增]
    ├── BattleVisuals
    │   ├── PlayerSprite
    │   │   ├── Sprite2D
    │   │   ├── HPBar
    │   │   └── AnimationPlayer
    │   ├── EnemySprite
    │   │   ├── Sprite2D
    │   │   ├── HPBar
    │   │   └── AnimationPlayer
    │   ├── SkillEffects (Node2D)
    │   └── AnimationPlayer
    └── EventVisuals
        └── IllustrationDisplay
```

#### 2.2 修改 main.gd 整合視覺系統
```gdscript
# main.gd 中添加
@onready var battle_visuals = $Visuals/BattleVisuals  # 新增
@onready var event_visuals = $Visuals/EventVisuals    # 新增

var use_visuals: bool = true  # 可選：開關視覺效果

# 修改 start_battle 函數
func start_battle(enemy_name: String, hp: int, atk: int, def: int, spd: int, skills: Array = []):
    in_battle = true
    stats_label.visible = false
    enemy_data = {
        "name": enemy_name,
        "hp": hp,
        "max_hp": hp,
        "mp": 40,
        "max_mp": 40,
        "attack": atk,
        "defense": def,
        "speed": spd,
        "skills": skills,
        "enemy_id": enemy_name  # 新增：用於載入立繪
    }
    
    battle_log.clear()
    battle_turn = "player" if player_data.speed >= enemy_data.speed else "enemy"
    
    # === 新增：顯示視覺效果 ===
    if use_visuals and battle_visuals:
        battle_visuals.show_battle(player_data, enemy_data)
        await battle_visuals.animation_finished  # 等待進場動畫
    # === 視覺效果結束 ===
    
    mode_label.text = "戰鬥模式"
    training_panel.visible = false
    event_panel.visible = false
    battle_panel.visible = true
    
    # ... 其餘代碼不變

# 修改技能使用
func _on_skill_used(skill_id: String):
    if battle_turn != "player" or not in_battle:
        return
    
    # === 新增：播放技能動畫 ===
    if use_visuals and battle_visuals:
        battle_visuals.play_skill_animation(skill_id, false)
        await battle_visuals.animation_finished
    # === 視覺效果結束 ===
    
    var executor = skill_manager.execute_skill(skill_id)
    
    if not executor:
        add_battle_log("無法使用技能！")
        return
    
    # 輸出戰鬥日誌
    for log in executor.get_logs():
        add_battle_log(log)
    
    # === 新增：顯示傷害效果 ===
    if use_visuals and battle_visuals and executor.damage_total > 0:
        battle_visuals.play_hit_effect("enemy", executor.damage_total)
        battle_visuals.update_hp("enemy", enemy_data.hp, enemy_data.max_hp)
        await battle_visuals.damage_dealt
    # === 視覺效果結束 ===
    
    if in_battle:
        battle_turn = "enemy"
        update_battle_display()
        await get_tree().create_timer(1.0).timeout
        enemy_turn()

# 戰鬥結束時隱藏視覺
func check_battle_end():
    if enemy_data.hp <= 0:
        add_battle_log("你獲勝了！")
        # ... 經驗金錢計算
        
        # === 新增：隱藏戰鬥場景 ===
        if use_visuals and battle_visuals:
            await get_tree().create_timer(2.0).timeout
            battle_visuals.hide_battle()
            await battle_visuals.animation_finished
        # === 視覺效果結束 ===
        
        # ... 其餘代碼
```

---

### 階段 3：事件插圖系統

#### 3.1 事件視覺管理器
```gdscript
# event_visuals.gd
class_name EventVisuals
extends Control

@onready var illustration = $IllustrationRect
@onready var fade_animation = $AnimationPlayer

# 顯示事件插圖
func show_illustration(event_id: String):
    var image_path = "res://images/events/%s.png" % event_id
    
    if ResourceLoader.exists(image_path):
        illustration.texture = load(image_path)
        visible = true
        fade_animation.play("fade_in")
        await fade_animation.animation_finished

# 隱藏插圖
func hide_illustration():
    fade_animation.play("fade_out")
    await fade_animation.animation_finished
    visible = false

# 更新插圖（用於多步驟事件）
func update_illustration(step_id: String):
    var image_path = "res://images/events/%s.png" % step_id
    
    if ResourceLoader.exists(image_path):
        fade_animation.play("fade_out")
        await fade_animation.animation_finished
        
        illustration.texture = load(image_path)
        
        fade_animation.play("fade_in")
        await fade_animation.animation_finished
```

#### 3.2 在 EventData 中添加插圖引用
```gdscript
# event_data.gd 添加
@export var illustration_id: String = ""  # 事件插圖ID

# event_step.gd 添加
@export var step_illustration_id: String = ""  # 步驟插圖ID
```

#### 3.3 整合到事件顯示
```gdscript
# main.gd 修改 show_event()
func show_event():
    var step = event_manager.get_current_step()
    if not step:
        return
    
    # === 新增：顯示事件插圖 ===
    if use_visuals and event_visuals:
        var illustration_id = step.step_illustration_id
        if illustration_id.is_empty():
            illustration_id = event_manager.current_event.illustration_id
        
        if not illustration_id.is_empty():
            event_visuals.show_illustration(illustration_id)
            await event_visuals.fade_animation.animation_finished
    # === 視覺效果結束 ===
    
    mode_label.text = "事件：" + event_manager.current_event.title
    # ... 其餘代碼不變
```

---

## 🎬 動畫製作指南

### 技能動畫製作
1. 在 Godot 編輯器中打開 `BattleVisuals.tscn`
2. 選擇 `AnimationPlayer`
3. 創建新動畫，命名為 `skill_XXX`（對應技能ID）
4. 為動畫添加軌道：
   - **精靈位置**：角色移動
   - **粒子效果**：特效節點
   - **聲音**：音效播放
   - **信號**：關鍵幀觸發事件

### 示例動畫時間軸
```
技能「連擊」動畫 (1.0 秒)
├── 0.0s: 玩家精靈向前移動
├── 0.2s: 第一擊特效 + 傷害數字
├── 0.4s: 第二擊特效 + 傷害數字
├── 0.6s: 玩家精靈後退
└── 1.0s: 動畫結束信號
```

---

## 📁 資源組織結構

```
WuxiaGoDot/
├── sprites/
│   ├── characters/
│   │   ├── player_default.png
│   │   ├── player_warrior.png
│   │   └── ...
│   └── enemies/
│       ├── 山賊.png
│       ├── 惡霸.png
│       └── 江湖武者.png
├── images/
│   └── events/
│       ├── beggar.png
│       ├── bully.png
│       └── cave_adventure.png
├── effects/
│   ├── hit_effect.tscn
│   ├── slash_effect.tscn
│   └── skill_particles.tscn
├── animations/
│   ├── battle_animations.tres
│   └── skill_animations.tres
└── scenes/
    ├── battle_visuals.tscn
    ├── character_sprite.tscn
    └── event_visuals.tscn
```

---

## 🔄 向後兼容性

### 功能開關
```gdscript
# 在設置中添加
var use_visuals: bool = true
var use_battle_animations: bool = true
var use_event_illustrations: bool = true

# 用戶可以關閉視覺效果（純文字模式）
# 適合低配設備或偏好傳統風格的玩家
```

### 漸進式升級
1. ✅ **第一版**：保持純文字
2. ✅ **第二版**：添加靜態立繪（無動畫）
3. ✅ **第三版**：添加簡單動畫（移動、閃爍）
4. ✅ **第四版**：添加完整特效和粒子

---

## 🎯 實施優先級

### P0 - 核心視覺（最低可行產品）
- [x] 戰鬥立繪（靜態圖片）
- [x] 基本血條顯示
- [x] 傷害數字特效

### P1 - 增強體驗
- [ ] 角色進場/退場動畫
- [ ] 技能閃光特效
- [ ] 事件插圖淡入淡出

### P2 - 高級特效
- [ ] 技能粒子系統
- [ ] 相機震動
- [ ] 背景音效

### P3 - 錦上添花
- [ ] Live2D 動態立繪
- [ ] 技能連招特效
- [ ] 場景切換過渡

---

## 💡 關鍵優勢

1. ✅ **不破壞現有代碼**：視覺層是可選的附加功能
2. ✅ **保持存檔兼容**：數據結構完全不變
3. ✅ **性能可控**：可以關閉視覺效果
4. ✅ **易於擴展**：添加新立繪只需加圖片
5. ✅ **開發靈活**：可以先做邏輯，後補視覺

---

## 📝 總結

這個方案讓你：
- 🎨 保持現有架構的簡潔性
- 🖼️ 添加豐富的視覺元素
- 🔧 不需要重構核心代碼
- 📦 逐步升級，每一步都可用
- 🎮 給玩家更好的體驗

**下一步**：我可以幫你創建具體的場景文件和示例代碼！
