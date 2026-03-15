extends Node2D

@onready var health_bar = $CanvasLayer/HealthBar

func _ready() -> void:
	if health_bar:
		health_bar.value = Global.player_health
