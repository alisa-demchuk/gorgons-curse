extends CharacterBody2D

enum {
	MOVE,
	ATTACK,
	DEATH
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
var player_pos

func _ready() -> void:
	Signals.connect("enemy_attack", Callable(self, "_on_damage_recevied"))

func _physics_process(delta: float) -> void:
	
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		DEATH:
			death_state()
	
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
			
		if telep == 0:
			telep = -1
			get_tree().change_scene_to_file("res://level_2.tscn")


		move_and_slide()
		
	player_pos = self.position
	Signals.emit_signal("player_position_update", player_pos)

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
		
func death_state ():
	velocity.x = 0
	animPlayer.play("death")
	await animPlayer.animation_finished
	queue_free()
	get_tree().change_scene_to_file.bind("res://menu.tscn").call_deferred()
		
func attack_state():
	velocity.x = 0
	animPlayer.play("attack")
	await animPlayer.animation_finished
	state = MOVE

func _on_damage_recevied (enemy_damage):
	health -= enemy_damage
	if health <= 0:
		health = 0
		state = DEATH

	print(health)
