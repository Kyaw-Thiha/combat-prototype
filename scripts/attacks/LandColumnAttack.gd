extends LandBaseAttack
class_name LandColumnAttack

func _init(col: int, soft_damage: float, medium_damage: float, hard_damage: float) -> void:
	self.col = col
	self.soft_damage = soft_damage
	self.medium_damage = medium_damage
	self.hard_damage = hard_damage
