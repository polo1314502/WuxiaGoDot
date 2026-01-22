# event_data.gd - 事件資源類
class_name EventData
extends Resource

@export var event_id: String = ""
@export var title: String = ""
@export var steps: Array[EventStep] = []
@export var trigger_conditions: Array[EventCondition] = []  # 觸發條件列表（所有條件都要滿足）
@export var can_repeat: bool = false  # 是否可重複觸發
@export var priority: int = 0  # 優先級（數字越大越優先）
@export var force_training_mode: bool = false  # 是否強制結束後進入養成模式（即使從場景模式觸發）
