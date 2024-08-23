@tool
extends Solid2
class_name Door2


## Controls the opening direction or style.
@export var open_method: open_methods = open_methods.RIGHT

## Length of the opening animation in ticks (1/240 seconds).
@export var open_time: int = 120

## Length of the closing animation in ticks (1/240 seconds).
@export var close_time: int = 120

## Choose whether or not the gate fades away as it opens.
@export var fade: bool = false

enum open_methods {
	UP, LEFT, DOWN, RIGHT, SHRINK, NONE
}

# Adding @onready is required to make them react to the export variables.
@onready var open_timer: TickBasedTimer = TickBasedTimer.new(open_time)
@onready var close_timer: TickBasedTimer = TickBasedTimer.new(close_time)

var is_triggered: bool = false


func child_ready() -> void:
	open_timer.timeout.connect(open_timeout)
	#close_timer.timeout.connect(close_timeout)
	
	close_timer.reversed = true
	if not Engine.is_editor_hint():
		GameLoop.update_timers.connect(update_timers)
		trigger_door()

func trigger_door() -> void:
	open_timer.reset_and_play()
	SFX.play("OpenDoor")
	is_triggered = true
	
	match open_method:
		open_methods.UP:
			pass
		open_methods.LEFT:
			pass
		open_methods.DOWN:
			pass
		open_methods.RIGHT:
			pass

func untrigger_door() -> void:
	is_triggered = false


func open_timeout() -> void:
	print("QUACK")
	set_sprite_size(Rect2(Vector2.ZERO, Vector2(size.x, -6)))


#func close_timeout() -> void:
#	pass

func update_timers() -> void:
	open_timer.tick_and_timeout()
	
	handle_animation(open_timer)


func handle_animation(timer: TickBasedTimer) -> void:
	if timer.active:
		match open_method:
			open_methods.UP:
				set_sprite_size(Rect2(Vector2.ZERO, Vector2(size.x, lerp(-outwards * 2.0, size.y, sine_in(timer.get_progress_left())))))
			open_methods.LEFT:
				set_sprite_size(Rect2(Vector2.ZERO, Vector2(lerp(-outwards * 2.0, size.x, sine_in(timer.get_progress_left())), size.y)))
			open_methods.DOWN:
				set_sprite_size(Rect2(Vector2(0, lerp(-outwards * 2.0, size.y, -sine_in(timer.get_progress_left()) + 1) + outwards * 2), \
						Vector2(size.x, lerp(-outwards * 2.0, size.y, sine_in(timer.get_progress_left())))))
			open_methods.RIGHT:
				set_sprite_size(Rect2(Vector2(lerp(-outwards * 2.0, size.y, -sine_in(timer.get_progress_left()) + 1) + outwards * 2, 0), \
						Vector2(lerp(-outwards * 2.0, size.x, sine_in(timer.get_progress_left())), size.y)))
		
		
		if fade:
			set_merge_sprite(true)
			canvas_group.self_modulate.a = global_opacity * sine_in(timer.get_progress_left())
			

func sine_in(t: float) -> float:
	return sin((t * PI) / 2.0)

func sine_out(t: float) -> float:
	return 1.0 - cos((t * PI) / 2.0)

func sine_in_out(t: float) -> float:
	return -0.5 * (cos(PI * t) - 1)
