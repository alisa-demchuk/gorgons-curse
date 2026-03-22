extends TextureProgressBar

@onready var health_text = $"../HealthText"
@onready var health_anim = $"../HealthAnim"

func _ready() -> void:
	self.value = Global.player_health

func _on_health_regen_timeout() -> void:
	if Global.player_health < 100:
		Global.player_health += 1
		#health_anim.play("health_received")
		self.value = Global.player_health
