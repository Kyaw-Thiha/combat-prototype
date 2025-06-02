extends Node
class_name LandUnit

# Division (10k to 20k people) contains 3+ brigades
# Brigade (3k to 5k) contains 2-5 battalions
# Regiment (1k to 3k) contains 2-3 battalions
# Battalion (300 to 1000) contains (3-5 companies)
# Company (100 to 200) contains 3-5 platoons
# Platoon (20 to 50) 

# The unit class represent a 

## 
enum UnitNames {
	StandardInfantry
}
@export var internal_name: UnitNames


## Health: 
## - Number of personals for infantry units
## - Number of vehicles for armoured units
## - Number of artillery piece for artillery units
@export var health:float  

# Soft Damage:
# - Amount of damage dealt to infantry units
# - Represents the number of enemy personals eliminated per combat round
# Medium Damage:
# - Amount of damage dealt to artillery units
# - Represents the number of enemy guns destroyed per combat round
# Hard Damage:
# - Amount of damage dealt to armoured units
# - Represents the number of enemy vehicles destroyed per combat round
@export var soft_defense:float
@export var soft_offense:float
@export var medium_defense:float
@export var medium_offense:float
@export var hard_defense:float
@export var hard_offense:float
@export var air_damage:float
@export var naval_damage:float

## Defense
## Subtractive multiplier to enemy's attack
@export var defense: float

## Armour class
enum ArmourClass {SOFT, MEDIUM, HARD}
@export var armour_class: ArmourClass

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
var target_algorithm: TargetAlgorithm = TargetAlgorithm.ROW

## Target Priority
## A priority system used to select different targets based on their preferred priority
## - It is in a dictionary of array of internal_name of units
## - Key 0 represents the units with highest priority
## - Units not included among the keys will be considered as 'non-priority', 
##   and will be represented with key 100 in internal process
var target_priority: Dictionary[int, Array] = {}

## Damage Drop-Off Multiplier
## - To prevent more units = more power
## - Values between 1 and 0
## - Will be multiplied to damage dealt (1.0 means full damage)
## - Index represents relative position of unit (0 index is first unit) 
## - Different units will have different damage drop-off rates
# Default rate ensures that maximum damage dealt by full column is 3 * combat power
@export var damage_drop_off: Array[float] = [1.0, 0.8, 0.6, 0.4, 0.2] 
# Alternative: 1, 0.8, 0.4, 0.2, 0.1

## Recon Value
## Amount of recon value that the unit contributes when in combat
## Note that
## - Total recon value of a division will always be between 0 and 1
## - Recon value will be directly multiplied to the attack types that rely on it 
## - This recon value from the unit will be modified by both its division, and the combat system
@export var recon_value:float

## Concealment Value
## Amount of concealment that the unit has
## - This is the value that will be subtracted to the recon value of enemy's divisions
## - Should be between 0 and 1
## - This value is NOT applied to the whole division, but rather only on a single unit only
## - Most units have concealment value of 0
@export var concealment_value:float = 0

## Combat Readiness
## Amount of combat readiness that a unit has
## Note that
## - By default combat readiness is at 1.0
## - Combat readiness is always between 0 and 1
## Affected by
## - If the division retreated, it will have less combat readiness
## - After every combat round, the combat readiness of a unit will decrease slightly
## - Force marching will decrease the combat readiness
## - Removing/Adding units to the division will affect the combat readiness massively
## - Certain units will have non-linear rate of combat readiness decay value
@export var combat_readiness:float = 1

## Experience
## How experienced a unit is based on combat and training
## Note that
## - Starting experience of all units are 1
## - Different units will have different effects at different experience level
##   (With some having huge effects at higher experience than others)
## - Experience increasing rate depends on each unit
## - Experience effects are applied when unit gets to specific integers like 1, 2 
##   (not proprotional to the float value)
## - The effects are experience are applied in the attack functions
@export var experience:float = 0

## Row & Column representing the position of the unit on the division grid
var row:int
var col:int

enum DamageType {DEFENSE, OFFENSE}

# Function definitions for different attack types
#func land_attack(context: LandCombatContext) -> LandAttack:
	#return LandAttack.new()
func air_attack():
	pass
func naval_attack():
	pass

func land_attack(context: LandCombatContext) -> Array[LandAttack]:
	# Getting the damage values based on damage type
	var damages = self._get_land_attack(context.damage_type)
	print("Row: ", self.row, "Col: ", self.col)
	var attack = LandAttack.new(damages[0], damages[1], damages[2], self)
	
	# Applying damage drop-off based on the unit's position
	attack.set_damage_drop_off(context.player_division, self.damage_drop_off, self.row, self.col)
	
	# Finding the enemy target
	return find_targets(context.enemy_division, attack)


## Targetting method to get the enemy unit positions on the attacks
## To check if the method is being called when the unit is attacking, or if called when enemy is applyihng damage,
## check the attack.target_unit property.
## If the property is null, it is called when the unit is attacking
## 
## Note that this is the method that is to be overriden in units with very unique attacks
## - If no enemy is left, will return [null]
## - If attack is not to be applied (for fixed attacks like heavy artillery), will return empty array []
func find_targets(enemy_division: Division, attack: LandAttack) -> Array[LandAttack]:
	var result: LandUnit = null
	if self.target_algorithm == TargetAlgorithm.ROW:
		result = attack.set_row_target(enemy_division, self.target_priority)
	elif self.target_algorithm == TargetAlgorithm.COLUMN or self.target_algorithm == TargetAlgorithm.COLUMNRIGHT or self.target_algorithm == TargetAlgorithm.COLUMNLEFT:
		if self.col <= 2:
			self.target_algorithm = TargetAlgorithm.COLUMNRIGHT
			result = attack.set_col_target(enemy_division, self.col, LandAttack.ColSearchDirection.RIGHT)
		else:
			self.target_algorithm = TargetAlgorithm.COLUMNLEFT
			result = attack.set_col_target(enemy_division, self.col, LandAttack.ColSearchDirection.LEFT)
	
	if result == null:
		return [null]
	return [attack]


## Method to apply incoming land damage from enemy units
func apply_Land_damage(attack: LandAttack, enemy_recon_value: float):
	# Choosing damage based on armour class
	var damage: float = 0
	match self.armour_class:
		ArmourClass.SOFT:
			damage = attack.soft_damage
		ArmourClass.MEDIUM:
			damage = attack.medium_damage
		ArmourClass.HARD:
			damage = attack.hard_damage

	# If attack is recon-based, apply the recon effect
	if attack.is_recon_affected:
		damage *= (enemy_recon_value - self.concealment_value)
	
	# Apply the damage
	self.health = self.health - (damage - self.defense)
	self.health = clampf(self.health, 0, self.health)   # Ensuring unit's health is not negative value



## Internal getter to return damage values based on damage type
func _get_land_attack(damage_type: DamageType) -> Array[float]:
	var soft_damage:float
	var medium_damage:float
	var hard_damage:float
	if (damage_type == self.DamageType.DEFENSE):
		soft_damage = self.soft_defense
		medium_damage = self.medium_defense
		hard_damage = self.hard_defense
	else:
		soft_damage = self.soft_offense
		medium_damage = self.medium_offense
		hard_damage = self.hard_offense
	return [soft_damage, medium_damage, hard_damage]
