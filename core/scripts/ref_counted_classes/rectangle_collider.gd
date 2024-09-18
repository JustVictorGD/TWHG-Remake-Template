extends AbstractCollider # Which then extends RefCounted.
class_name RectangleCollider


var position: Vector2
var size: Vector2
var rotation: float
var pivot_offset: Vector2

var end: Vector2 = position + size:
	get:
		return position + size
	set(value):
		size = value - position

func _init(bounding_box: Rect2 = Rect2(), _rotation: float = 0, _pivot_offset: Vector2 = Vector2.ZERO) -> void:
	position = bounding_box.position
	size = bounding_box.size
	rotation = _rotation
	pivot_offset = _pivot_offset


func _to_string() -> String:
	var extra: String = ""
	
	if rotation != 0 or pivot_offset != Vector2.ZERO:
		extra = str(", Rotation = ", rotation)
	
	if pivot_offset != Vector2.ZERO:
		extra += str(", Pivot Offset = ", pivot_offset)
	
	return str("[Enabled: ", enabled, ", Bounding Box: ", Rect2(position, size), extra, "]")


func intersects(shape: AbstractCollider) -> bool:
	if enabled and shape.enabled:
		if shape is CircleCollider:
			if is_zero_approx(rotation) and not Rect2(position, size).intersects(create_rect_with_radius(shape.position, shape.radius)):
				return false
			elif not Rect2(position - size / 4, size * 1.5).intersects(create_rect_with_radius(shape.position, shape.radius)):
				return false
			
			var relative_point: Vector2 = shape.position - position
			relative_point -= pivot_offset
			
			if not is_zero_approx(rotation):
				relative_point = relative_point.rotated(-rotation)
			
			relative_point += pivot_offset
			
			var nearest_point: Vector2 = Vector2(
				clamp(relative_point.x, 0, size.x),
				clamp(relative_point.y, 0, size.y))
			
			return relative_point.distance_squared_to(nearest_point) < shape.radius ** 2
		
		
		if shape is PointCollider:
			var relative_point: Vector2 = shape.position - position
			relative_point -= pivot_offset
			
			if not is_zero_approx(rotation):
				relative_point = relative_point.rotated(-rotation)
			
			relative_point += pivot_offset
			
			return relative_point > Vector2.ZERO and relative_point < size
		
		
		if shape is RectangleCollider:
			if is_zero_approx(rotation) and is_zero_approx(shape.rotation):
				return Rect2(position, size).intersects(Rect2(shape.position, shape.size))
			
			elif not Rect2(position - size / 4, size * 1.5).intersects(\
					Rect2(shape.position - shape.size / 4, shape.size * 1.5)):
				return false
			
			else:
				return are_rectangles_colliding(self, shape)
	
	return false

# Separating Axis Theorem here we go.
func are_rectangles_colliding(rect_1: RectangleCollider, rect_2: RectangleCollider) -> bool:
	var rect_1_vertices: PackedVector2Array = get_vertices()
	var rect_2_vertices: PackedVector2Array = rect_2.get_vertices()
	var axes: PackedVector2Array = get_separating_axes(rect_1_vertices, rect_2_vertices)
	
	for axis: Vector2 in axes:
		var rect_1_projection: Vector2 = project_rectangle(rect_1_vertices, axis)
		var rect_2_projection: Vector2 = project_rectangle(rect_2_vertices, axis)
		
		if not overlap(rect_1_projection, rect_2_projection):
			return false
	
	return true


func overlap(range_1: Vector2, range_2: Vector2) -> bool:
	return not (range_1.y < range_2.x or range_2.y < range_1.x)


func get_vertices() -> PackedVector2Array:
	var rect: Rect2 = Rect2(position, size)
	
	var vertices: PackedVector2Array = [
		Vector2(0, 0),
		Vector2(rect.size.x, 0),
		Vector2(0, rect.size.y),
		Vector2(rect.size.x, rect.size.y)
	]
	
	for i: int in range(vertices.size()):
		vertices[i] -= pivot_offset
		vertices[i] = vertices[i].rotated(rotation)
		vertices[i] += pivot_offset
		vertices[i] += rect.position
	
	return vertices


func get_center() -> Vector2:
	var vertices: PackedVector2Array = get_vertices()
	return Vector2((vertices[0] + vertices[3]) / 2)


func get_separating_axes(rect_1_vertices: PackedVector2Array, rect_2_vertices: PackedVector2Array) -> PackedVector2Array:
	var rectangles: Array[Array] = [rect_1_vertices, rect_2_vertices]
	var axes: PackedVector2Array = []
	
	for rectangle: PackedVector2Array in rectangles:
		for i: int in range(rectangle.size()):
			var edge: Vector2 = Vector2(rectangle[(i + 1) % rectangle.size()] - rectangle[i])
			var normal: Vector2 = Vector2(-edge.y, edge.x)
			axes.append(normal.normalized())
	
	return axes


func project_rectangle(vertices: PackedVector2Array, axis: Vector2) -> Vector2:
	var min_proj: float = INF
	var max_proj: float = -INF
	
	# Loop through each vertex of the rectangle
	for vertex: Vector2 in vertices:
		# Project the vertex onto the axis using the dot product
		var projection: float = vertex.dot(axis)
		
		# Track the minimum and maximum projection values
		if projection < min_proj:
			min_proj = projection
		if projection > max_proj:
			max_proj = projection
	
	return Vector2(min_proj, max_proj) # Return the min and max projections as a Vector2
