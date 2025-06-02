extends LandUnit
class_name StandardInfantry

var recon_effects = [0, 0, 0, 0.1, 0.2]

func _init(row: int, col: int, health: float = 500, combat_readiness: float = 1, experience: float = 0):
	self.row = row
	self.col = col
	self.health = health
	self.soft_defense = 100
	self.soft_offense = 80
	self.medium_defense = 5
	self.medium_offense = 3
	self.hard_defense = 3
	self.hard_offense = 1
	self.defense = 0
	self.armour_class = ArmourClass.SOFT
	self.target_algorithm = TargetAlgorithm.ROW
	self.air_damage = 0.01
	self.naval_damage = 0
	
	self.recon_value = 0.02
	self.concealment_value = 0
	self.combat_readiness = 1
	self.experience = experience

func _apply_experience(attack: LandAttack):
	return attack
