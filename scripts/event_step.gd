# event_step.gd - 事件步驟資源類
class_name EventStep
extends Resource

@export var text: String = ""
@export var choices: Array[EventChoice] = []  # 不使用類型化數組，改用普通 Array
