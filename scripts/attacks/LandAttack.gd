extends Node
class_name  LandAttack

## Damage value against the enemy target
var soft_damage: float
var medium_damage: float
var hard_damage: float

## Source unit of the attack
var source_unit: LandUnit

## Target unit of the attack
var target_unit: LandUnit

## Determines whether or not the damage values are affected by recon
var is_recon_affected: bool = false

## Effects
var effects: Array[Effect] = []

func _init(soft_damage = 0.0, medium_damage = 0.0, hard_damage = 0.0, source_unit: LandUnit = null, target_unit:LandUnit = null, is_recon_affected: bool = false) -> void:
	self.soft_damage = soft_damage
	self.medium_damage = medium_damage
	self.hard_damage = hard_damage
	self.source_unit  = source_unit
	self.target_unit = target_unit
	self.is_recon_affected = is_recon_affected

## Helper method to copy itself, and return a new object
func copy():
	return LandAttack.new(self.soft_damage, self.medium_damage, self.hard_damage, self.source_unit, self.target_unit, self.is_recon_affected)

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

## Helper methods to find target for most common attack algorithms

## Method to find target by going through the row
## Row attack is mainly done by infantry units
## Return:
## - enemy_unit if found
## - null if no target found (ie enemy division is empty)
##
## Parameters:
## - enemy_division: The enemy division that will be targeted
## - priority: A dictionary of priority to select enemy units
## - row: A starting row to start the search on
## - exclude_list: A list of enemy units to exclude from targeting
func set_row_target(enemy_division: Division, priority: Dictionary[int, Array], row = -1, exclude_list: Array[LandUnit] = []) -> LandUnit:
	var units_found: Dictionary[int, LandUnit] = {}   # Dictionary of found units based on priority level
	var col = self.source_unit.col
	# if target unit is already set, start from there
	if row == -1: 
		if self.target_unit != null:
			row = self.target_unit.row
		else: 
			row = 0
	
	## Finding the row where unit exists
	var found = false
	var row_count = 0
	while row_count < 5 and not found:
		for i in range(5):
			var pos = 5 * row + i
			var enemy_unit = enemy_division.units[pos]
			if enemy_unit != null and enemy_unit.health > 0 and enemy_unit not in exclude_list:
				found = true
		## If no unit found in this row, go to the next one
		if not found:
			row += 1
			row_count += 1
			if row >= 5:
				row = 0

	# If there is no row with a unit, return null
	if not found:
		return null
	
	var count = 0      # count to stop the loop when we get back to starting col
	while count < 5:
		var pos = 5 * row + col
		var enemy_unit = enemy_division.units[pos]
		if enemy_unit != null and enemy_unit.health > 0 and enemy_unit not in exclude_list:
			# If no priority is set, return the first enemy unit found
			if priority.is_empty():
				self.target_unit = enemy_unit
				return enemy_unit
			# If priority is set, add the unit to necessary priority
			add_unit_based_on_priority(units_found, priority, enemy_unit)
		
		# Incrementing the column to the next column
		col += 1
		if col >= 5:
			col = 0
		count += 1
	
	# Choose the unit with highest priority
	self.target_unit = choose_unit_based_on_priority(units_found)
	return self.target_unit

## Method to find target by going through the column
## Column attack is mainly done by armoured units
## 
## Return
## - enemy_unit if found
## - null if no target found (ie enemy division is empty)
##
## Parameters:
## - enemy_division: The enemy division that will be targeted
## - search_direction: Search direction of the column - left or right
## - col: A starting col to start the search on
enum ColSearchDirection {LEFT, RIGHT}
func set_col_target(enemy_division: Division, search_direction: ColSearchDirection, col:int = 0) -> LandUnit:
	var unit_found = false
	var row = 0
	var count = 0      # count to stop the loop when we get back to starting col
	while count < 5:
		# Checking the enemy in position
		var pos = 5 * row + col
		var enemy_unit = enemy_division.units[pos]
		if enemy_unit != null and enemy_unit.health > 0:
			self.target_unit = enemy_unit
			return enemy_unit
		
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
			
	return null  # if not found

## A method to search through the grid of the enemy unit
## Grid attack is done by priority-focused units like snipers
##
## Returns
## - enemy_unit if found
## - null if no target found (ie enemy division is empty)
##
## Parameters
## - enemy_division: The enemy division that will be targeted
## - search_direction: Direction to search the grid on - row by row or column by column
## - priority: A dictionary of priority to select enemy units
## - exclude_list: A list of enemy units to exclude from targeting
enum GridSearchDirection {ROW, COL}
func set_grid_target(enemy_division: Division, search_direction: GridSearchDirection, priority: Dictionary[int, Array], exclude_list: Array[LandUnit] = []):
	var row = 0
	var col = 0
	var count = 0
	var units_found: Dictionary[int, LandUnit] = {}   # Dictionary of found units based on priority level

	while count < 5:
		var pos = 5 * row + col
		var enemy_unit = enemy_division.units[pos]
		if enemy_unit != null and enemy_unit.health > 0 and enemy_unit not in exclude_list:
			# If no priority is set, return the first enemy unit found
			if priority.is_empty():
				self.target_unit = enemy_unit
				return enemy_unit
			# If priority is set, add the unit to necessary priority
			add_unit_based_on_priority(units_found, priority, enemy_unit)
		
		## Going to the next cell
		if search_direction == GridSearchDirection.ROW:
			col += 1
			if col >= 5:
				col = 0
				row += 1
				if row >= 5:
					row = 0
				count += 1
		elif search_direction == GridSearchDirection.COL:
			row += 1
			if row >= 5:
				row = 0
				col += 1
				if col >= 5:
					col = 0
				count += 1
	
	## Choose the target with highest priority
	self.target_unit = choose_unit_based_on_priority(units_found)
	return self.target_unit

## Helper method to add unit based on priority list
func add_unit_based_on_priority(units_found: Dictionary[int, LandUnit], priority: Dictionary[int, Array], current_unit: LandUnit):
	for priority_level in priority:
		var units: Array[LandUnit] = priority[priority_level]
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
func choose_unit_based_on_priority(units_found: Dictionary[int, LandUnit]) -> LandUnit:
	var sorted_keys = units_found.keys()
	sorted_keys.sort()
	return units_found[sorted_keys[0]]
