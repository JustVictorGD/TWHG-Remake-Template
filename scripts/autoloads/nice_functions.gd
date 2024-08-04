extends Node



func closest_point_on_rectangle(circle_center: Vector2, rect: Rect2) -> Vector2:
	var closest_x: float = clamp(circle_center.x, rect.position.x, rect.end.x)
	var closest_y: float = clamp(circle_center.y, rect.position.y, rect.end.y)
	return Vector2(closest_x, closest_y)


func enemy_intersection(rect: Rect2, circle_pos: Vector2) -> bool:
	var closest_point : Vector2 = closest_point_on_rectangle(circle_pos, rect)
	var distance : float = circle_pos.distance_to(closest_point)
	return distance < 7


func get_center(rect: Rect2) -> Vector2:
	return rect.position + rect.size / 2


func global_to_normal_position(global_position: Vector2) -> Vector2:
	return (global_position - Collider.GAMEPLAY_POSITION) / Collider.GAMEPLAY_SCALE


func global_to_normal_rect(global_rect: Rect2) -> Rect2:
	return Rect2(global_to_normal_position(global_rect.position), \
			(global_rect.size / Collider.GAMEPLAY_SCALE))


func point_in_rect(position: Vector2, rect: Rect2) -> bool:
	if position.x >= rect.position.x and position.x <= rect.end.x and \
			position.y >= rect.position.y and position.y <= rect.end.y:
		return true
	return false


func rect_and_circle_overlap(rect: Rect2, circle_pos: Vector2, circle_radius: float) -> bool:
	var closest_point: Vector2 = closest_point_on_rectangle(circle_pos, rect)
	var distance: float = circle_pos.distance_to(closest_point)
	return distance < circle_radius
