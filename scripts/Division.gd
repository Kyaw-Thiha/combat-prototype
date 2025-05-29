extends Node2D
class_name Division

const row_num = 5
const col_num = 5

## A 5x5 2D array of units
## Note that this is a linear array storing 2D info
@export var units: Array[LandUnit]

func _init(init_units: Array[LandUnit] = []):
	for row in range(row_num):
		for col in range(col_num):
			if len(init_units) == 0:
				units.append(null)
			else:
				units.append(init_units[row_num * row + col_num])
	self.units[0] = StandardInfantry.new(0, 0, 500)

## Collect the attacks of all of its units, and return it
func attack(damage_type: LandUnit.DamageType):
	const attacks = []
	for row in range(row_num):
		for col in range(col_num):
			var unit = units[row_num * row + col_num]
			if unit != null:
				var damage = unit.land_attack(damage_type)
				attacks.append(damage)
	return attacks

## Collect recon values of all units in the division
## Note that the return value could be greater than 1
func get_total_recon_value() -> float:
	var total_recon_value = 0
	for row in range(row_num):
		for col in range(col_num):
			var unit = units[row_num * row + col_num]
			if unit != null:
				total_recon_value += unit.recon_value
	return total_recon_value

##
func apply_damage(attacks: Array[LandAttack], recon_value: float, combat_stage: int):
	for attack in attacks:
		for attack_target in attack.attack_targets:
			var target = self.units[attack_target.row * row_num + attack_target.col]
			
			## ???
			match attack.attack_type:
				LandAttack.AttackType.ROW:
					var target_row = target.row
					while target_row < 5:
						if _is_row_empty(target_row):
							target_row += 1
						else:
							pass
				LandAttack.AttackType.COLUMN:
					var target_col = target.col
					while target_col < 5:
						if _is_col_empty(target_col):
							target_col += 1
						else:
							pass
				LandAttack.AttackType.FIXED:
					pass

	return

## Internal method to check if column is empty
func _is_col_empty(col: int):
	for row in row_num:
		if units[row_num * row + col] != null:
			return false
	return true
## Internal method to check if row is empty
func _is_row_empty(row: int):
	for col in col_num:
		if units[row_num * row + col] != null:
			return false
	return true
## Internal method to check if cell is empty
func _find_non_empty_unit(row: int, col: int):
	while units[row_num * row + col] == null:
		col += 1
		if col > 5:
			col = 0
			row += 1
		if row > 5:
			return null
	return units[row_num * row + col]
			
