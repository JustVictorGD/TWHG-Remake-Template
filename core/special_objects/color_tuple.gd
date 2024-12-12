extends Resource
class_name ColorTuple

@export var outline: Color = Color.BLACK
@export var fill: Color = Color.WHITE

# Ideally, this should mean that the constructor copies the export
# properties unless the arguments are overwritten.
func _init(_outline: Color = outline, _fill: Color = outline) -> void:
	outline = _outline
	fill = _fill
