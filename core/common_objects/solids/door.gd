@tool
extends Solid
class_name Door

## Debug purposes.
@export var tracking: bool = false

## Controls the opening direction or style.
@export var open_method: open_methods

## Defines which shape the door will approach if open_method is set to Custom.
## In this context, the entire door goes from (0, 0) to (1, 1).
@export var custom_method: Rect2 = Rect2(0.5, 0.5, 0, 0)

## Length of the opening animation in frames (1/60 seconds).
@export var open_time: int = 30

## Length of the closing animation in frames (1/60 seconds).
@export var close_time: int = 15

## Choose whether or not the door fades away as it opens.
@export var fade: bool = false

enum open_methods {
	UP, LEFT, DOWN, RIGHT, CUSTOM
}
# Internal values for the 4 open method presets.
const INTERNAL_METHODS: Array[Rect2] = [
	Rect2(0, 0, 1, 0),
	Rect2(0, 0, 0, 1),
	Rect2(0, 1, 1, 0),
	Rect2(1, 0, 0, 1)
]

# Adding @onready is required to make them react to the export variables.
@onready var open_timer: TickBasedTimer = TickBasedTimer.new(open_time)
@onready var close_timer: TickBasedTimer = TickBasedTimer.new(close_time)

var triggered: bool = false


func _ready() -> void:
	# Call the _ready() function from the Solid class.
	super()
	
	if not Engine.is_editor_hint():
		GameLoop.update_timers.connect(update_timers)


func trigger_door() -> void:
	# Don't trigger while already triggered.
	if not triggered:
		open_timer.reset_and_play()
		
		nullify_hitbox()
		
		SFX.play("OpenDoor")
		triggered = true


func untrigger_door() -> void:
	# Don't untrigger while already not triggered.
	if triggered:
		close_timer.reset_and_play()
		
		World.walls[hitbox_index] = Rect2i(global_bound)
		
		SFX.play("CloseDoor")
		triggered = false


func update_timers() -> void:
	open_timer.tick_and_timeout()
	close_timer.tick()
	
	if open_timer.active:
		handle_animation(open_timer.get_progress_left())
	
	if close_timer.active:
		if close_timer.get_progress_left() <= 0:
			close_timer.handle_timeout()
			handle_animation(1)
		else:
			handle_animation(close_timer.get_progress())

func sine_in(t: float) -> float:
	return 1.0 - cos((t * PI) / 2.0)

func sine_out(t: float) -> float:
	return sin((t * PI) / 2.0)

func sine_in_out(t: float) -> float:
	return -0.5 * (cos(PI * t) - 1)


func handle_animation(progress_left: float) -> void:
	if fade:
		modulate.a = progress_left
	
	progress_left = sine_in_out(progress_left)
	
	var target_rect: Rect2
	
	if open_method != open_methods.CUSTOM:
		target_rect = INTERNAL_METHODS[open_method]
	else:
		target_rect = custom_method
	
	var distortion: Rect2 = Rect2(
		lerp(target_rect.position, Vector2.ZERO, progress_left),
		lerp(target_rect.size, Vector2.ONE, progress_left),
	)
	
	change_shape(distort_rect(outer_bound, distortion))


func distort_rect(rect: Rect2, distortion: Rect2) -> Rect2:
	return Rect2(Vector2(
		lerp(rect.position.x, rect.end.x, distortion.position.x),
		lerp(rect.position.y, rect.end.y, distortion.position.y)),
		rect.size * distortion.size)
