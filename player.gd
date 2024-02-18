class_name Player
extends CharacterBody2D

signal die

@onready var anim_player = $AnimationPlayer
@onready var body = $Body
@onready var collision = $CollisionShape2D

enum STATES {NORMAL, ATTACKING, HURT}
var current_state : STATES = STATES.NORMAL

@export var move_speed : float = 100.0


func _input(event):
	if event is InputEventMouseMotion:
		global_position.y = event.position.y
	
	if event.is_action_pressed("sword_attack"):
		current_state = STATES.ATTACKING
		anim_player.play("attack")
	if event.is_action_pressed("shield_attack"):
		current_state = STATES.ATTACKING
		anim_player.play("shield_bash")


func _physics_process(delta):
	if current_state == STATES.NORMAL:
		var input_dir : Vector2 = Vector2.ZERO
		#var input_dir : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		velocity = input_dir * move_speed
		
		if velocity != Vector2.ZERO:
			if velocity.x < 0:
				body.scale.x = -1
			elif velocity.x > 0:
				body.scale.x = 1
			anim_player.play("run")
		else:
			anim_player.play("run")
		
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"attack", "shield_bash":
			current_state = STATES.NORMAL


func _on_die():
	collision.call_deferred("set_disabled", true)
	hide()
