extends HBoxContainer
class_name time_ui

var progress_value: int
var progress_bar: TextureRect


func _ready() -> void:
	self.progress = 0
	
	self.progress_bar = TextureRect.new()
	self.add_child(self.progress_bar)
	self.time_display = TextureRect.new()
	self.add_child(self.time_display)
