extends Node
class_name LandUnit

# Division (10k to 20k people) contains 3+ brigades
# Brigade (3k to 5k) contains 2-5 battalions
# Regiment (1k to 3k) contains 2-3 battalions
# Battalion (300 to 1000) contains (3-5 companies)
# Company (100 to 200) contains 3-5 platoons
# Platoon (20 to 50) 

# The unit class represent a 


# Health: 
# - Number of personals for infantry units
# - Number of vehicles for armoured units
# - Number of artillery piece for artillery units
# Soft Damage:
# - Amount of damage dealt to infantry units
# - Represents the number of enemy personals eliminated per combat round
# Medium Damage:
# - Amount of damage dealt to artillery units
# - Represents the number of enemy guns destroyed per combat round
# Hard Damage:
# - Amount of damage dealt to armoured units
# - Represents the number of enemy vehicles destroyed per combat round

@export var health:float  
@export var soft_defense:float
@export var soft_offense:float
@export var medium_defense:float
@export var medium_offense:float
@export var hard_defense:float
@export var hard_offense:float
@export var air_damage:float
@export var naval_damage:float

var row:int
var col:int

enum DamageType {DEFENSE, OFFENSE}

# Function definitions for different attack types
func land_attack(damage_type: DamageType) -> LandBaseAttack:
	return LandBaseAttack.new()
func air_attack():
	pass
func naval_attack():
	pass
