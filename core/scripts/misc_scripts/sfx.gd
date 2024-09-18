extends Node

func play(sound_name: String) -> void:
	if GameManager.sfx_enabled:
		for node: Node in get_children():
			if node.name == sound_name:
				node.play()
				return
		
		push_error("The sound with the name \"", sound_name, "\" doesn\'t exist.")
