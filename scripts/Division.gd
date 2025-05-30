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
func attack(context: LandCombatContext):
	const attacks = []
	for row in range(row_num):
		for col in range(col_num):
			var unit = units[row_num * row + col_num]
			if unit != null:
				var damage = unit.land_attack(context)
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

## Method to apply damage to units from enemy attacks
func apply_damage(attacks: Array[LandAttack], recon_value: float):
	for attack in attacks:
		var target = self.units[attack.target_row * 5 + attack.target_col]
		target.apply_Land_damage(attack, recon_value)
	
	return not _check_if_wiped_out()

## Internal method to check if division is wiped out
func _check_if_wiped_out():
	for row in 5:
		for col in 5:
			var unit = self.units[row * 5 + col]
			if unit.health > 0:
				return false
	return true

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
			
