extends CharacterBody2D

signal health_changed(new_health)

enum {
	MOVE,
	ATTACK,
	DEATH,
	DAMAGE
}

const SPEED = 300.0
var JUMP_VELOCITY = -500.0
var alive = true
var max_depth = 700

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
@onready var health_text = $HealthText
@onready var health_anim = $HealthAnim
@onready var leaves: GPUParticles2D = $Leaves


var max_health = 100
var telep = 1
var state = MOVE
var damage_current = 10

# ✅ Единое здоровье через Global
var health: int:
	get:
		return Global.player_health
	set(value):
		Global.player_health = clamp(value, 0, max_health)
		emit_signal("health_changed", Global.player_health)

func _ready() -> void:
	Signals.connect("enemy_attack", Callable(self, "_on_damage_recevied"))
	Global.player_damage = damage_current
	health_text.modulate.a = 0
	
func _physics_process(delta: float) -> void:
	var current_scene = get_tree().current_scene
	# Гравитация всегда
	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		DEATH:
			death_state()
			return  # ✅ Не выполняем остальное при смерти
		DAMAGE:
			damage_state()

	if alive:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			animPlayer.play("jump")

		if velocity.y > 0:
			animPlayer.play("fall")

		if position.y >= max_depth:
			# ✅ Нельзя queue_free() и потом обращаться к get_tree()
			get_tree().change_scene_to_file("res://menu.tscn")
			return

		if telep == 0:
			get_tree().change_scene_to_file("res://level_2.tscn")
			return

		move_and_slide()

	Global.player_pos = self.position

func move_state():
	var direction := Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * SPEED
		if velocity.y == 0:
			animPlayer.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("idle")

	if direction == -1:
		anim.flip_h = true
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:
		anim.flip_h = false
		$AttackDirection.rotation_degrees = 0

	if Input.is_action_just_pressed("attack"):
		state = ATTACK

	if Input.is_action_just_pressed("action(потом заменить на портал)"):
		get_tree().change_scene_to_file("res://new_level.tscn")

	if Input.is_action_just_pressed("action(перемещение к боссу, заменить на портал)"):
		get_tree().change_scene_to_file("res://level.tscn")

func death_state():
	velocity.x = 0
	animPlayer.play("death")
	await animPlayer.animation_finished
	# ✅ Сначала меняем сцену, потом queue_free
	get_tree().change_scene_to_file.bind("res://menu.tscn").call_deferred()

func damage_state():
	velocity.x = 0
	self.modulate = Color(1,0,0,1)
	if $AnimatedSprite2D.flip_h == true:
		velocity.x += 600
	else:
		velocity.x -= 600
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2(0,0), 0.1)
	tween.parallel().tween_property(self, "modulate", Color(1,1,1,1), 0.1)

	state = MOVE

func attack_state():
	velocity.x = 0
	animPlayer.play("attack")
	await animPlayer.animation_finished
	state = MOVE

func _on_damage_recevied(enemy_damage):
	state = DAMAGE
	#damage_anim()
	health -= enemy_damage
	health_text.text = str(enemy_damage)
	health_text.modulate.a = 1
	health_anim.play("damage_received")
	if health <= 0:
		state = DEATH
	print("HP: ", health)

#func damage_anim():
#	if $AnimatedSprite2D.flip_h == true:
#		velocity.x += 200
#	else:
#		velocity.x -= 200
#	var tween = get_tree().create_tween()
#	tween.parallel().tween_property(self, "velocity", Vector2(0,0), 0.2)

func steps():
	leaves.emitting = true
	leaves.one_shot = true
