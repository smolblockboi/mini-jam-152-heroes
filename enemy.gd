class_name Enemy
extends CharacterBody2D

@export var start_flipped : bool = false

@onready var body = $Body
@onready var anim_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D

enum STATES {NORMAL, HURT}
var current_state : STATES = STATES.NORMAL

var input_dir : Vector2
@export var move_speed : float = 100.0

var player_ref : Player


func _ready():
	await get_parent().ready
	if start_flipped:
		scale.x = -1
	player_ref = get_parent().player


func _physics_process(delta):
	if current_state == STATES.NORMAL:
		
		if get_parent().game_state != 0:
			input_dir = Vector2.LEFT
		else:
			input_dir = Vector2.ZERO
		
		velocity = input_dir * move_speed
		
		if velocity != Vector2.ZERO:
			if velocity.x < 0:
				#body.scale.x = -1
				pass
			elif velocity.x > 0:
				#body.scale.x = 1
				pass
			anim_player.play("run")
		else:
			anim_player.play("idle")
		
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()


func get_hit_by_ball():
	collision_shape.call_deferred("set_disabled", true)
	queue_free()
