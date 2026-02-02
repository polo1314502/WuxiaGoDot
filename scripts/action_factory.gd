# action_factory.gd - 動作工廠
class_name ActionFactory
extends RefCounted

static func create_action(main_scene, action_type: String, params: Dictionary) -> EventAction:
	match action_type:
		"change_stats":
			return ActionChangeStats.new(main_scene, params)
		"trigger_battle":
			return ActionTriggerBattle.new(main_scene, params)
		"buy_item":
			return ActionBuyItem.new(main_scene, params)
		"use_item":
			return ActionUseItem.new(main_scene, params)
		"learn_skill":
			return ActionLearnSkill.new(main_scene, params)
		_:
			push_error("Unknown action type: " + action_type)
			return null
