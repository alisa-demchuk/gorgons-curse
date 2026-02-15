extends Node2D

func _ready():
	$HitBox/CollisionShape2D.disabled = true


func _on_hit_box_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
