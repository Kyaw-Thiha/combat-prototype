extends CanvasLayer
class_name CombatInteface

var player_division: Division
var player_damage_type: LandUnit.DamageType
var enemy_division: Division
var enemy_damage_type: LandUnit.DamageType

var timer: Timer

## Combat Stage
## 1: Contact
## 2: Skirmish
## 3: Clash
## 4: Assault
## 5: Full-Assault
var combat_stage: int

var ui: VBoxContainer

var test_player = [
	StandardInfantry.new(0, 0), null, StandardInfantry.new(0, 2), null, StandardInfantry.new(0, 4),
	StandardInfantry.new(1, 0), null, StandardInfantry.new(1, 2), null, StandardInfantry.new(1, 4),
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
] as Array[LandUnit]

var test_enemy = [
	null, StandardInfantry.new(0, 1), null, StandardInfantry.new(0, 3), null,
	null, StandardInfantry.new(1, 1), null, StandardInfantry.new(1, 3), null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
] as Array[LandUnit]

func _ready() -> void:
	self.ui = VBoxContainer.new()
	
	# Rendering the 2 divisions
	self.player_division = Division.new(test_player)
	self.player_damage_type = LandUnit.DamageType.DEFENSE
	ui.add_child(self.player_division)
	
	self.enemy_division = Division.new(test_enemy)
	self.enemy_damage_type = LandUnit.DamageType.DEFENSE
	ui.add_child(self.enemy_division)
	
	self.add_child(self.ui)
	
	# Rendering the timer
	self.timer = Timer.new()
	self.timer.wait_time = 3		# Every 30seconds
	self.timer.one_shot = false
	self.timer.autostart = true
	self.timer.timeout.connect(_on_timer_timeout)

	self.add_child(self.timer) 

func _on_timer_timeout():
	print("Timer fired!")
	process_combat()
	
	var player_dead = self.player_division.check_if_wiped_out()
	var enemy_dead = self.enemy_division.check_if_wiped_out()
	
	if player_dead or enemy_dead:
		timer.stop()
		# queue_free()

func process_combat():
	var player_combat_context = LandCombatContext.new(self.player_damage_type, self.player_division, self.enemy_division)
	var enemy_combat_context = LandCombatContext.new(self.enemy_damage_type, self.enemy_division, self.player_division)
	# Getting the attack values
	var player_attacks: Array[LandAttack] = player_division.attack(player_combat_context)
	var enemy_attacks: Array[LandAttack] = enemy_division.attack(enemy_combat_context)
	
	# Getting the recon values
	var player_recon_value = player_division.get_total_recon_value()
	var enemy_recon_value = enemy_division.get_total_recon_value()
	# Apply the affects on recon value from weather and fortifications (Additive)
	
	# Ensuring that the recon values are capped at 1.0
	player_recon_value = clampf(player_recon_value, 0.0, 1.0)
	enemy_recon_value = clampf(enemy_recon_value, 0.0, 1.0)
	
	
	print("Enemy Attacks: ", enemy_attacks)
	# Apply damages to each of the divisions
	player_division.apply_damage(enemy_attacks, enemy_division, enemy_recon_value)
	enemy_division.apply_damage(player_attacks, player_division, player_recon_value)
	print("Player Attacks:", player_attacks)
	
	# Check if either player or division are wiped out
	# If they are, apply experience gain accordingly
	
	# Incrementing to next stage of battle
	self.combat_stage = clamp(self.combat_stage + 1, 1, 5)
	
