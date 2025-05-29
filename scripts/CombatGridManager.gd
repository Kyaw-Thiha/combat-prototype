extends CanvasLayer
class_name CombatInteface

var player_division: Division
var player_damage_type: LandUnit.DamageType
var enemy_division: Division
var enemy_damage_type: LandUnit.DamageType

## Combat Stage
## 1: Contact
## 2: Skirmish
## 3: Clash
## 4: Assault
## 5: Full-Assault
var combat_stage: int

func _ready() -> void:
	var grid  = $CombatGrid
	
	for row in range(5):
		for col in range(5):
			var btn = Button.new()
			btn.text = "%d, %d" % [row, col]
			grid.add_child(btn)

func process_combat():
	# Getting the attack values
	var player_attacks = player_division.attack(player_damage_type)
	var enemy_attacks = enemy_division.attack(enemy_damage_type)
	
	# Getting the recon values
	var player_recon_value = player_division.get_total_recon_value()
	var enemy_recon_value = enemy_division.get_total_recon_value()
	# Apply the affects on recon value from weather and fortifications (Additive)
	
	# Ensuring that the recon values are capped at 1.0
	player_recon_value = clampf(player_recon_value, 0.0, 1.0)
	enemy_recon_value = clampf(enemy_recon_value, 0.0, 1.0)
	
	# Apply combat stage effect on recon value (Multiplicative)
	match self.combat_stage:
		1:
			player_recon_value *= 0.5
			enemy_recon_value *= 0.5
		2:
			player_recon_value *= 0.75
			enemy_recon_value *= 0.75
		3:
			player_recon_value *= 0.9
			enemy_recon_value *= 0.9
	
	# Apply damages to each of the divisions
	
	# Incrementing to next stage of battle
	self.combat_stage = clamp(self.combat_stage + 1, 1, 5)
	
