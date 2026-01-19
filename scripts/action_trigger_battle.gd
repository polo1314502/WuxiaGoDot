# action_trigger_battle.gd - 觸發戰鬥動作
class_name ActionTriggerBattle
extends EventAction

var enemy_name: String = "敵人"
var enemy_hp: int = 80
var enemy_attack: int = 12
var enemy_defense: int = 8
var enemy_speed: int = 10
var pre_message: String = ""

func setup(params: Dictionary):
	if params.has("enemy_name"): enemy_name = params.enemy_name
	if params.has("enemy_hp"): enemy_hp = params.enemy_hp
	if params.has("enemy_attack"): enemy_attack = params.enemy_attack
	if params.has("enemy_defense"): enemy_defense = params.enemy_defense
	if params.has("enemy_speed"): enemy_speed = params.enemy_speed
	if params.has("message"): pre_message = params.message

func execute():
	triggers_battle = true
	battle_params = {
		"name": enemy_name,
		"hp": enemy_hp,
		"attack": enemy_attack,
		"defense": enemy_defense,
		"speed": enemy_speed
	}
	result_text = pre_message
