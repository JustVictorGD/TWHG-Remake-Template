@tool
extends TileMapLayer

@export var outline_color: Color = Color.BLACK
@export var fill_color: Color = Color.WHITE

@onready var outline: TileMapLayer = $Outline
@onready var fill: TileMapLayer = $Fill

var previous_cells: Array[Vector2i] = []


func _ready() -> void:
	if not Engine.is_editor_hint():
		for cell: Vector2i in get_used_cells():
			Collider.walls.append(Rect2(
				Vector2(cell.x * 48 - 3, cell.y * 48 - 3) + global_position,
				Vector2(54, 54)))


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if GameManager.ghost:
			modulate.a = 0.5
		else:
			modulate.a = 1
	
	
	outline.modulate = outline_color
	fill.modulate = fill_color
	
	var current_cells: Array[Vector2i] = get_used_cells()
	
	# Abort if the tiles haven't changed
	if current_cells == previous_cells:
		return
	
	outline.clear()
	fill.clear()
	
	for cell: Vector2i in current_cells:
		if cell not in previous_cells:
			pass
		
		outline.set_cell(cell, 0, Vector2i(0, 0))
		fill.set_cell(cell, 0, Vector2i(0, 0))
	
	outline.set_cells_terrain_connect(current_cells, 0, 0)
	fill.set_cells_terrain_connect(current_cells, 0, 0)
	
	previous_cells = current_cells
