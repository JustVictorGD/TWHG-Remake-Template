extends RefCounted
class_name TickBasedTimer

signal timeout

# You're meant to set these 2 properties manually!
var metronome: bool = false
var reversed: bool = false

# Ideally not these, though.
var active: bool = false
var duration: int
var remaining_time: int


func _init(_duration: int, _metronome: bool = false, _reversed: bool = false) -> void:
	duration = _duration
	metronome = _metronome
	reversed = _reversed
	
	if not reversed:
		remaining_time = duration


func _to_string() -> String:
	var extra: String = ""
	
	if metronome and reversed:
		extra = ", Reversed Metronome"
	
	elif metronome:
		extra = ", Metronome"
	
	elif reversed:
		extra = ", Reversed"
	
	return str("[Active: ", active, ", Progress: ", remaining_time, "/", duration, extra, "]")


func reset_and_play() -> void:
	active = true
	
	if duration <= 0:
		handle_timeout() # Zero duration timers send timeout signals immediately.
	
	if not reversed:
		remaining_time = duration
	else:
		remaining_time = 0


func tick() -> void:
	if active:
		if not reversed:
			remaining_time -= 1
		else:
			remaining_time += 1


func handle_timeout() -> void:
	if active:
		if (not reversed and remaining_time <= 0) or (reversed and remaining_time >= duration):
			active = false
			timeout.emit()
			
			if metronome:
				if duration > 0:
					reset_and_play()
				else:
					push_error("A metronome with no cooldown has been prevented from \
							restarting itself to avoid an infinite loop. Make sure \
							the duration is above zero when working with metronomes.")

# Combined for convenience. It's rare to need these 2 functions to be separate.
func tick_and_timeout() -> void:
	tick()
	handle_timeout()


func get_progress() -> float: # Gradually rises from 0 at start to 1 at end
	return 1 - (remaining_time / float(duration))


func get_progress_left() -> float: # Gradually drops from 1 at start to 0 at end
	return remaining_time / float(duration)
