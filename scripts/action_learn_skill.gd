# action_learn_skill.gd - 學習技能動作
class_name ActionLearnSkill
extends EventAction

var skill_id: String = ""
var skill_name: String = ""

func setup(params: Dictionary):
	if params.has("skill_id"):
		skill_id = params.skill_id
	if params.has("skill_name"):
		skill_name = params.skill_name

func can_execute() -> bool:
	# 檢查是否已經學會
	return not (skill_id in player_data.skills)

func execute():
	if skill_id and not (skill_id in player_data.skills):
		player_data.skills.append(skill_id)
		result_text = "你學會了新技能：%s！" % (skill_name if skill_name else skill_id)
	else:
		result_text = "你已經學會這個技能了。"
