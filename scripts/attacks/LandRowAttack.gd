extends LandBaseAttack
class_name LandRowAttack

func _init(row: int, soft_damage: float, medium_damage: float, hard_damage: float) -> void:
	self.row = row
	self.soft_damage = soft_damage
	self.medium_damage = medium_damage
	self.hard_damage = hard_damage
