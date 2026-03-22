extends Node2D

@onready var light = $DirectionalLight2D
@onready var day_text = $CanvasLayer/DayText
@onready var animPlayer = $CanvasLayer/AnimationPlayer
@onready var health_bar = $CanvasLayer/HealthBar
@onready var player = $Player

var mushroom_preload = preload("res://Mobs/mushroom.tscn")

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var state = MORNING
var day_count: int

func _ready() -> void:
	health_bar.value = Global.player_health
	light.enabled = true 
	day_count = 1
	set_day_text()
	day_text_fade()

func morning_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.4, 30)
func evening_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.95, 30)

func _on_day_night_timeout() -> void:
	match state:
		MORNING:
			morning_state()
		EVENING:
			evening_state()
	if state < 3:
		state += 1
	else:
		state = MORNING
		day_count += 1
		set_day_text()
		day_text_fade()
		
func day_text_fade():
		animPlayer.play("day_text")
		
func set_day_text():
	day_text.text = "DAY " + str(day_count)


func _on_player_health_changed(new_health: Variant) -> void:
	health_bar.value = Global.player_health


func _on_spawner_timeout() -> void:
	pass # Replace with function body.


func mushroom_spawn():
	var mushroom = mushroom_preload.instantiate()
	mushroom.position = Vector2(randi_range(900, 1200), 625)
