extends CharacterBody2D

enum {
	MOVE,
	ATTACK,
}

const SPEED = 300.0
var JUMP_VELOCITY = -500.0
var alive = true

var max_depth = 700

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer

var health = 100
var gold = 0
var telep = 1
var state = MOVE

func _physics_process(delta: float) -> void:
	
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	if alive == true:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			animPlayer.play("jump")

		if velocity.y > 0:
			animPlayer.play("fall")
			
		if position.y >= max_depth:
			queue_free()
			get_tree().change_scene_to_file("res://menu.tscn")			


		if health <= 0:
			alive = false
			animPlayer.play("death")
			await anim.animation_finished
			queue_free()
			get_tree().change_scene_to_file("res://menu.tscn")
			
		if telep == 0:
			telep = -1
			get_tree().change_scene_to_file("res://level_2.tscn")

		move_and_slide()

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
	elif direction == 1:
		anim.flip_h = false
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
func attack_state():
	velocity.x = 0
	animPlayer.play("attack")
	await animPlayer.animation_finished
	state = MOVE
