extends Node
class_name  LandAttack

var soft_damage: float
var medium_damage: float
var hard_damage: float

## Source unit of the attack
var source_unit: LandUnit

## Target unit of the attack
var target_unit: LandUnit

## Target Algorithm
## COLUMNLEFT: 
## - Target will be searched by column, starting from the column that the source unit is located it
## - If the current column is empty, it will move to the column to the left of the current column
## COLUMNRIGHT:
## - Target will be searched by column, starting from the column that the source unit is located it
## - If the current column is empty, it will move to the column to the right of the current column
## ROW:
## - Target will be searched on the nearest row (Row-0), starting from the column the unit is located in
## - If the current row is empty, it will move onto the next row
## GRID:
## - Target will be searched across the whole grid, starting from Grid[0,0]
## - This algorithm is mainly used for priority first targets like snipers
## FIXED:
## - Target will not be prioritized, but will only search if a target 
## - This algorithm is mainly used by units like heavy artillery
enum TargetAlgorithm {COLUMN, COLUMNLEFT, COLUMNRIGHT, ROW, FIXED}
var target_algorithm: TargetAlgorithm = TargetAlgorithm.COLUMN

## Target Priority
## A priority system used to select different targets based on their preferred priority
## - It is in a dictionary of array of internal_name of units
## - Key 0 represents the units with highest priority
## - Units not included among the keys will be considered as 'non-priority', 
##   and will be represented with key 100 in internal process
var target_priority: Dictionary[int, Array]

## Determines whether or not the damage values are affected by recon
var is_recon_affected: bool = false

func _init(soft_damage = 0.0, medium_damage = 0.0, hard_damage = 0.0, source_unit: LandUnit = null, target_unit:LandUnit = null, target_algorithm = TargetAlgorithm.ROW, is_recon_affected: bool = false) -> void:
	self.soft_damage = soft_damage
	self.medium_damage = medium_damage
	self.hard_damage = hard_damage
	self.source_unit  = source_unit
	self.target_unit = target_unit
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

## Helper Classes to find target for most common attack algorithms

## Method to find target based on the algorithm
## Return
## - null if no need to do any damage
## - -1 if enemy division has been wiped out
## - else will return target position
func find_target(enemy_division: Division):
	if self.target_algorithm == TargetAlgorithm.ROW:
		return set_row_target(enemy_division)
	elif self.target_algorithm == TargetAlgorithm.COLUMN:
		return self.set_col_target(enemy_division)
	elif self.target_algorithm == TargetAlgorithm.FIXED:
		return null

## Method to find target by going through the row
## Will return position (5 * col + row) if found
## Else will return -1 if no target found (ie enemy division is empty)
## Row attack is mainly done by infantry units
func set_row_target(enemy_division: Division) -> int:
	self.target_algorithm = TargetAlgorithm.ROW
	
	var units_found: Dictionary[int, LandUnit] = {}   # Dictionary of found units based on priority level
	var source_col = self.source_unit.col
	var col = source_col
	var row = 0
	# if target unit is already set, start from there
	if self.target_unit != null:
		row = self.target_unit.row

	while col != source_col or row < 5:
		# Checking the enemy in position
		var pos = 5 * row + col
		var enemy_unit = enemy_division.units[pos]
		if enemy_unit != null and enemy_unit.health > 0:
			self.target_unit = enemy_unit
			return pos
		
		# Incrementing to next checking position
		col += 1
		if col >= 5:
			col = 0
		if col == source_col:
			row += 1
	return -1

## Method to find target by going through the column
## Will return position (5 * col + row) if found
## Else will return -1 if no target found (ie enemy division is empty)
## Column attack is mainly done by armoured units
enum ColSearchDirection {LEFT, RIGHT}
func set_col_target(enemy_division: Division, col:int = 0, search_direction: ColSearchDirection = ColSearchDirection.RIGHT) -> int:
	self.target_algorithm = TargetAlgorithm.COLUMN
	
	var unit_found = false
	var row = 0
	var count = 0      # count to stop the loop when we get back to starting col
	while count < 5:
		# Checking the enemy in position
		var pos = 5 * row + col
		var enemy_unit = enemy_division.units[pos]
		if enemy_unit != null and enemy_unit.health > 0:
			self.target_unit = enemy_unit
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


## Helper method to add unit based on priority list
func add_unit_based_on_priority(units_found: Dictionary[int, LandUnit], current_unit: LandUnit):
	for priority_level in self.target_priority:
		var units: Array[LandUnit] = self.target_priority[priority_level]
		for unit in units: 
			## If unit is in the priority list, and no units of same priority has been found yet
			if unit.internal_name == current_unit.internal_name and not units_found.has(priority_level):
				units_found[priority_level] = current_unit
				return
		## If unit is not in priority list, and no unit has been selected for 'non-priority' yet
		# Note that we are storing 'non-priority' units at key 100
		if not units_found.has(100):
			units_found[100] = current_unit
	return

## Helper method to return the unit with highest priority
func choose_unit_based_on_priority(units_found: Dictionary[int, LandUnit]):
	var sorted_keys = units_found.keys()
	sorted_keys.sort()
	return units_found[sorted_keys[0]]
