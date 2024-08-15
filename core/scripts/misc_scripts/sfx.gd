extends Node

func play(sound_name : String) -> void:
	for node : Node in get_children():
		if node.name == sound_name:
			node.play()
