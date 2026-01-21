# event_data.gd - 事件資源類
class_name EventData
extends Resource

@export var event_id: String = ""
@export var title: String = ""
@export var steps: Array[EventStep] = []
@export var trigger_conditions: Array[EventCondition] = []  # 觸發條件列表
@export var prerequisites: Array = []  # 前置條件列表
@export var can_repeat: bool = false  # 是否可重複觸發
@export var priority: int = 0  # 優先級（數字越大越優先）
