extends Node

signal collectables_processed

signal coin_collected(id: int)
signal anything_collected # Update checkpoints
signal checkpoint_touched(id: int)
signal player_death
signal player_respawn

signal switch_level(label: String) # Specify name for world.gd
signal level_switched # Just a signal

signal finish

signal progress_saved

signal event(id: int, state: bool)
