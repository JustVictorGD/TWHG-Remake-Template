extends Button
class_name AudibleButton

## This is just a button but plays the "menu click" sound when pressed.

func _pressed() -> void:
	SFX.play(SFX.sounds.MENU_CLICK)
