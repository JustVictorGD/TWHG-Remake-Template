extends Node2D
class_name Collectable

## Print debug information. (WIP, does nothing)
@export var tracking: bool = false
## Lock scale even if a parent changes its scale.
@export var lock_scale: bool = false
## Lock rotation even if a parent changes its rotation.
@export var lock_rotation: bool = false
## Play sound when collected.
@export var plays_sound: bool = true

@export var sound: SFX.sounds = SFX.sounds.NONE

enum states {
	UNCOLLECTED,
	PICKED_UP, # Goes back to UNCOLLECTED if the player dies
	SAVED
}

var collect_animation: TickBasedTimer = TickBasedTimer.new(6)
var drop_animation: TickBasedTimer = TickBasedTimer.new(6)

var state: states = states.UNCOLLECTED


func _ready() -> void:
	print("Calling _ready()... somehow?")
	
	drop_animation.timeout.connect(finish_animation)
	
	GameLoop.update_timers.connect(update_timers)
	GameLoop.movement_update.connect(movement_update)
	
	GlobalSignal.checkpoint_touched.connect(checkpoint_touched)
	GlobalSignal.player_respawn.connect(player_respawn)


func try_collect() -> void:
	if state == states.UNCOLLECTED:
		collect()


func try_drop() -> void:
	if state == states.PICKED_UP:
		drop()


func try_save() -> void:
	if state == states.PICKED_UP:
		save()


func collect() -> void:
	if Collider.touched_checkpoint_ids.size() == 0:
		state = states.PICKED_UP
	else:
		state = states.SAVED
	
	collect_animation.reset_and_play()
	
	if plays_sound:
		SFX.play(sound)
	
	GlobalSignal.anything_collected.emit()


func drop() -> void:
	state = states.UNCOLLECTED
	drop_animation.reset_and_play()


func save() -> void:
	state = states.SAVED


func movement_update() -> void:
	if lock_scale:
		global_scale = Vector2(1, 1)
	if lock_rotation:
		global_rotation = 0


func update_timers() -> void:
	if state != states.UNCOLLECTED:
		if collect_animation.active:
			modulate.a = collect_animation.get_progress_left()
		else:
			modulate.a = 0
	
	if drop_animation.active:
		modulate.a = drop_animation.get_progress()


func finish_animation() -> void:
	modulate.a = 1


func player_respawn() -> void:
	try_drop()


func checkpoint_touched(_id: int) -> void:
	try_save()
