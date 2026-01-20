# skill_data.gd - 技能資源類
class_name SkillData
extends Resource

@export var skill_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var mp_cost: int = 0
@export var damage_multiplier: float = 1.0
@export var hits: int = 1
@export var effects: Array[SkillEffect] = []  # Array of SkillEffect
