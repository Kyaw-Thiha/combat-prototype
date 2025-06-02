extends Node
class_name GlobalEffect

var effects: Array[Array]

func _init() -> void:
	for i in range(25):
		effects.append([])
