extends Solid
class_name Door

# ## Controls the starting state of the door. If this is false, the door will close when triggered, instead of opening.
# @export var starts_closed: bool = true
## Controls the opening direction or style.
@export var open_method: open_methods = open_methods.RIGHT
## Length of the opening animation in ticks (1/240 seconds).
@export var open_time: int = 120
## Choose whether or not the gate fades away as it opens.
@export var fade: bool = false

@onready var open_timer: TickBasedTimer = TickBasedTimer.new(open_time)
@onready var close_timer: TickBasedTimer = TickBasedTimer.new(open_time)

var is_triggered: bool = false

var old_size: Vector2
var old_position: Vector2
var old_outline_size: int
var old_outline_position: Vector2

enum open_methods {
	UP, LEFT, DOWN, RIGHT, SHRINK, NONE
}

func child_ready() -> void:
	open_timer.timeout.connect(open_timeout)
	
	close_timer.reversed = true

func trigger_door() -> void:
	if not is_triggered:
		open_timer.reset_and_play()
		can_collide = false
		is_triggered = true
		SFX.play("Door")
		
		# Variables for animations
		old_size = size
		old_position = position
		old_outline_size = outline_size
		old_outline_position = outline.position

func untrigger_door() -> void:
	if is_triggered:
		can_collide = true
		is_triggered = false
		
		if not fade:
			modulate.a = 1
		close_timer.reset_and_play()
		
		SFX.play("Door")

func update_timers() -> void:
	if is_triggered:
		handle_animations(open_timer)
	else:
		handle_animations(close_timer)
	
	extra_update_timers()

func handle_animations(timer: TickBasedTimer) -> void:
	if timer.active:
		timer.tick_and_timeout()
		
		# AMAZING CODE!
		if open_method == open_methods.UP:
			size.y = old_size.y * ease(timer.get_progress_left(), -2) # Negative means IN-OUT easing
			
			
		elif open_method == open_methods.LEFT:
			size.x = old_size.x * ease(timer.get_progress_left(), -2) 
			
		elif open_method == open_methods.DOWN:
			size.y = old_size.y * ease(timer.get_progress_left(), -2)
			rotation = PI
			
		elif open_method == open_methods.RIGHT:
			size.x = old_size.x * ease(timer.get_progress_left(), -2)
			rotation = PI
			
		elif open_method == open_methods.SHRINK:
			@warning_ignore("narrowing_conversion")
			size = old_size * ease(timer.get_progress_left(), -2)
			position = old_position + old_size * ease(timer.get_progress(), -2) / 2
		
		elif open_method == open_methods.NONE:
			if not fade:
				modulate.a = 0
		
		if fade:
			modulate.a = timer.get_progress_left()

func open_timeout() -> void:
	print("A")
	modulate.a = 0

# Override these functions to add extra behaviour.
func extra_update_timers() -> void:
	pass
