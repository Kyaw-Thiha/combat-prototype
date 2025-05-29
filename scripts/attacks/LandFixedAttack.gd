extends LandAttack
class_name LandFixedAttack

func _init(row:int, col: int, soft_damage: float, medium_damage: float, hard_damage: float) -> void:
	self.row = row
	self.col = col
	self.soft_damage = soft_damage
	self.medium_damage = medium_damage
	self.hard_damage = hard_damage
