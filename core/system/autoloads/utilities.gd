extends Node


func disable_area(area: Area2D) -> void:
	area.set_deferred("monitorable", false)
	area.monitoring = false


func enable_area(area: Area2D) -> void:
	area.set_deferred("monitorable", true)
	area.monitoring = true
