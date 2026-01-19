# event_data.gd - 事件資源類
class_name EventData
extends Resource

@export var event_id: String = ""
@export var title: String = ""
@export var steps: Array[EventStep] = []  # 不使用類型化數組，改用普通 Array
