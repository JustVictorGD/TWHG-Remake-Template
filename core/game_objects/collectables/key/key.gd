@tool
@icon("res://core/misc_assets/images/node_icons/key.png")
extends Collectable
class_name Key

@export var key_id: int = -1

@export var constant_check: bool = false

var key_states: Array


func _ready() -> void:
	super()
	
	sprite.update_textures()
	sprite.update_scale()
	
	update_colors()


func _process(delta: float) -> void:
	if constant_check or Engine.is_editor_hint():
		update_colors()


func stay_collected() -> void:
	super()
	
	for key_door: KeyDoor in get_tree().get_nodes_in_group("key_doors"):
		if key_door.key_id == key_id:
			if not key_door.is_initialized:
				await key_door.initialized
			
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


func update_colors() -> void:
	var theme: AreaTheme
	
	if owner is Area:
		theme = owner.theme
	
	if copy_area_theme and theme != null:
		sprite.outline_color = theme.key_outline
		sprite.fill_color = theme.key_fill
	else:
		sprite.outline_color = outline_color
		sprite.fill_color = fill_color
	
	sprite.update_colors()
