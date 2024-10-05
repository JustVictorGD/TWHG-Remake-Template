extends Resource
class_name AreaTheme

@export var wall_outline: Color = Color.BLACK
@export var wall_fill: Color = Color.WHITE

@export var tile_1: Color = Color.BLACK # Appears in the top left.
@export var tile_2: Color = Color.WHITE

@export var enemy_outline: Color = Color.BLACK
@export var enemy_fill: Color = Color.WHITE

# Applies to both coins and golden doors.
@export var gold_outline: Color = Color(0.584, 0.467, 0)
@export var gold_fill: Color = Color(1, 0.8, 0)

# Applies to both keys and key doors.
@export var key_outline: Color = Color(0.267, 0.267, 0.267)
@export var key_fill: Color = Color(0.6, 0.6, 0.6)

@export var pit: Color = Color.BLACK
