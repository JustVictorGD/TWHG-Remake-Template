extends Node2D
class_name Collectable

@export var tracking: bool = false

enum states {
	UNCOLLECTED,
	PICKED_UP, # Goes back to UNCOLLECTED if the player dies
	SAVED
}

var collect_animation: TickBasedTimer = TickBasedTimer.new(24)
var drop_animation: TickBasedTimer = TickBasedTimer.new(24)

var state: states = states.UNCOLLECTED

func _init() -> void:
	GameLoop.update_timers.connect(update_timers)
	GlobalSignal.player_respawn.connect(player_respawn)

func collect() -> void:
	collect_animation.reset_and_play()
	if Collider.touched_checkpoint_ids.size() == 0:
		state = states.PICKED_UP
	else:
		state = states.SAVED

func drop() -> void:
	if state == states.PICKED_UP:
		state = states.UNCOLLECTED
		drop_animation.reset_and_play()

func save() -> void:
	if state == states.PICKED_UP:
		state = states.SAVED

func update_timers() -> void:
	collect_animation.tick()
	drop_animation.tick()
	
	if state != states.UNCOLLECTED:
		if collect_animation.active:
			modulate.a = collect_animation.get_progress_left()
		else:
			modulate.a = 0
	
	if drop_animation.active:
		modulate.a = drop_animation.get_progress()

func player_respawn() -> void:
	drop()
