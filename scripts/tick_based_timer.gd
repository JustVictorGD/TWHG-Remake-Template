extends RefCounted
class_name TickBasedTimer

signal timeout

var active : bool = false
var duration : int
var remaining_time : int

func _init(_duration : int) -> void:
	duration = _duration
	remaining_time = duration

func reset_and_play() -> void:
	active = true
	remaining_time = duration

func tick() -> void:
	if active:
		if remaining_time > 0:
			remaining_time -= 1
			
			if remaining_time <= 0:
				timeout.emit()
				active = false
				remaining_time = duration

func get_progress() -> float: # Gradually rises from 0 at start to 1 at end
	return 1 - (remaining_time / float(duration))

func get_progress_left() -> float: # Gradually drops from 1 at start to 0 at end
	return remaining_time / float(duration)
