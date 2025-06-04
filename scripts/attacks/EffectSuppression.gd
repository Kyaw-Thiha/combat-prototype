extends Effect
class_name SuppressionEffect

var multiplier: float

func _init(multiplier: float, duration: int = 1) -> void:
	self.multiplier = multiplier
	self.duration = duration

func apply(unit: LandUnit) -> void:
	unit.soft_defense *= self.multiplier
	unit.soft_offense *= self.multiplier
	unit.medium_defense *= self.multiplier
	unit.medium_offense *= self.multiplier
	unit.hard_defense *= self.multiplier
	unit.hard_offense *= self.multiplier

func remove(unit: LandUnit) -> void:
	unit.soft_defense /= self.multiplier
	unit.soft_offense /= self.multiplier
	unit.medium_defense /= self.multiplier
	unit.medium_offense /= self.multiplier
	unit.hard_defense /= self.multiplier
	unit.hard_offense /= self.multiplier
