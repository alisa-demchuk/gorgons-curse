extends Node2D

@onready var health_bar = $HUD/HealthBar
	
func _ready() -> void:
	health_bar.value = Global.player_health
