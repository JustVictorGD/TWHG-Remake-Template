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

enum states {
	UNCOLLECTED,
	PICKED_UP, # Goes back to UNCOLLECTED if the player dies
	SAVED
}

var collect_animation: TickBasedTimer = TickBasedTimer.new(6)
var drop_animation: TickBasedTimer = TickBasedTimer.new(6)

var state: states = states.UNCOLLECTED
var collect_sound: String

func _init() -> void:
	GameLoop.update_timers.connect(update_timers)
	GameLoop.movement_update.connect(movement_update)
	GlobalSignal.player_respawn.connect(player_respawn)

func collect() -> void:
	if state == states.UNCOLLECTED:
		if Collider.touched_checkpoint_ids.size() == 0:
			state = states.PICKED_UP
		else:
			state = states.SAVED
		
		collect_animation.reset_and_play()
		if plays_sound:
			SFX.play(collect_sound)
		GlobalSignal.anything_collected.emit()
		
		extra_collect()

func drop() -> void:
	if state == states.PICKED_UP:
		state = states.UNCOLLECTED
		drop_animation.reset_and_play()
		extra_drop()

func save() -> void:
	if state == states.PICKED_UP:
		state = states.SAVED
		extra_save()

# Override these functions to add more behavior.
func extra_collect() -> void:
	pass
func extra_drop() -> void:
	pass
func extra_save() -> void:
	pass

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

func player_respawn() -> void:
	drop()
