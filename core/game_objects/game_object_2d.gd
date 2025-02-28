@tool
extends Node2D
class_name GameObject2D

## Required for automatic theme support and color updates.
@export var sprite: MaskedSprite
## The game will scream at you if this is null.
@export var hitbox: Area2D

## Makes colors constantly get checked in game. Probably costs some
## performance but allows themes with gradually changing colors.
@export var rapid_update_colors: bool = false

## If the owner of this node is of the 'Area' class, try to link
## the object's colors to the area's 'AreaTheme' resource.
@export var copy_area_theme: bool = true

## The exact name of a variable in an 'AreaTheme'
## resource to reference to color the sprite's outline.
@export var outline_theme_link: String = ""

## The exact name of a variable in an 'AreaTheme'
## resource to reference to color the sprite's filling.
@export var fill_theme_link: String = ""

@export_category("Self-contained theme")

@export var outline_color: Color = Color.BLACK
@export var fill_color: Color = Color.WHITE

# It's not only clean but I think it's also more performant to
# call the function once and store its output in a variable.
@onready var in_editor: bool = Engine.is_editor_hint()

## Returns the nearest "Area" on the node tree. Returns null if nothing
## is found. Doesn't loop through nodes again after already succeeding.
var area: Area = null:
	get:
		if is_instance_valid(area): return area
		
		var parent: Node = get_parent()
		
		while is_instance_valid(parent) and not (parent is Area):
			if parent is Window: return null # "Window" is the highest node
			
			parent = parent.get_parent()
		
		area = parent
		return area


func _ready() -> void:
	if sprite == null:
		return
	
	if hitbox == null:
		push_error("Hitbox of the GameObject '", name,
				"' is null! Trying to use it will lead to crashes.")
	
	sprite.update_textures()
	sprite.update_colors()
	sprite.update_scale()
	
	sprite.rapid_update_colors = rapid_update_colors
	
	update_colors()


func update_colors() -> void:
	if sprite == null:
		return
	
	var theme: AreaTheme
	
	if owner is Area:
		theme = owner.theme
	
	if theme == null or not copy_area_theme:
		sprite.outline_color = outline_color
		sprite.fill_color = fill_color
	else:
		if outline_theme_link != "":
			if outline_theme_link in theme:
				sprite.outline_color = theme.get(outline_theme_link)
			else:
				push_error("Property named '", outline_theme_link, "' not found in AreaTheme.")
		
		if fill_theme_link != "":
			if fill_theme_link in theme:
				sprite.fill_color = theme.get(fill_theme_link)
			else:
				push_error("Property named '", fill_theme_link, "' not found in AreaTheme.")
	
	sprite.update_colors()


func _process(delta: float) -> void:
	if not (rapid_update_colors or in_editor):
		return
	
	update_colors()
