extends TextureProgressBar

func _ready() -> void:
	self.value = Global.player_health

func _on_health_regen_timeout() -> void:
	if Global.player_health < 100:
		Global.player_health += 1
		self.value = Global.player_heaalth
