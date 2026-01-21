# enemy_manager.gd - 敵人管理器
class_name EnemyManager
extends Node

var main_scene
var available_enemies: Array = []  # Array of EnemyData

func _init(main):
	main_scene = main

func load_enemies_from_directory(path: String = "res://enemies/"):
	available_enemies.clear()
	_scan_directory(path)

func _scan_directory(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = path + file_name
			if dir.current_is_dir() and not file_name.begins_with("."):
				# 遞歸掃描子目錄
				_scan_directory(full_path + "/")
			elif file_name.ends_with(".tres"):
				var resource = load(full_path)
				if resource is EnemyData:
					available_enemies.append(resource)
			file_name = dir.get_next()
		dir.list_dir_end()

func get_enemy_by_id(enemy_id: String) -> EnemyData:
	for enemy in available_enemies:
		if enemy.enemy_id == enemy_id:
			return enemy
	return null

func create_battle_data(enemy: EnemyData) -> Dictionary:
	if enemy:
		return enemy.create_battle_instance()
	return {}
