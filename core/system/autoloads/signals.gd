extends Node

signal coin_collected(id: int)
signal anything_collected # Update checkpoints
signal checkpoint_touched(id: int)
signal player_death
signal player_respawn

signal paint_changed(id: int)

signal switch_level(label: String) # Specify name for world.gd
signal level_switched # Just a signal

signal finish

# These should only be "emitted" from SaveData functions,
# otherwise the save files aren't properly interacted with.
signal save_game()
signal load_game()
signal wipe_save()
signal save_unsafely()

signal event(id: int, state: bool)
signal trails_toggled()
