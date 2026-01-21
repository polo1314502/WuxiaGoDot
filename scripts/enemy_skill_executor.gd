# enemy_skill_executor.gd - 敵人技能執行器
class_name EnemySkillExecutor
extends RefCounted

var main_scene
var skill_data: SkillData
var effect_actions: Array = []
var damage_total: int = 0
var all_logs: Array = []

func _init(main, skill: SkillData):
	main_scene = main
	skill_data = skill

func can_execute() -> bool:
	# 敵人無需檢查 MP（簡化版）
	# 如果需要敵人也有MP系統，可以在 enemy_data 中加入 mp 欄位
	
	# 檢查所有效果的前置條件
	for effect in skill_data.effects:
		var action = SkillEffectFactory.create_enemy_effect(main_scene, skill_data, effect)
		if action and not action.can_execute():
			return false
		if action:
			effect_actions.append(action)
	
	return true

func execute():
	all_logs.append("%s 使用【%s】" % [main_scene.enemy_data.name, skill_data.name])
	
	# 執行所有效果
	for action in effect_actions:
		action.execute()
		damage_total += action.total_damage
		
		for log in action.get_logs():
			all_logs.append("  " + log)
	
	# 處理吸血（需要在傷害計算後）
	for action in effect_actions:
		if action is EnemyEffectHeal and action.lifesteal_percent > 0 and damage_total > 0:
			var heal = int(damage_total * action.lifesteal_percent / 100.0)
			main_scene.enemy_data.hp = min(main_scene.enemy_data.max_hp, main_scene.enemy_data.hp + heal)
			all_logs.append("  吸血回復 %d 生命" % heal)

func get_logs() -> Array:
	return all_logs
