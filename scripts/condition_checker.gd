# condition_checker.gd - 條件檢查器
class_name ConditionChecker
extends RefCounted

var main_scene

func _init(main):
	main_scene = main

## 檢查所有條件是否滿足（AND 邏輯）
func check_all_conditions(conditions: Array) -> bool:
	if conditions.is_empty():
		return true
	
	for condition in conditions:
		if condition is EventCondition:
			if not condition.check(main_scene):
				return false
		else:
			# 如果不是 EventCondition 類型，視為條件不滿足
			push_warning("條件類型錯誤：", condition)
			return false
	
	return true

## 檢查任一條件是否滿足（OR 邏輯）
func check_any_condition(conditions: Array) -> bool:
	if conditions.is_empty():
		return false
	
	for condition in conditions:
		if condition is EventCondition:
			if condition.check(main_scene):
				return true
	
	return false

## 檢查單個條件
func check_condition(condition: EventCondition) -> bool:
	if condition:
		return condition.check(main_scene)
	return false
