extends Node

signal preparation_stage
signal animation_update
signal movement_update
signal collision_update
signal update_timers
signal final_polish

const TICK_LENGTH : float = 1/240.0
# Time
var time : float = 0
var ticks : int = 0
var seconds : int = 0
var minutes : int = 0
var hours : int = 0
# Interface
var time_string : String = str(hours) + (":%02d:%02d" % [minutes, seconds])
var tick_string : String = ".%03d" % [ticks]


func _process(delta: float) -> void:
	time += delta
	
	while time > TICK_LENGTH:
		time -= TICK_LENGTH
		ticks += 1
		
		internal_frame()
		
		while ticks >= 240:
			ticks -= 240
			seconds += 1
		while seconds >= 60:
			seconds -= 60
			minutes += 1
		while minutes >= 60:
			minutes -= 60
			hours += 1
		
		time_string = str(hours) + (":%02d:%02d" % [minutes, seconds])
		tick_string = ".%03d" % [ticks]

func internal_frame() -> void:
	preparation_stage.emit()
	animation_update.emit() # Non-player object movement with AnimationPlayer
	movement_update.emit() # Player movement and enemy position update
	collision_update.emit()
	update_timers.emit()
	final_polish.emit()



