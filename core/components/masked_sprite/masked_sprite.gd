@tool
extends Sprite2D
class_name MaskedSprite

## By default, the sprite waits for its parent object to call the "update"
## functions. Switching this to true makes the sprite call its own update
## functions. It's a problem with the order in which _ready() gets called.
@export var standalone_decoration: bool = false

@export var rapid_update_colors: bool = false
@export var rapid_update_scale: bool = false

@export var outline_scale: Vector2 = Vector2.ONE
@export var fill_scale: Vector2 = Vector2.ONE

@export var outline_color: Color = Color.BLACK
@export var fill_color: Color = Color.WHITE

@export var outline_texture: Texture
@export var fill_texture: Texture

@onready var in_editor: bool = Engine.is_editor_hint()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = preload("res://core/misc_assets/images/Blank pixel.png")
	
	material = ShaderMaterial.new()
	material.shader = preload("res://core/components/masked_sprite/masked_sprite.gdshader")
	
	if standalone_decoration:
		update_textures()
		update_colors()
		update_scale()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_editor:
		update_textures()
	
	if in_editor or rapid_update_colors:
		update_colors()
	
	if in_editor or rapid_update_scale:
		update_scale()


func update_colors() -> void:
	material.set_shader_parameter("outline_color", outline_color)
	material.set_shader_parameter("fill_color", fill_color)


func update_scale() -> void:
	material.set_shader_parameter("outline_scale", outline_scale)
	material.set_shader_parameter("fill_scale", fill_scale)


func update_textures() -> void:
	material.set_shader_parameter("outline_texture", outline_texture)
	material.set_shader_parameter("fill_texture", fill_texture)
