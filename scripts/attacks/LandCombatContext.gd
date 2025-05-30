## Context to send from combat manager onto division onto each land units
extends Node
class_name LandCombatContext

var damage_type: LandUnit.DamageType
var player_division: Division
var enemy_division: Division

func _init(damage_type: LandUnit.DamageType, player_division: Division, enemy_division: Division) -> void:
	self.damage_type = damage_type
	self.player_division = player_division
	self.enemy_division = enemy_division
