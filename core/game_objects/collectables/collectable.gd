extends GameObject2D
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

## Controls when the collectable state becomes saved. Not to be confused with Store Behavior.
@export var save_behavior: save_behaviors = save_behaviors.NORMAL

## Whether or not this collectable's state gets stored in the save file.
## Disable this if the collectable will be instanced in runtime.
@export var store_behavior: store_behaviors = store_behaviors.STORE_STATE

# Only really exists for paints, as they can both become semi-transparent
# from a special mode (ghost paints) and can have a fading animation.
var opacity_multiplier: float = 1.0

# Object creators call _ready() for the second time to make
# themes function properly, but it leads to unwanted repeats of code.
# This condition is false only for the first _ready() call.
var registered: bool = false

enum states {
	UNCOLLECTED,
	PICKED_UP, # Goes back to UNCOLLECTED if the player dies
	SAVED
}

enum save_behaviors {
	NORMAL, ## Collecting and saving work as normal.
	AUTOMATIC_SAVE, ## Automatically saves when collected, won't get dropped on death.
	UNSAVABLE ## Saving is completely disabled.
}

enum store_behaviors {
	STORE_STATE, ## Stores the collectable's state as a separate number
	INCREMENT_TOTAL, ## Increments the total collected collectables in the group. Currently only supported for coins. Useful for collectables which get instanced in runtime.
	DONT_STORE ## Doesn't store anything
}


var collect_animation: TickBasedTimer = TickBasedTimer.new(6)
var drop_animation: TickBasedTimer = TickBasedTimer.new(6)

var state: states = states.UNCOLLECTED

var id: int

var group: String
var group_states: Array # Gets the states of all collectables in the same group.

func _ready() -> void:
	super()
	
	if not is_in_group("collectables"):
		push_warning("Node extending 'Collectable' expected to be in \"collectables\" group.")
	
	if not registered and not Engine.is_editor_hint():
		GameLoop.update_timers.connect(update_timers)
		GameLoop.movement_update.connect(movement_update)
		
		Signals.checkpoint_touched.connect(checkpoint_touched)
		Signals.player_respawn.connect(player_respawn)
		
		drop_animation.timeout.connect(finish_animation)
	
	registered = true


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
	Utilities.disable_area(hitbox)
	modulate.a = 0


func collect() -> void:
	if World.touched_checkpoint_ids.size() == 0:
		state = states.PICKED_UP
	else:
		state = states.SAVED
	
	Utilities.disable_area(hitbox)
	
	collect_animation.reset_and_play()
	
	if plays_sound:
		SFX.play(sound)
	
	if save_behavior == save_behaviors.AUTOMATIC_SAVE:
		save()
	
	update_state()
	
	Signals.anything_collected.emit()


func drop() -> void:
	state = states.UNCOLLECTED
	drop_animation.reset_and_play()
	Utilities.enable_area(hitbox)
	update_state()


func save() -> void:
	if save_behavior == save_behaviors.UNSAVABLE:
		return
	
	state = states.SAVED
	update_state()


func update_state() -> void:
	if store_behavior == store_behaviors.STORE_STATE:
		
		if group_states.size() == 0:
			push_warning("Collectable state array for group " + group + " is not created.")
			return
		
		group_states[id] = 1 if state == states.SAVED else 0
	
	if store_behavior == store_behaviors.INCREMENT_TOTAL:
		if self is Coin:
			pass
			if state == states.SAVED:
				SaveFile.save_dictionary["levels"][GameManager.current_level]["extra_coins"] += 1
		else:
			push_warning("Saving the amount of incremented collectables is only supported for coins.")


func movement_update() -> void:
	if lock_scale:
		global_scale = Vector2(1, 1)
	if lock_rotation:
		global_rotation = 0


func update_timers() -> void:
	if sprite == null:
		push_error("What have you done to make a collectable lose its sprite node?")
		return
	
	if state != states.UNCOLLECTED:
		if collect_animation.active:
			sprite.set_opacity(collect_animation.get_progress_left() * opacity_multiplier)
		else:
			sprite.set_opacity(0)
	
	if drop_animation.active:
		sprite.set_opacity(drop_animation.get_progress() * opacity_multiplier)


func finish_animation() -> void:
	modulate.a = 1


func player_respawn() -> void:
	try_drop()


func checkpoint_touched(_id: int) -> void:
	try_save()
