extends Enemy
@onready var vc: VelocityComponent = $VelocityComponent

func _ready() -> void:
	GlobalSignal.event.connect(on_event)

func on_event(event_id: int) -> void:
	if event_id == 1:
		vc.enabled = true
