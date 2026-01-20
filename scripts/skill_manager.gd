# skill_manager.gd - 技能管理器
class_name SkillManager
extends Node

var main_scene
var available_skills: Array = []  # Array of SkillData

func _init(main):
	main_scene = main

func load_skills_from_directory(path: String = "res://skills/"):
	available_skills.clear()
	_scan_directory(path)

func _scan_directory(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var full_path = path + file_name
				var resource = load(full_path)
				if resource is SkillData:
					available_skills.append(resource)
			file_name = dir.get_next()
		dir.list_dir_end()

func get_skill_by_id(skill_id: String) -> SkillData:
	for skill in available_skills:
		if skill.skill_id == skill_id:
			return skill
	return null

func execute_skill(skill_id: String) -> SkillExecutor:
	var skill = get_skill_by_id(skill_id)
	if not skill:
		return null
	
	var executor = SkillExecutor.new(main_scene, skill)
	if executor.can_execute():
		executor.execute()
		return executor
	
	return null
