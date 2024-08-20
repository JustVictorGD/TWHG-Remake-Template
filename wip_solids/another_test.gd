@tool
extends Node

@export var color_1: Color = Color.BLACK
@export var color_2: Color = Color.WHITE

var canvas_group := CanvasGroup.new()
var outline := ColorRect.new()
var fill := ColorRect.new()

func _ready() -> void:
	add_child(canvas_group)
	canvas_group.add_child(outline)
	canvas_group.add_child(fill)
	
	outline.size *= 2

func _process(delta: float) -> void:
	outline.color = color_1
	fill.color = color_2
