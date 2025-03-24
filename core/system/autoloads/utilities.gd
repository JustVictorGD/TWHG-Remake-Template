@tool
extends Node


func disable_area(area: Area2D) -> void:
	area.set_deferred("monitorable", false)
	area.monitoring = false


func enable_area(area: Area2D) -> void:
	area.set_deferred("monitorable", true)
	area.monitoring = true


func fallback(plan_a: Variant, plan_b: Variant) -> Variant:
	return plan_a if plan_a != null else plan_b


func index_in_range(index: int, array_size: int) -> bool:
	if index >= 0:
		return index < array_size
	else:
		return abs(index) <= array_size
