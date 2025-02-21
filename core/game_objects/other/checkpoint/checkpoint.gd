@icon("res://core/misc_assets/images/node_icons/checkpoint.png")
extends ColorRect
class_name Checkpoint

@export var type: types = types.CHECKPOINT

## If the checkpoint is a finish and is used to win the level, this value
## will be used as a shortcut to warp to another level. Check the file
## "res://game/connections.json" for the list of key-value pairs. If a valid
## key is entered in this field, it will load the corresponding file path.
@export var level_warp: String = ""

## Amount of delay after finishing the level before warping
## to the next one. Measured in ticks. 1 second = 60 ticks.
@export var warp_time: int = 120

## If this checkpoint is a finish, using it to win will turn
## the timer golden and will not lead to another level.
@export var final_destination: bool = false

@onready var warp_timer: TickBasedTimer = $WarpDelayTimer
var state: states = states.NOT_SELECTED

@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D

enum types {
	CHECKPOINT,
	START,
	FINISH,
	START_AND_FINISH
}

enum states {
	NOT_SELECTED,
	SELECTED,
	UPDATED # After picking up stuff, your last checkpoint can be activated again.
}

const ORIGINAL_COLOR: Color = Color(0.643, 0.996, 0.639)
const FLASH_COLOR: Color = Color(0.478, 0.745, 0.478)

@onready var flash_animation: TickBasedTimer = $FlashAnimationTimer
var id: int = -1

# The RectangleCollider in the scene tree currently does nothing.

func _ready() -> void:
	collision_shape_2d.shape.size = self.size
	collision_shape_2d.position = self.size / 2
	
	GameLoop.update_timers.connect(update_timers)
	Signals.checkpoint_touched.connect(any_checkpoint_touched)
	Signals.anything_collected.connect(anything_collected)
	Signals.player_death.connect(player_death)
	
	warp_timer.duration = warp_time
	warp_timer.timeout.connect(warp_level)


func update_timers() -> void:
	flash_animation.tick_and_timeout()
	warp_timer.tick_and_timeout()
	
	if flash_animation.active:
		color = lerp(FLASH_COLOR, ORIGINAL_COLOR, flash_animation.get_progress())


func is_start() -> bool:
	return type == types.START or type == types.START_AND_FINISH

func is_finish() -> bool:
	return type == types.FINISH or type == types.START_AND_FINISH


func any_checkpoint_touched(_id: int) -> void:
	if _id != id:
		state = states.NOT_SELECTED


func anything_collected() -> void:
	if state == states.SELECTED and self.id not in World.touched_checkpoint_ids:
		state = states.UPDATED


func player_death() -> void:
	if state == states.UPDATED:
		state = states.SELECTED


func select() -> void:
	if state != states.SELECTED:
		flash_animation.reset_and_play()
		state = states.SELECTED
		Signals.checkpoint_touched.emit(id)
		
		if is_finish() and World.collected_money >= World.money_requirement \
				and not GameManager.finished:
			win()
		
		else:
			SFX.play(SFX.sounds.CHECKPOINT)


func win() -> void:
	SFX.play(SFX.sounds.FINISH)
	warp_timer.reset_and_play()
	
	if final_destination:
		Signals.finish.emit()
		GameManager.finished = true


func warp_level() -> void:
	if final_destination:
		get_tree().change_scene_to_packed(preload("res://game/scenes/end_screen.tscn"))
	
	elif level_warp != "":
		Signals.switch_level.emit(level_warp)
