extends Effect
class_name SmokeEffect

var multiplier: float

func _init(multiplier: float, duration: int = 1) -> void:
	self.multiplier = multiplier
	self.duration = duration

func apply(unit: LandUnit) -> void:
	unit.recon_value *= self.multiplier

func remove(unit: LandUnit) -> void:
	unit.recon_value /= self.multiplier
