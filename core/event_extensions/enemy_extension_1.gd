extends Enemy
@onready var vc: VelocityComponent = $VelocityComponent

func _ready() -> void:
	GlobalSignal.event.connect(on_event)

func on_event(event_id: int, state: bool) -> void:
	if event_id == 1:
		if state == true:
			vc.enabled = true
		else:
			vc.enabled = false
