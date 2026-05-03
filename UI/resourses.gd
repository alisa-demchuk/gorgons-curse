extends CanvasLayer

@onready var goldtext: Label = $Control/PanelContainer/HBoxContainer/Goldtext

func _process(delta: float) -> void:
	goldtext.text = str(Global.gold)
