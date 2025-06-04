extends Resource
class_name Effect

var name: String
var duration: int
var combat  # The combat that the effect is part of
var is_new: bool = true   # a flag to not apply effects that are immediately in the current round

func apply(unit: LandUnit) -> void:
	pass

func remove(unit: LandUnit) -> void:
	pass
