@tool
extends Solid
class_name Door

## Internal values for the 4 open method presets.
const INTERNAL_METHODS: Array[Rect2] = [
	Rect2(0, 0, 1, 0),
	Rect2(0, 0, 0, 1),
	Rect2(0, 1, 1, 0),
	Rect2(1, 0, 0, 1)
]

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

## This is only exported so that it's detectable by AnimationPlayer nodes.
@export var progress_left: float = 1

var old_progress_left: float = 1

@onready var animation_player: AnimationPlayer = $AnimationPlayer


enum open_methods {
	UP, LEFT, DOWN, RIGHT, CUSTOM
}

var triggered: bool = false


func _ready() -> void:
	super()
	
	# The exact step is arbitrary. It just needs to happen before the player moves.
	if not in_editor:
		GameManager.animation_update.connect(handle_animation)


func stay_triggered() -> void:
	progress_left = 0
	
	nullify_hitbox()
	triggered = true


func trigger_door() -> void:
	# Don't trigger while already triggered.
	if not triggered:
		animation_player.play(&"open")
		animation_player.speed_scale = 1.0 / open_time * 60
		
		nullify_hitbox()
		
		SFX.play(SFX.sounds.OPEN_DOOR)
		triggered = true


func untrigger_door() -> void:
	# Don't untrigger while already not triggered.
	if triggered:
		animation_player.play(&"close")
		animation_player.speed_scale = 1.0 / close_time * 60
		
		GameManager.walls[hitbox_index] = Rect2i(global_bound)
		
		SFX.play(SFX.sounds.CLOSE_DOOR)
		triggered = false


func sine_in(t: float) -> float:
	return 1.0 - cos((t * PI) / 2.0)

func sine_out(t: float) -> float:
	return sin((t * PI) / 2.0)

func sine_in_out(t: float) -> float:
	return -0.5 * (cos(PI * t) - 1)


func handle_animation() -> void:
	if progress_left == old_progress_left:
		return # Avoiding unnecessary logic if no change happens.
	
	old_progress_left = progress_left
	
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
