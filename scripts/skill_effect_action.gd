# skill_effect_action.gd - 技能效果動作基類
class_name SkillEffectAction
extends RefCounted

var main_scene
var player_data: Dictionary
var enemy_data: Dictionary
var skill_data: SkillData
var result_logs: Array = []
var total_damage: int = 0
var total_heal: int = 0

func _init(main, skill: SkillData):
	main_scene = main
	player_data = main.player_data
	enemy_data = main.enemy_data
	skill_data = skill

func can_execute() -> bool:
	return true

func execute():
	pass

func get_logs() -> Array:
	return result_logs
