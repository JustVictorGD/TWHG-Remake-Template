@icon("res://core/misc_assets/images/node_icons/Area 16.png")
extends Node2D
class_name Area

## Remember how areas could have coordinates like A1 and B4?
## Due to them being off-grid, you need to set them manually.
@export var displayed_coordinates: String = "Z0"
@export var bottom_text: String = ""
@export var theme: AreaTheme
@export var area_size: Vector2i = Vector2(32, 20)

@export_category("Object Folders")
## The game goes over all objects when an area gets loaded to assign IDs to them.
## To save resources and to encourage organization, only select sections of the
## scene are looped through per object type instead of looping through the entire
## node tree multiple times. The game will only read objects of the Coin class
## in the assigned "Coins" Folder2D and ignore anything else.
@export var floors: Folder2D
## See the description for "Floors."
@export var walls: Folder2D
## See the description for "Floors."
@export var checkpoints: Folder2D
## See the description for "Floors."
@export var enemies: Folder2D
## See the description for "Floors."
@export var coins: Folder2D
## See the description for "Floors."
@export var keys: Folder2D
## See the description for "Floors."
@export var gold_doors: Folder2D
## See the description for "Floors."
@export var key_doors: Folder2D

# Multi-area travel purposes.
var boundary: Rect2

@onready var edges: Dictionary = {
	"up": RectangleCollider.new(Rect2(boundary.position, Vector2(boundary.size.x, 0))),
	"left": RectangleCollider.new(Rect2(boundary.position, Vector2(0, boundary.size.y))),
	"down": RectangleCollider.new(Rect2(boundary.position.x, boundary.end.y, boundary.size.x, 0)),
	"right": RectangleCollider.new(Rect2(boundary.end.x, boundary.position.y, 0, boundary.size.y))
}

var id: int = -1

# Activates VERY early, before any call of ready().
func _enter_tree() -> void:
	add_to_group("areas")

func process_ids() -> void:
	pass
