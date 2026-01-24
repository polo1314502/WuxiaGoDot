# event_data.gd - 事件資源類
class_name EventData
extends Resource

enum ForceMode {
	NONE,      # 不強制，根據觸發來源決定
	TRAINING,  # 強制進入養成模式
	LOCATION   # 強制進入場景模式
}

@export var event_id: String = ""
@export var title: String = ""
@export var steps: Array[EventStep] = []
@export var trigger_conditions: Array[EventCondition] = []  # 觸發條件列表（所有條件都要滿足）
@export var can_repeat: bool = false  # 是否可重複觸發
@export var priority: int = 0  # 優先級（數字越大越優先）
@export var force_mode: ForceMode = ForceMode.NONE  # 事件結束後強制進入的模式
