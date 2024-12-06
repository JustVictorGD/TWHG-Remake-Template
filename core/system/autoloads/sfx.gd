extends Node


enum sounds {
	NONE,
	ENEMY_DEATH,
	COIN,
	CHECKPOINT,
	FINISH,
	KEY,
	PAINT,
	OPEN_DOOR,
	CLOSE_DOOR,
}


@onready var enemy_death: AudioStreamPlayer = $EnemyDeath
@onready var coin: AudioStreamPlayer = $Coin
@onready var checkpoint: AudioStreamPlayer = $Checkpoint
@onready var finish: AudioStreamPlayer = $Finish
@onready var key: AudioStreamPlayer = $Key
@onready var paint: AudioStreamPlayer = $Paint
@onready var open_door: AudioStreamPlayer = $OpenDoor
@onready var close_door: AudioStreamPlayer = $CloseDoor


func play(sound_name: sounds) -> void:
	match sound_name:
		sounds.NONE:
			pass
		sounds.ENEMY_DEATH:
			enemy_death.play()
		sounds.COIN:
			coin.play()
		sounds.CHECKPOINT:
			checkpoint.play()
		sounds.FINISH:
			finish.play()
		sounds.PAINT:
			paint.play()
		sounds.OPEN_DOOR:
			open_door.play()
		sounds.CLOSE_DOOR:
			close_door.play()
