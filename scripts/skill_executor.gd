# skill_executor.gd - 統一技能執行器（玩家和敵人共用）
class_name SkillExecutor
extends RefCounted

var main_scene
var skill_data: SkillData
var effect_actions: Array = []
var damage_total: int = 0
var all_logs: Array = []
var is_enemy: bool = false  # 新增：標記是否為敵人使用

func _init(main, skill: SkillData, enemy_mode: bool = false):
	main_scene = main
	skill_data = skill
	is_enemy = enemy_mode

func can_execute() -> bool:
	# 玩家和敵人都需要檢查 MP
	if not is_enemy:
		if main_scene.player_data.mp < skill_data.mp_cost:
			return false
	else:
		# 檢查敵人 MP
		if main_scene.enemy_data.has("mp") and main_scene.enemy_data.mp < skill_data.mp_cost:
			return false
	
	# 檢查所有效果的前置條件
	for effect in skill_data.effects:
		var action = null
		if is_enemy:
			action = SkillEffectFactory.create_enemy_effect(main_scene, skill_data, effect)
		else:
			action = SkillEffectFactory.create_effect(main_scene, skill_data, effect)
		
		if action and not action.can_execute():
			return false
		if action:
			effect_actions.append(action)
	
	return true

func execute():
	# 玩家和敵人都消耗 MP
	if not is_enemy:
		main_scene.player_data.mp -= skill_data.mp_cost
		all_logs.append("你使用【%s】" % skill_data.name)
	else:
		# 敵人消耗 MP
		if main_scene.enemy_data.has("mp"):
			main_scene.enemy_data.mp -= skill_data.mp_cost
		all_logs.append("%s 使用【%s】" % [main_scene.enemy_data.name, skill_data.name])
	
	# 執行所有效果
	for action in effect_actions:
		action.execute()
		damage_total += action.total_damage
		
		for log in action.get_logs():
			all_logs.append("  " + log)
	
	# 處理吸血（需要在傷害計算後）
	_process_lifesteal()

func _process_lifesteal():
	for action in effect_actions:
		var heal_action = null
		var target_data = null
		var max_hp = 0
		
		if is_enemy:
			if action is EnemyEffectHeal:
				heal_action = action
				target_data = main_scene.enemy_data
				max_hp = target_data.max_hp
		else:
			if action is EffectHeal:
				heal_action = action
				target_data = main_scene.player_data
				max_hp = target_data.max_hp
		
		if heal_action and heal_action.lifesteal_percent > 0 and damage_total > 0:
			var heal = int(damage_total * heal_action.lifesteal_percent / 100.0)
			target_data.hp = min(max_hp, target_data.hp + heal)
			all_logs.append("  吸血回復 %d 生命" % heal)

func get_logs() -> Array:
	return all_logs
