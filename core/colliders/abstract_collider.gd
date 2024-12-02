extends Node2D
class_name AbstractCollider

signal collided(node: Node)

## Whether or not this collider checks for collisions.
@export var enabled: bool = true
## List the node groups you want to check collisions with here. Keep the array empty to check all nodes in the tree (might cause lag).
@export var groups_to_check: Array[String] = []

func _ready() -> void:
	GameLoop.collision_update.connect(collision_update)

func collision_update() -> void:
	if not enabled:
		return
	
	for group: String in groups_to_check:
		var nodes: Array[Node] = get_tree().get_nodes_in_group(group)
		for node: Node in nodes:
			var collider: AbstractCollider = get_collider(node)
			if collider != null and self.intersects(collider):
				collided.emit(node)

func get_collider(node: Node) -> AbstractCollider:
	for child: Node in node.get_children():
		if child is AbstractCollider:
			return child
	push_warning("Node " + node.to_string() + "doesn't have a collider.")
	return null




func intersects(shape: AbstractCollider) -> bool:
	push_warning("Can't check collisions with an abstract collider. Use a circle, point or rectangle collider.")
	return false


func create_rect_with_radius(_position: Vector2, radius: float) -> Rect2:
	return Rect2(_position - Vector2(radius, radius), Vector2(radius * 2, radius * 2))


func point_in_rect(point: Vector2, rect: Rect2) -> bool:
	return rect.position.x < point.x and point.x < rect.end.x and \
			rect.position.y < point.y and point.y < rect.end.y
