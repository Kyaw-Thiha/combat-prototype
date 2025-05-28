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
