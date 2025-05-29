extends Node
class_name  LandAttack

var soft_damage: float
var medium_damage: float
var hard_damage: float

enum AttackType {COLUMN, ROW, FIXED}
var attack_type: AttackType = AttackType.FIXED

var attack_targets: Array[AttackTarget]

func _init(soft_damage = 0.0, medium_damage = 0.0, hard_damage = 0.0, attack_type = AttackType.FIXED, attack_targets: Array[AttackTarget] = []) -> void:
	self.soft_damage = soft_damage
	self.medium_damage = medium_damage
	self.hard_damage = hard_damage
	self.attack_type = attack_type
	self.attack_targets = attack_targets

func apply_column_targets(col: int, recon_effects: Array[float]):
	self.attack_type = AttackType.COLUMN
	for row in range(5):
		var target = AttackTarget.new(row, col, recon_effects[row])
		self.attack_targets.append(target)
	return self.attack_targets

func apply_row_targets(row: int, recon_effects: Array[float]):
	for col in range(5):
		self.attack_type = AttackType.ROW
		var target = AttackTarget.new(row, col, recon_effects[row])
		self.attack_targets.append(target)
	return self.attack_targets
