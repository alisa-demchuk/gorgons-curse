extends CharacterBody2D

enum {
	MOVE,
	ATTACK,
	BLOCK,
	SLIDE
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
			pass
		ATTACK:
			pass
		BLOCK:
			pass
		SLIDE:
			pass
		
	
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
			
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
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
			
		if health <= 0:
			alive = false
			animPlayer.play("death")
			await anim.animation_finished
			queue_free()
			get_tree().change_scene_to_file("res://menu.tscn")
			
		if telep == 0:
			telep = -1
			get_tree().change_scene_to_file("res://level.tscn")

		move_and_slide()
