extends Node2D

var inf_metronome: TickBasedTimer = TickBasedTimer.new(0)
var reverse_metronome: TickBasedTimer = TickBasedTimer.new(120)

func _ready() -> void:
	GameLoop.update_timers.connect(update_timers)
	
	# Demonstrating what would happen with a metronome with duration of zero.
	# Spoiler: The game prevents it from restarting itself and shows a non-lethal error.
	inf_metronome.metronome = true
	inf_metronome.reset_and_play()
	
	reverse_metronome.reversed = true
	reverse_metronome.metronome = true
	reverse_metronome.reset_and_play()
	
	reverse_metronome.timeout.connect(timeout)


func update_timers() -> void:
	reverse_metronome.tick_and_timeout()
	# Un-comment the line below to see how reversed timers count up instead of down.
	#print(reverse_metronome.remaining_time, "/", reverse_metronome.duration)

func timeout() -> void:
	print("  Tick.")
