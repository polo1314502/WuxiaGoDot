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
