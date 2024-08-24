@tool
extends Solid2
class_name Door2


## Controls the opening direction or style.
@export var open_method: open_methods

## Defines which shape the door will approach if open_method is set to CUSTOM.
## In this context, the entire door goes from (0, 0) to (1, 1).
@export var custom_method: Rect2 = Rect2(0.5, 0.5, 0, 0)

## Length of the opening animation in ticks (1/240 seconds).
@export var open_time: int = 120

## Length of the closing animation in ticks (1/240 seconds).
@export var close_time: int = 120

## Choose whether or not the gate fades away as it opens.
@export var fade: bool = false

enum open_methods {
	UP, LEFT, DOWN, RIGHT, CUSTOM
}
# Internal values for the 4 open method presets.
const UP_METHOD_TARGET: Rect2 = Rect2(0, 0, 1, 0)
const LEFT_METHOD_TARGET: Rect2 = Rect2(0, 0, 0, 1)
const DOWN_METHOD_TARGET: Rect2 = Rect2(0, 1, 1, 0)
const RIGHT_METHOD_TARGET: Rect2 = Rect2(1, 0, 0, 1)

# Adding @onready is required to make them react to the export variables.
@onready var open_timer: TickBasedTimer = TickBasedTimer.new(open_time)
@onready var close_timer: TickBasedTimer = TickBasedTimer.new(close_time)

var is_triggered: bool = false


func child_ready() -> void:
	open_timer.timeout.connect(open_timeout)
	
	close_timer.reversed = true
	if not Engine.is_editor_hint():
		GameLoop.update_timers.connect(update_timers)
		trigger_door()

func trigger_door() -> void:
	open_timer.reset_and_play()
	SFX.play("OpenDoor")
	is_triggered = true
	# Animation happens in the 'handle_animation' function.

func untrigger_door() -> void:
	is_triggered = false


func open_timeout() -> void:
	print("QUACK")
	set_sprite_size(Rect2(Vector2.ZERO, Vector2(size.x, -6)))


func update_timers() -> void:
	open_timer.tick_and_timeout()
	
	handle_animation(open_timer)



func sine_in(t: float) -> float:
	return 1.0 - cos((t * PI) / 2.0)

func sine_out(t: float) -> float:
	return sin((t * PI) / 2.0)

func sine_in_out(t: float) -> float:
	return -0.5 * (cos(PI * t) - 1)



func handle_animation(timer: TickBasedTimer) -> void:
	if timer.active:
		var original_rect: Rect2 = Rect2(Vector2.ZERO, size)
		var target_rect: Rect2
		
		match open_method:
			open_methods.UP:
				target_rect = UP_METHOD_TARGET
			open_methods.LEFT:
				target_rect = LEFT_METHOD_TARGET
			open_methods.DOWN:
				target_rect = DOWN_METHOD_TARGET
			open_methods.RIGHT:
				target_rect = RIGHT_METHOD_TARGET
			open_methods.CUSTOM:
				target_rect = custom_method
		
		target_rect.position *= self.size
		target_rect.size *= self.size
		
		var interpolated_rect: Rect2 = Rect2(
			lerp(original_rect.position, target_rect.position, sine_in(timer.get_progress())),
			lerp(original_rect.size, target_rect.size, sine_in(timer.get_progress()))
		)
		set_sprite_size(interpolated_rect)
		
		if tracking:
			print(interpolated_rect.size)
		
		if fade:
			set_merge_sprite(true)
			canvas_group.self_modulate.a = global_opacity * sine_in(timer.get_progress_left())
