## Context to send from combat manager onto division onto each land units
extends Node
class_name LandCombatContext

var damage_type: LandUnit.DamageType
var player_division: Division
var player_global_effects: Array[Array]
var enemy_division: Division
var enemy_global_effects: Array[Array]

func _init(damage_type: LandUnit.DamageType, player_division: Division, player_global_effects: Array[Array], enemy_division: Division, enemy_global_effects: Array[Array]) -> void:
	self.damage_type = damage_type
	self.player_division = player_division
	self.player_global_effects = player_global_effects
	self.enemy_division = enemy_division
	self.enemy_global_effects =  enemy_global_effects
