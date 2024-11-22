@icon("res://core/misc_assets/images/node_icons/area.png")
extends Node2D
class_name Area

## Examples: "1-1", "5-X", "3-9", "2-S", "???". Will be displayed
## in the top left corner as "Level: {level_code}."
@export var level_code: String = "0-1"

## Just an extra comment in the bottom middle part of the screen.
@export var bottom_text: String = ""

## (Should) affect the colors of pretty much everything.
@export var theme: AreaTheme

## Used to make the camera focus properly.
@export var area_size: Vector2i = Vector2(32, 20)
