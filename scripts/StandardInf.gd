extends Path2D

@onready var path_follow_2d = $PathFollow2D
@onready var state_chart = $PathFollow2D/StateChart
@onready var area_2d = $PathFollow2D/Area2D
@onready var animated_sprite_2d = $PathFollow2D/Area2D/AnimatedSprite2D
@onready var collision_shape_2d = $PathFollow2D/Area2D/CollisionShape2D

signal clicked(region)
signal shift_clicked(region)

# 10 is a pretty good value but for dev purposes, 50 will be used
@export var movement_speed = 50

var tween:Tween

var _is_selected = false
var position_difference = 0
var _target_rotation = 0
var current_rotation = 0

#func _ready():
	## Difference between initial postion of collision shape and the global position
	#position_difference = collision_shape_2d.global_position
#
#func _process(delta):
	## if there is movement path, then move
	#if self.curve.point_count > 0:
		## Moving the curve
		#path_follow_2d.progress += delta * movement_speed
		#
		## Drawing the path
		#queue_redraw()
		#
		#if path_follow_2d.progress_ratio == 1.0:
			## removing the path and redrawing the canvas
			#self.curve.clear_points()
			#path_follow_2d.progress = 0
			#queue_redraw()
			#
			## changing the state & animation
			#state_chart.send_event("idle")
#
#func _input(event):
	#if _is_selected:
		#if event.is_action_pressed("shift-move"):
			## Add start position if there are not previous points
			#if self.curve.point_count == 0:
				## Intially it is Vector.Zero
				## But as the character moves, the global position changes 
				#self.curve.add_point(collision_shape_2d.global_position - position_difference)
			## Add the new position
			#self.curve.add_point(get_global_mouse_position() - self.global_position)
			#state_chart.send_event("walk")
			#
		#elif event.is_action_pressed("move"):
			## Clear out previous path & progress
			#self.curve.clear_points()
			#path_follow_2d.progress = 0
			#
			## Add start position
			#self.curve.add_point(collision_shape_2d.global_position - position_difference)
			#
			#var target_point = get_global_mouse_position() - self.global_position
			## Add the new position
			#self.curve.add_point(target_point)
			#state_chart.send_event("walk")
		#
		## Handling Rotation
		#if event.is_action_pressed("rotate"):
			#handle_rotation()
#
#
## If there are enough points, draw the curve
#func _draw():
	#if self.curve.point_count > 1:
		#var current_position = collision_shape_2d.global_position - position_difference
		#
		## If the starting position has reached the 2nd point, remove it
		## We need this code for shift move
		## Note: This kinda feels like a workaround
		#var difference_threshold = Vector2(0.01, 0.01)
		#var vec_diff = current_position - self.curve.get_point_position(0)
		## Make the vector difference modulus
		#if vec_diff.x < 0:
			#vec_diff.x = -vec_diff.x
		#if vec_diff.y < 0:
			#vec_diff.y = -vec_diff.y
		##  If the vector difference is not zero and less than threshold,
		##  it shows that the current position has reached the 2nd point (index 1)
		#if vec_diff != Vector2.ZERO and vec_diff < difference_threshold:
			#self.curve.remove_point(0)
		#
		#
		## Edit the curve starting position to current position
		## This is the code that draws the path
		#self.curve.set_point_position(0, current_position)
		#path_follow_2d.progress = 0
		#
		## Draw the line
		#draw_polyline(self.curve.get_baked_points(), Color.SPRING_GREEN, 8, true)
#
## Handling selection actions
#func _on_area_2d_input_event(viewport, event, shape_idx):
	#if event.is_action_pressed("shift-select"):
		#shift_clicked.emit(self)
	#elif event.is_action_pressed("select"):
		#clicked.emit(self)
#
#
## Controlling the states
## When changed to idle while selected
#func _on_select_idle_taken():
	#animated_sprite_2d.play("attack")
## When changed to idle while unselected
#func _on_unselect_idle_taken():
	#animated_sprite_2d.play("idle")
#
## When selected in idle state
#func _on_select_when_idle_taken():
	#animated_sprite_2d.play("attack")
## When unselected in idle state
#func _on_unselect_taken():
	#animated_sprite_2d.play("idle")
#
## Walk
#func _on_walk_state_processing(delta):
	#animated_sprite_2d.play("walk")
## Combat
#func _on_combat_state_processing(delta):
	#animated_sprite_2d.play("combat")
#
#func select():
	#_is_selected = true
	#state_chart.send_event("select")
	#
#func deselect():
	#_is_selected = false
	#state_chart.send_event("unselect")
#
#func handle_rotation() -> void:
	## The new target rotation
	#_target_rotation = _target_rotation + 90
	#rotate_tween(_target_rotation)
	#
	## If the target gets 180deg rotation,
	## reset it and flip it
	#if _target_rotation >= 180:
		##Needs to be 180 here cox it was added by 90 earlier
		#_target_rotation = _target_rotation - 180 
		#rotate_tween(_target_rotation)
		#animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
#
#func rotate_tween(rotate_target: float) -> void:
	#if tween:
		#tween.kill()
	#tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	#tween.tween_property(area_2d, "rotation_degrees", rotate_target, 1)
	#
	#tween.finished.connect(set.bind("current_rotation", _target_rotation))  

#func smooth():
	#var point_count = self.curve.get_point_count()
	#for i in point_count:
		#var spline = _get_spline(i)
		#self.curve.set_point_in(i, -spline)
		#self.curve.set_point_out(i, spline)
#
#func _get_spline(i):
	#var spline_length = 50
	#var last_point = _get_point(i - 1)
	#var next_point = _get_point(i + 1)
	#var spline = last_point.direction_to(next_point) * spline_length
	#return spline
#
#func _get_point(i):
	#var point_count = self.curve.get_point_count()
	#i = wrapi(i, 0, point_count - 1)
	#return self.curve.get_point_position(i)
