# action_custom_message.gd - 自訂訊息動作
class_name ActionCustomMessage
extends EventAction

var message: String = ""

func setup(params: Dictionary):
	if params.has("message"):
		message = params.message

func can_execute() -> bool:
	# 總是可以執行
	return true

func execute():
	result_text = message
