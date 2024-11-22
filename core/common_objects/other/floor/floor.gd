@tool
extends Control

@export var invert_pattern: bool = false
@export var copy_area_theme: bool = true

@export var color_1: Color = Color(0.75, 0.75, 0.75)
@export var color_2: Color = Color.WHITE

@onready var tile_1: TextureRect = $Tile1
@onready var tile_2: TextureRect = $Tile2

var debug_theme: AreaTheme = load("res://game/themes/red_theme.tres")

# Keeping track of change
var old_size: Vector2
var old_color_1: Color
var old_color_2: Color
var old_invert_pattern: bool

func _process(_delta: float) -> void:
	# The texture can't get any smaller than 2x2 anyway, and (0,0) size is annoying.
	if size.x < 2:
		size.x = 2
	if size.y < 2:
		size.y = 2
	
	if invert_pattern != old_invert_pattern:
		if invert_pattern:
			tile_1 = $Tile2
			tile_2 = $Tile1
		if not invert_pattern:
			tile_1 = $Tile1
			tile_2 = $Tile2
	
	if size != old_size:
		tile_1.size = size
		tile_2.size = size
	
	old_size = size
	old_color_1 = color_1
	old_color_2 = color_2
	old_invert_pattern = invert_pattern
	
	refresh_color_1()
	refresh_color_2()


func refresh_color_1() -> void:
	if copy_area_theme and owner is Area:
		tile_1.modulate = owner.theme.tile_1
	else:
		tile_1.modulate = color_1


func refresh_color_2() -> void:
	if copy_area_theme and owner is Area:
		tile_2.modulate = owner.theme.tile_2
	else:
		tile_2.modulate = color_2
