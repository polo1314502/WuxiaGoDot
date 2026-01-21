# skill_effect_factory.gd - 技能效果工廠
class_name SkillEffectFactory
extends RefCounted

static func create_effect(main_scene, skill: SkillData, effect: SkillEffect) -> SkillEffectAction:
	var action = null
	
	match effect.effect_type:
		"damage":
			action = EffectDamage.new(main_scene, skill)
		"heal":
			action = EffectHeal.new(main_scene, skill)
		"buff":
			action = EffectBuff.new(main_scene, skill)
		"cost":
			action = EffectCost.new(main_scene, skill)
		_:
			push_error("Unknown effect type: " + effect.effect_type)
			return null
	
	if action:
		action.setup(effect.effect_params)
	
	return action

# 創建敵人效果
static func create_enemy_effect(main_scene, skill: SkillData, effect: SkillEffect) -> SkillEffectAction:
	var action = null
	
	match effect.effect_type:
		"damage":
			action = EnemyEffectDamage.new(main_scene, skill)
		"heal":
			action = EnemyEffectHeal.new(main_scene, skill)
		"buff":
			action = EnemyEffectBuff.new(main_scene, skill)
		_:
			push_error("Unknown effect type: " + effect.effect_type)
			return null
	
	if action:
		action.setup(effect.effect_params)
	
	return action
