extends Node
class_name LandAttackTarget

enum TargetAlgorithm {COLUMN, ROW, FIXED}
var target_algorithm: TargetAlgorithm = TargetAlgorithm.ROW

enum SearchDirection {LEFT, RIGHT, UP, DOWN}
var search_direction: SearchDirection = SearchDirection.LEFT

var priority_list: Array 

func _init(target_algorithm: TargetAlgorithm, search_direction: SearchDirection, priority_list: Array = []) -> void:
	self.target_algorithm = target_algorithm
	self.search_direction = search_direction
	self.priority_list = priority_list

## Method to find target based on the algorithm
## Return
## - null if no need to do any damage
## - -1 if enemy division has been wiped out
## - else will return target position
func find_target(enemy_division: Division, search_direction: SearchDirection, target_pos: int):
	if self.target_algorithm == TargetAlgorithm.ROW:
		self.target_algorithm = TargetAlgorithm.ROW
		self.search_direction = search_direction
		return set_row_target(enemy_division, search_direction, target_pos)
		
	elif self.target_algorithm == TargetAlgorithm.COLUMN:
		self.target_algorithm = TargetAlgorithm.COLUMN
		self.search_direction = search_direction
		return self.set_col_target(enemy_division)
	
	elif self.target_algorithm == TargetAlgorithm.FIXED:
		return null

## Method to find target by going through the row
## Will return position (5 * col + row) if found
## Else will return -1 if no target found (ie enemy division is empty)
## Row attack is mainly done by infantry units
func set_row_target(enemy_division: Division, search_direction: SearchDirection, target_row: int = -1) -> int:
	self.target_algorithm = TargetAlgorithm.ROW
	self.search_direction = search_direction
	
	var col = 0
	var row = 0
	# if row is already set, start from there
	if target_row == -1:
		row = 0
	else:
		row = target_row

	while col < 5 and row < 5:
		# Checking the enemy in position
		var pos = 5 * row + col
		var enemy_unit = enemy_division.units[pos]
		if enemy_unit != null and enemy_unit.health > 0:
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
