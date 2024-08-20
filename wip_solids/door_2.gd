@tool
extends Solid2
class_name Door2




# ## Controls the starting state of the door. If this is false, the door will close when triggered, instead of opening.
# @export var starts_closed: bool = true
## Controls the opening direction or style.
@export var open_method: open_methods = open_methods.RIGHT

## Length of the opening animation in ticks (1/240 seconds).
@export var open_time: int = 240

## Length of the closing animation in ticks (1/240 seconds).
@export var close_time: int = 120

## Choose whether or not the gate fades away as it opens.
@export var fade: bool = false

enum open_methods {
	UP, LEFT, DOWN, RIGHT, SHRINK, NONE
}

var open_timer: TickBasedTimer = TickBasedTimer.new(open_time)
var close_timer: TickBasedTimer = TickBasedTimer.new(close_time)

var is_triggered: bool = false


func child_ready() -> void:
	open_timer.timeout.connect(open_timeout)
	
	close_timer.reversed = true

func trigger_door() -> void:
	pass

func untrigger_door() -> void:
	pass


func open_timeout() -> void:
	pass

func close_timeout() -> void:
	pass
