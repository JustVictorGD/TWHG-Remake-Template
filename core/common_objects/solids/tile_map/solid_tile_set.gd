@tool
extends TileMapLayer

## If the node's owner is a node of the "Area" type, the area's theme gets
## referenced instead of the wall's outline and fill colors being set manually.
@export var copy_area_theme: bool = true
## Gets overridden if "copy_area_theme" is on.
@export var outline_color: Color = Color.BLACK
## Gets overridden if "copy_area_theme" is on.
@export var fill_color: Color = Color.WHITE

## If true, it will keep updating its values in game every frame.
@export var constant_check: bool = false

@onready var outline: TileMapLayer = $Outline
@onready var fill: TileMapLayer = $Fill

var previous_cells: Array[Vector2i] = []


func _ready() -> void:
	if not Engine.is_editor_hint():
		for cell: Vector2i in get_used_cells():
			World.walls.append(Rect2(
				Vector2(cell.x * 48 - 3, cell.y * 48 - 3) + global_position,
				Vector2(54, 54)))
	
	update_tiles()


func _process(delta: float) -> void:
	# Not in the scene editor, only properly in game.
	if not Engine.is_editor_hint():
		if GameManager.ghost:
			modulate.a = 0.5
		else:
			modulate.a = 1
	
	if constant_check or Engine.is_editor_hint():
		update_tiles()


func update_tiles() -> void:
	if copy_area_theme:
		if owner is Area:
			if owner.theme != null:
				outline.modulate = owner.theme.wall_outline
				fill.modulate = owner.theme.wall_fill
	else:
		outline.modulate = outline_color
		fill.modulate = fill_color
	
	var current_cells: Array[Vector2i] = get_used_cells()
	
	# Abort if the tiles haven't changed
	if current_cells == previous_cells:
		return
	
	fill.tile_map_data = self.tile_map_data
	outline.tile_map_data = self.tile_map_data
	
	previous_cells = current_cells
