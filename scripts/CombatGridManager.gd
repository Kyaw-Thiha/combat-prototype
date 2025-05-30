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
	var grid = $VBoxContainer
	
	for row in range(5):
		var hline = HBoxContainer.new();
		for col in range(5):
			var btn = Button.new()
			btn.text = "%d, %d" % [row, col]
			hline.add_child(btn)
		grid.add_child(hline)

func process_combat():
	var player_combat_context = LandCombatContext.new(self.player_damage_type, self.player_division, self.enemy_division)
	var enemy_combat_context = LandCombatContext.new(self.enemy_damage_type, self.enemy_division, self.player_division)
	# Getting the attack values
	var player_attacks = player_division.attack(player_combat_context)
	var enemy_attacks = enemy_division.attack(enemy_combat_context)
	
	# Getting the recon values
	var player_recon_value = player_division.get_total_recon_value()
	var enemy_recon_value = enemy_division.get_total_recon_value()
	# Apply the affects on recon value from weather and fortifications (Additive)
	
	# Ensuring that the recon values are capped at 1.0
	player_recon_value = clampf(player_recon_value, 0.0, 1.0)
	enemy_recon_value = clampf(enemy_recon_value, 0.0, 1.0)
	
	# Apply damages to each of the divisions
	var player_result = player_division.apply_damage(enemy_attacks, enemy_recon_value)
	var enemy_result = enemy_division.apply_damage(player_attacks, player_recon_value)
	
	# Check if either player or division are wiped out
	# If they are, apply experience gain accordingly
	
	# Incrementing to next stage of battle
	self.combat_stage = clamp(self.combat_stage + 1, 1, 5)
	
