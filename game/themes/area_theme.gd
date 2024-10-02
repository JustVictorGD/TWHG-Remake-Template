extends Resource
class_name AreaTheme

@export var wall_outline: Color = Color.BLACK
@export var wall_fill: Color = Color.html("b3b3ff")

@export var tile_1: Color = Color.html("ddddff") # Appears in the top left.
@export var tile_2: Color = Color.html("f7f7ff")

@export var enemy_outline: Color = Color.html("000066")
@export var enemy_fill: Color = Color.html("0000ff")

# Applies to both coins and golden doors.
@export var gold_outline: Color = Color.html("957700")
@export var gold_fill: Color = Color.html("ffcc00")

# Applies to both keys and key doors.
@export var key_outline: Color = Color.html("444444")
@export var key_fill: Color = Color.html("999999")

@export var pit: Color = Color.BLACK
