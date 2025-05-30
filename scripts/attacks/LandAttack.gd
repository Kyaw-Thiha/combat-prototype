extends Node
class_name  LandAttack

var soft_damage: float
var medium_damage: float
var hard_damage: float

## Position of target on enemy division in the form of 5 * row + col
var target_row: int = -1
var target_col: int = -1

enum TargetAlgorithm {COLUMN, ROW, IGNORE}
var target_algorithm: TargetAlgorithm = TargetAlgorithm.COLUMN

## Determines whether or not the damage values are affected by recon
var is_recon_affected: bool = false

func _init(soft_damage = 0.0, medium_damage = 0.0, hard_damage = 0.0, target_row = -1, target_col = -1, target_algorithm = TargetAlgorithm.ROW, is_recon_affected: bool = false) -> void:
	self.soft_damage = soft_damage
	self.medium_damage = medium_damage
	self.hard_damage = hard_damage
	self.target_row = target_row
	self.target_col = target_col
	self.target_algorithm = target_algorithm
	self.is_recon_affected = is_recon_affected

## Method to update damage values by a multiplier
func update_damage_multiplier(multiplier: float):
	self.soft_damage *= multiplier
	self.medium_damage *= multiplier
	self.hard_damage *= multiplier

## Method to set the damage drop off of the unit
func set_damage_drop_off(player_division: Division, drop_off_rate: Array[float], row: int, col: int):
	var drop_off_count = 0
	var current_row = 0
	
	while current_row < row:
		var unit = player_division.units[current_row * 5 + col]
		if unit != null and unit.health != 0:
			drop_off_count += 1
		current_row += 1
	update_damage_multiplier(drop_off_rate[drop_off_count])
	
	return drop_off_rate[drop_off_count]


## Method to find target by going through the row
## Will return position (5 * col + row) if found
## Else will return -1 if no target found (ie enemy division is empty)
## Row attack is mainly done by infantry units
func set_row_target(enemy_division: Division) -> int:
	var unit_found = false
	var col = 0
	var row = 0
	# if row is already set, start from there
	if self.target_row == -1:
		row = 0
	else:
		row = self.target_row

	while col < 5 and row < 5:
		# Checking the enemy in position
		var pos = 5 * row + col
		var enemy_unit = enemy_division.units[pos]
		if enemy_unit.health != 0:
			self.target_row = row
			self.target_col = col
			return pos
		
		# Incrementing to next checking position
		col += 1
		if col >= 5:
			col = 0
			row += 1
	return -1

## Method to find target by going through the column
## Will return position (5 * col + row) if found
## Else will return -1 if no target found (ie enemy division is empty)
## Column attack is mainly done by armoured units
enum ColSearchDirection {LEFT, RIGHT}
func get_col_target(enemy_division: Division, col:int = 0, search_direction: ColSearchDirection = ColSearchDirection.RIGHT) -> int:
	var unit_found = false
	var row = 0
	var count = 0      # count to stop the loop when we get back to starting col
	while count < 5:
		# Checking the enemy in position
		var pos = 5 * row + col
		var enemy_unit = enemy_division.units[pos]
		if enemy_unit.health != 0:
			self.target_row = row
			self.target_col = col
			return pos
		
		# Incrementing to next checking position
		row += 1
		if row >= 5:
			row = 0
			if search_direction ==  ColSearchDirection.RIGHT:
				col += 1
				if col >= 5:
					col = 0
			elif search_direction == ColSearchDirection.LEFT:
				col -= 1
				if col < 0:
					col = 4
			count += 1
			
	return -1  # if not found
