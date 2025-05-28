extends LandUnit
class_name StandardInfantry

func _init(row: int, col: int, health: float = 500):
	self.row = row
	self.col = col
	self.health = health
	self.soft_defense = 100
	self.soft_offense = 80
	self.medium_defense = 5
	self.medium_offense = 3
	self.hard_defense = 3
	self.hard_offense = 1
	self.air_damage = 0.01
	self.naval_damage = 0

func land_attack(damage_type: DamageType):
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

	return self.attacks.LandColumnAttack.new(self.col, soft_damage, medium_damage, hard_damage)
