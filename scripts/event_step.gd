# event_step.gd - 事件步驟資源類
class_name EventStep
extends Resource

enum SpeakerPosition { LEFT, RIGHT }

@export var speaker: String = ""  # 說話者名稱（可選）
@export var speaker_position: SpeakerPosition = SpeakerPosition.LEFT  # 說話者位置
@export var text: String = ""
@export var choices: Array[EventChoice] = []  # 不使用類型化數組，改用普通 Array
@export var end_event: bool = false  # 是否在此步驟後直接結束事件（不管是否還有下一步）
