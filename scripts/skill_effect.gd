# skill_effect.gd - 技能效果資源類
class_name SkillEffect
extends Resource

@export_enum("damage", "heal", "buff", "debuff", "cost", "special") var effect_type: String = "damage"
@export var effect_params: Dictionary = {}
