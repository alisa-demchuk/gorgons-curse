extends CharacterBody2D

var chase = false
var speed = 100
@onready var anim = $AnimatedSprite2D
var alive = true
var health = 10000

# ✅ Получаем позицию игрока через сигнал, как в mushroom.gd
var player_pos: Vector2 = Vector2.ZERO

func _ready():
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))

func _on_player_position_update(pos):
	player_pos = pos

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if alive:
		if chase:
			var direction = (player_pos - self.position).normalized()
			velocity.x = direction.x * speed
			anim.play("run")

			if direction.x < 0:
				anim.flip_h = true
			else:
				anim.flip_h = false
		else:
			velocity.x = 0
			anim.play("idle")

	move_and_slide()

func _on_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true

func _on_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false

func _on_death_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		death()

func _on_death_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		alive = false
		anim.play("attack1")
		await anim.animation_finished
		if $Death2.overlaps_body(body):
			# ✅ Используем сигнал вместо прямого доступа
			Signals.emit_signal("enemy_attack", 50)
		alive = true

func death():
	alive = false
	anim.play("death")
	await anim.animation_finished
	queue_free()
