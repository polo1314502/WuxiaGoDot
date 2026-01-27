# ============================================
# 戰鬥模式腳本（獨立模式）
# ============================================

extends Panel

# 信號定義
signal skill_used(skill_id: String)
signal battle_ended()

# UI 節點引用
@onready var battle_info = $VBoxContainer/BattleInfo
@onready var skills_container = $VBoxContainer/SkillsContainer

# 外部依賴（由Main傳入）
var main_node: Node = null
var skill_manager = null

func _ready():
	pass

func initialize(main_ref: Node, skill_mgr):
	"""初始化戰鬥模式"""
	main_node = main_ref
	skill_manager = skill_mgr

func setup_battle(player_skills: Array):
	"""設置戰鬥UI，生成技能按鈕"""
	# 清除舊的技能按鈕
	for child in skills_container.get_children():
		child.queue_free()
	
	# 動態生成技能按鈕
	for skill_id in player_skills:
		var skill = skill_manager.get_skill_by_id(skill_id)
		if skill:
			var btn = Button.new()
			if skill.mp_cost == 0:
				btn.text = skill.name
			else:
				btn.text = "%s (內力:%d)" % [skill.name, skill.mp_cost]
			btn.custom_minimum_size = Vector2(150, 40)
			btn.pressed.connect(func(): _on_skill_pressed(skill_id))
			skills_container.add_child(btn)

func _on_skill_pressed(skill_id: String):
	"""技能按鈕被按下"""
	skill_used.emit(skill_id)

func update_battle_info(info_text: String):
	"""更新戰鬥資訊顯示"""
	battle_info.text = info_text

func show_battle():
	"""顯示戰鬥UI"""
	visible = true

func hide_battle():
	"""隱藏戰鬥UI"""
	visible = false
