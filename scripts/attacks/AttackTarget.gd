extends Node
class_name AttackTarget

@export var row:int
@export var col:int

## Multiplier of how much recon affects the damage values
## 1 if recon fully affect the damage
## 0 if recon does not affect the damage at all
var recon_effect: float = 1

func _init(row: int, col: int, recon_effect: float) -> void:
	self.row = row
	self.col = col
	self.recon_effect = recon_effect
