class_name Ball
extends CharacterBody2D

@export var min_speed : float = 50.0
@export var max_speed : float = 200.0

@onready var body = $Body
@onready var bounce_shape = $BounceArea/CollisionShape2D

@onready var audio_player = $AudioStreamPlayer
var hit_sounds = [
	load("res://audio/blip.wav"), 
	load("res://audio/blip2.wav")
]

var move_speed : float = 100.0
var hit_power : float = 2.0
var bounce_power : float = 0.95

var invincible : bool = false


func _ready():
	max_speed = clampf(max_speed + (GlobalData.level * 50), 100.0, 300.0)
	min_speed = max_speed * 0.50
	velocity = Vector2.DOWN * max_speed


func _input(event):
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()


func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	
	if invincible:
		bounce_shape.shape.height = 26.0
		bounce_shape.shape.radius = 6.0
	else:
		bounce_shape.shape.height = 8.0
		bounce_shape.shape.radius = 4.0
	
	if collision:
		audio_player.set_stream(hit_sounds.pick_random())
		audio_player.play(0.0)
		if !invincible and collision.get_collider() is Enemy:
			collision.get_collider().get_hit_by_ball()
			velocity = velocity.bounce(collision.get_normal())
		elif invincible and collision.get_collider() is Enemy:
			collision.get_collider().get_hit_by_ball()
		else:
			velocity = velocity.bounce(collision.get_normal())
			move_speed = clamp_bounce_speed(move_speed)
		velocity = velocity.normalized() * move_speed
		body.frame = 0
		invincible = false


func clamp_bounce_speed(speed):
	return clampf(speed * bounce_power, min_speed, max_speed)

func clamp_hit_speed(speed):
	return clampf(speed * hit_power, min_speed, max_speed)


func _on_bounce_area_area_entered(area):
	audio_player.set_stream(hit_sounds.pick_random())
	audio_player.play(0.0)
	print(area)
	
	if area.is_in_group("sword") or area.is_in_group("shield"):
		
		var area_side = (area.owner.global_position - global_position)
		
		if area_side.x > 0:
			move_speed = clamp_hit_speed(move_speed)
			velocity.x = -move_speed
		elif area_side.x < 0:
			move_speed = clamp_hit_speed(move_speed)
			velocity.x = move_speed
		
		if area_side.y < 0:
			if area.is_in_group("sword"):
				velocity.y = move_speed * 1.05
		elif area_side.y > 0:
			if area.is_in_group("sword"):
				velocity.y = -move_speed * 1.05
		
		if area.is_in_group("shield"):
			move_speed = max_speed
			body.frame = 1
			velocity.y = 0
			invincible = true


func _on_bounce_area_body_entered(body):
	if body is Player and !invincible:
		body.die.emit()
	if body is Enemy:
		body.get_hit_by_ball()


func _on_visible_on_screen_notifier_2d_screen_exited():
	if get_parent().game_state == 0 and get_parent().player:
		get_parent().player.die.emit()
	queue_free()
