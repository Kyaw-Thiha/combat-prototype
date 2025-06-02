extends Control
class_name Division

const row_num = 5
const col_num = 5

## A 5x5 2D array of units
## Note that this is a linear array storing 2D info
@export var units: Array[LandUnit]

var ui: Panel
func _ready() -> void:
	self.ui = Panel.new()
	self.custom_minimum_size = Vector2(200, 300)
	
	render_division()
	
	self.add_child(self.ui)
	
	#print_ui_children(self)

func render_division():
	var margin_container = MarginContainer.new()
	var vline = VBoxContainer.new()
	
	print("units: ", self.units)
	for row in range(5):
		var hline = HBoxContainer.new();
		for col in range(5):
			var unit = self.units[row * 5 + col]
			var btn = Button.new()
			if unit != null:
				btn.text = "%d, %d, Health: %f" % [row, col, unit.health]
			btn.custom_minimum_size = Vector2(180, 50)
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
			hline.add_child(btn)
		vline.add_child(hline)
	
	margin_container.add_child(vline)
	self.ui.add_child(margin_container)

func print_ui_children(node: Node, level: int = 0) -> void:
	for child in node.get_children():
		if child is Control:
			print(str(level), ". UI Child: ", child.name)
		print_ui_children(child, level+1)  # Recursive


func _init(init_units: Array[LandUnit] = []):
	#for row in range(row_num):
		#for col in range(col_num):
			#if len(init_units) == 0:
				#units.append(null)
			#else:
				#units.append(init_units[row_num * row + col_num])
	if len(init_units) == 0:
		self.units.append(null)
	else:
		self.units.append_array(init_units)
	print(self.units)

## Collect the attacks of all of its units, and return it
func attack(context: LandCombatContext):
	var attacks: Array[LandAttack] = []
	for row in range(5):
		for col in range(5):
			var unit = units[5 * row + col]
			if unit != null:
				var damages = unit.land_attack(context)
				attacks.append_array(damages)
	return attacks

## Collect recon values of all units in the division
## Note that the return value could be greater than 1
func get_total_recon_value() -> float:
	var total_recon_value = 0
	for row in range(5):
		for col in range(5):
			var unit = units[5 * row + col]
			if unit != null:
				total_recon_value += unit.recon_value
	return total_recon_value

## Method to apply damage to units from enemy attacks
func apply_damage(attacks: Array[LandAttack], source: Division, recon_value: float):
	for attack in attacks:
		if attack.target_unit != null and attack.target_unit.health > 0:
			# print("Applying damage to ", attack.target_unit.row, attack.target_unit.col)
			attack.target_unit.apply_Land_damage(attack, recon_value)
		else:
			# If the targeted enemy is dead, choose the next target
			var result = attack.source_unit.find_targets(self, attack)
			print("Result: ", result)
			if len(result) != 0:
				if result[0] == null:
					break     # no enemies left
				else:
					attack.target_unit.apply_Land_damage(attack, recon_value)
	
	render_division()
	return

## Method to check if division is wiped out
func check_if_wiped_out():
	for row in 5:
		for col in 5:
			var unit = self.units[row * 5 + col]
			if unit != null and unit.health > 0:
				return false
	return true
