extends CharacterBody2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()


func _on_detector_body_entered(body: Node2D) -> void:
	if is_on_floor():
		var tween = get_tree().create_tween()
		var tween1 = get_tree().create_tween()
		tween.tween_property(self, "position", position - Vector2(0, 25), 0.3)
		tween1.tween_property(self, "modulate:a", 0, 0.3)
		tween.tween_callback(queue_free)
		Global.gold += 1
		queue_free()
