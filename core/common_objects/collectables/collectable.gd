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

@export var save_behavior: save_behaviors = save_behaviors.NORMAL


enum states {
	UNCOLLECTED,
	PICKED_UP, # Goes back to UNCOLLECTED if the player dies
	SAVED
}

enum save_behaviors {
	NORMAL,
	AUTOMATIC_SAVE,
	UNSAVABLE
}

var hitbox: AbstractCollider

var collect_animation: TickBasedTimer = TickBasedTimer.new(6)
var drop_animation: TickBasedTimer = TickBasedTimer.new(6)

var state: states = states.UNCOLLECTED
var store_state: bool = true

var id: int

var group: String
var group_states: Array # Gets the states of all collectables in the same group.

func _ready() -> void:
	if not is_in_group("collectables"):
		push_warning("Node extending 'Collectable' expected to be in \"collectables\" group.")
	
	drop_animation.timeout.connect(finish_animation)
	
	if not Engine.is_editor_hint():
		GameLoop.update_timers.connect(update_timers)
		GameLoop.movement_update.connect(movement_update)
		
		GlobalSignal.checkpoint_touched.connect(checkpoint_touched)
		GlobalSignal.player_respawn.connect(player_respawn)


func try_collect() -> bool:
	if state == states.UNCOLLECTED:
		collect()
		return true
	
	return false


func try_drop() -> bool:
	if state == states.PICKED_UP:
		drop()
		return true
	
	return false


func try_save() -> bool:
	if state == states.PICKED_UP:
		save()
		return true
	
	return false


func stay_collected() -> void:
	state = states.SAVED
	hitbox.enabled = false
	modulate.a = 0


func collect() -> void:
	if Collider.touched_checkpoint_ids.size() == 0:
		state = states.PICKED_UP
	else:
		state = states.SAVED
	
	hitbox.enabled = false
	
	collect_animation.reset_and_play()
	
	if plays_sound:
		SFX.play(sound)
	
	if save_behavior == save_behaviors.AUTOMATIC_SAVE:
		save()
	
	update_state()
	
	GlobalSignal.anything_collected.emit()


func drop() -> void:
	state = states.UNCOLLECTED
	drop_animation.reset_and_play()
	hitbox.enabled = true
	update_state()
	



func save() -> void:
	if save_behavior == save_behaviors.UNSAVABLE:
		return
	
	state = states.SAVED
	update_state()

func update_state() -> void:
	if not store_state:
		return
	
	if group_states.size() == 0:
		push_warning("Collectable state array for group " + group + " is not created.")
		return
	
	group_states[id] = 1 if state == states.SAVED else 0

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
