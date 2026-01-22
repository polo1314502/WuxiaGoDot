# location_action.gd - 地點動作資源類
class_name LocationAction
extends Resource

## 動作唯一ID
@export var action_id: String = ""

## 動作名稱（如"打聽消息"、"租房休息"）
@export var action_name: String = ""

## 動作描述
@export var description: String = ""

## 可用條件（可選，如需要金錢、聲望等）
@export var available_conditions: Array[EventCondition] = []

## 觸發的事件ID（可以是單個事件或事件序列）
@export var trigger_event_id: String = ""

## 是否觸發事件序列
@export var is_event_sequence: bool = false

## 事件序列ID列表（按順序觸發）
@export var event_sequence: Array[String] = []

## 消耗資源（可選）
@export var cost_money: int = 0
@export var cost_items: Dictionary = {}  # 將來擴展用

## 是否可重複使用
@export var repeatable: bool = true

## 冷卻天數（0表示無冷卻）
@export var cooldown_days: int = 0
