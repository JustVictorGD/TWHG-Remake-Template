extends ColorRect

@export var type: types = types.CHECKPOINT

var state: states = states.NOT_SELECTED

enum types {
	CHECKPOINT,
	START,
	FINISH
}

enum states {
	NOT_SELECTED,
	SELECTED,
	UPDATED # After picking up stuff, your last checkpoint can be activated again.
}

const ORIGINAL_COLOR: Color = Color(0.643, 0.996, 0.639)
const FLASH_COLOR: Color = Color(0.478, 0.745, 0.478)

var flash_animation: TickBasedTimer = TickBasedTimer.new(120)
var id: int
var hitbox: Rect2

func _ready() -> void:
	if type == types.START:
		state = states.SELECTED
	
	id = Collider.register_checkpoint_id(self)
	hitbox = Rect2(global_position, size)
	
	GameLoop.movement_update.connect(movement_update)
	GameLoop.update_timers.connect(update_timers)
	GlobalSignal.checkpoint_touched.connect(any_checkpoint_touched)
	GlobalSignal.anything_collected.connect(anything_collected)
	GlobalSignal.player_death.connect(player_death)


func movement_update() -> void:
	hitbox = Rect2(round(global_position), round(size))


func update_timers() -> void:
	flash_animation.tick()
	
	if flash_animation.active:
		color = lerp(FLASH_COLOR, ORIGINAL_COLOR, flash_animation.get_progress())


func any_checkpoint_touched(_id: int) -> void:
	if _id == id:
		if state != states.SELECTED: # Checking if it can be selected
			select()
	else:
		state = states.NOT_SELECTED


func anything_collected() -> void:
	if state == states.SELECTED and self.id not in Collider.touched_checkpoint_ids:
		state = states.UPDATED


func player_death() -> void:
	if state == states.UPDATED:
		state = states.SELECTED


func select() -> void:
	flash_animation.reset_and_play()
	state = states.SELECTED
	
	if type == types.FINISH and AreaManager.money >= AreaManager.max_money and not AreaManager.finished:
		SFX.play("Finish")
		AreaManager.finished = true
		GlobalSignal.finish.emit()
	
	else:
		SFX.play("Checkpoint")
