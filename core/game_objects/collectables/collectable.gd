@tool
extends GameObject2D
class_name Collectable

const ARRAY_FAIL_MESSAGE: String = "SAVE ARRAY FAILED"

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

## Used for saving the collectable's state to file, more specifically an array.
@export var array_name: String

@export var id_group: String

## Used by 'save_array' to avoid repeating complex operations after a success.
var array_valid: bool = false

var save_array: Array:
	get:
		if array_valid: return save_array
		
		if not is_instance_valid(area) or array_name == "":
			return [ARRAY_FAIL_MESSAGE]
		
		if array_name not in area.persistent_data.keys():
			area.persistent_data[array_name] = []
		
		array_valid = true
		save_array = area.persistent_data[array_name]
		return save_array



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


var collect_animation: TickBasedTimer = TickBasedTimer.new(6)
var drop_animation: TickBasedTimer = TickBasedTimer.new(6)

var state: states = states.UNCOLLECTED
var id: int


func _ready() -> void:
	super()
	
	if not in_editor:
		id = IdGenerator.get_group(id_group)
		
		if save_array != [ARRAY_FAIL_MESSAGE]:
			id = save_array.size()
			save_array.append(0)
		
		if not registered:
			GameManager.update_timers.connect(update_timers)
			GameManager.movement_update.connect(movement_update)
			
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
	
	Signals.anything_collected.emit()


func drop() -> void:
	state = states.UNCOLLECTED
	drop_animation.reset_and_play()
	Utilities.enable_area(hitbox)


func save() -> void:
	if save_behavior == save_behaviors.UNSAVABLE:
		return
	
	state = states.SAVED


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
