extends Node
class_name LandUnit

# Division (10k to 20k people) contains 3+ brigades
# Brigade (3k to 5k) contains 2-5 battalions
# Regiment (1k to 3k) contains 2-3 battalions
# Battalion (300 to 1000) contains (3-5 companies)
# Company (100 to 200) contains 3-5 platoons
# Platoon (20 to 50) 

# The unit class represent a 


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

enum DamageType {DEFENSE, OFFENHealthSE}

# Function definitions for different attack types
func land_attack(damage_type: DamageType) -> LandAttack:
	return LandAttack.new()
func air_attack():
	pass
func naval_attack():
	pass

## Internal getter to return damage values based on damage type
func _get_land_attack(damage_type: DamageType) -> Array[float]:
	var soft_damage:int
	var medium_damage:int
	var hard_damage:int
	if (damage_type == self.DamageType.DEFENSE):
		soft_damage = self.soft_defense
		medium_damage = self.medium_defense
		hard_damage = self.hard_defense
	else:
		soft_damage = self.soft_offense
		medium_damage = self.medium_offense
		hard_damage = self.hard_offense
	return [soft_damage, medium_damage, hard_damage]
