extends ColorRect

@export var type: types = types.CHECKPOINT
@export var tracking: bool = false

var state: states = states.NOT_SELECTED

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

var flash_animation: TickBasedTimer = TickBasedTimer.new(120)
var id: int

@onready var hitbox: RectangleCollider = RectangleCollider.new(Rect2(position, size), rotation, pivot_offset)

func _ready() -> void:
	id = Collider.register_checkpoint_id(self)
	
	GameLoop.movement_update.connect(movement_update)
	GameLoop.update_timers.connect(update_timers)
	GlobalSignal.checkpoint_touched.connect(any_checkpoint_touched)
	GlobalSignal.anything_collected.connect(anything_collected)
	GlobalSignal.player_death.connect(player_death)


func movement_update() -> void:
	var previous_rotation: float = rotation
	
	rotation = 0
	
	hitbox.position = self.global_position
	hitbox.size = self.size
	hitbox.rotation = previous_rotation
	hitbox.pivot_offset = self.pivot_offset
	
	rotation = previous_rotation


func update_timers() -> void:
	flash_animation.tick_and_timeout()
	
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
	if tracking:
		print(Collider.touched_checkpoint_ids, ", ", id)
	
	if state == states.SELECTED and self.id not in Collider.touched_checkpoint_ids:
		state = states.UPDATED


func player_death() -> void:
	if state == states.UPDATED:
		state = states.SELECTED


func select() -> void:
	if state != states.SELECTED:
		flash_animation.reset_and_play()
		state = states.SELECTED
		GlobalSignal.checkpoint_touched.emit(id)
		
		if GameManager.money >= GameManager.max_money and not \
				GameManager.finished and is_finish():
			SFX.play("Finish")
			GameManager.finished = true
			GlobalSignal.finish.emit()
		else:
			SFX.play("Checkpoint")
