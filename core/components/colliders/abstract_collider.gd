extends Node2D
class_name AbstractCollider

signal collision_entered(node: Node)
signal collision_exited(node: Node)
signal all_collisions_exited()

## Whether or not this collider checks for collisions.
@export var enabled: bool = true
## If this is enabled, each colliding object will be registered by this collider every tick.
## Otherwise each collision will be registed once unless the colliding object leaves and reenters the collider.
@export var multi_activate: bool = true
## List the node groups you want to check collisions with here. Keep the array empty to check all nodes in the tree (might cause lag).
@export var groups_to_check: Array[String] = []

var previous_collisions: Array[Node] = []
var collisions: Array[Node] = []

func _ready() -> void:
	GameLoop.collision_update.connect(collision_update)

func collision_update() -> void:
	previous_collisions = collisions
	collisions = []
	if not enabled:
		return
	
	var nodes_to_check: Array[Node] = []
	for group: String in groups_to_check:
		var nodes: Array[Node] = get_tree().get_nodes_in_group(group)
		nodes_to_check.append_array(nodes)
	
	for node: Node in nodes_to_check:
		var collider: AbstractCollider = get_collider(node)
		
		if self.intersects(collider):
			collisions.append(node)
			
			if multi_activate or (not multi_activate and not previous_collisions.has(node)):
				collision_entered.emit(node)
		else:
			if previous_collisions.has(node) and not collisions.has(node):
				collision_exited.emit(node)
	
	if len(collisions) == 0 and len(previous_collisions) != 0:
		all_collisions_exited.emit()

func get_collider(node: Node) -> AbstractCollider:
	for child: Node in node.get_children():
		if child is AbstractCollider:
			return child
	push_warning("Node " + node.to_string() + "'s collider is not found.")
	return null




func intersects(shape: AbstractCollider) -> bool:
	push_warning("Can't check collisions with an abstract collider. Use a circle, point or rectangle collider.")
	return false


func create_rect_with_radius(_position: Vector2, radius: float) -> Rect2:
	return Rect2(_position - Vector2(radius, radius), Vector2(radius * 2, radius * 2))


func point_in_rect(point: Vector2, rect: Rect2) -> bool:
	return rect.position.x < point.x and point.x < rect.end.x and \
			rect.position.y < point.y and point.y < rect.end.y
