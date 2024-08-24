@tool
extends Door2

## Values above 0 define the requirement directly.
## Values equal or less than 0 add the total amount of money in the level to themselves.
@export var money_requirement: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
