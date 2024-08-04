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


func _ready() -> void:
	if type == types.START:
		state = states.SELECTED
	
	id = Collider.register_checkpoint_id()
	Collider.checkpoints[id] = NiceFunctions.global_to_normal_rect(get_global_rect())
	
	GameLoop.movement_update.connect(movement_update)
	GameLoop.update_timers.connect(update_timers)
	
	GlobalSignal.checkpoint_touched.connect(any_checkpoint_touched)


func movement_update() -> void:
	Collider.checkpoints[id] = NiceFunctions.global_to_normal_rect(get_global_rect())


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


func select() -> void:
	flash_animation.reset_and_play()
	SFX.play("Checkpoint")
	state = states.SELECTED
