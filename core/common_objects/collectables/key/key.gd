@tool
@icon("res://core/misc_assets/images/node_icons/key.png")
extends Collectable
class_name Key

@export var key_id: int = -1

@export var constant_check: bool = false
@export var copy_area_theme: bool = true
@export var outline_color: Color = Color(0.267, 0.267, 0.267)
@export var fill_color: Color = Color(0.6, 0.6, 0.6)

@onready var outline: Sprite2D = $Outline
@onready var fill: Sprite2D = $Fill

var key_states: Array

func _ready() -> void:
	super()
	update_colors()
	
	hitbox = $CircleCollider


func _process(delta: float) -> void:
	if constant_check or Engine.is_editor_hint():
		update_colors()


func stay_collected() -> void:
	super()
	for key_door: Door in get_tree().get_nodes_in_group("key_doors"):
		if key_door.key_id == key_id:
			key_door.stay_triggered()
	

func collect() -> void:
	# Call the collect() function of the Collectable class.
	super()
	
	for key_door: Door in get_tree().get_nodes_in_group("key_doors"):
		if key_door.key_id == key_id:
			key_door.trigger_door()


func drop() -> void:
	super()
	
	for key_door: Door in get_tree().get_nodes_in_group("key_doors"):
		if key_door.key_id == key_id:
			key_door.untrigger_door()

func save() -> void:
	super()

func movement_update() -> void:
	hitbox.global_position = self.global_position
	hitbox.radius = self.global_scale.x * 21 # 21 units is the default scale of the key.
	# This assumes that enemy scale.x and scale.y are equal as oval hitboxes are not implemented.

func update_colors() -> void:
	var theme: AreaTheme
	
	if owner is Area:
		theme = owner.theme
	
	if copy_area_theme and theme != null:
		outline.modulate = theme.key_outline
		fill.modulate = theme.key_fill
	else:
		outline.modulate = outline_color
		fill.modulate = fill_color
