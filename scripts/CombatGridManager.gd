extends CanvasLayer
class_name CombatInteface

var player_division: Division
var player_damage_type: LandUnit.DamageType
var enemy_division: Division
var enemy_damage_type: LandUnit.DamageType

func _ready() -> void:
	var grid  = $CombatGrid
	
	for row in range(5):
		for col in range(5):
			var btn = Button.new()
			btn.text = "%d, %d" % [row, col]
			grid.add_child(btn)

func process_combat():
	var player_attacks = player_division.attack(player_damage_type)
	var enemy_attacks = enemy_division.attack(enemy_damage_type)
