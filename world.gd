extends Node2D

signal game_won
signal game_lost

const LOSE_SCREEN = preload("res://lose_screen.tscn")
const WIN_SCREEN = preload("res://win_screen.tscn")

@onready var player = %Player
@onready var level_label = %LevelLabel

@onready var ball = $Ball
@onready var ball_marker = $BallMarker

@onready var balls_h_box = %BallsHBox

enum GAME_STATE {PLAYING, WON, LOST}
var game_state : GAME_STATE = GAME_STATE.PLAYING

var lives_count : int = 3
var enemy_count : int = 0


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func _input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()


func _process(delta):
	level_label.text = "Wave %s" % str(GlobalData.level)
	
	var count = 0
	for i in get_children():
		if i.is_in_group("enemy"):
			count += 1
	enemy_count = count
	
	if enemy_count <= 0:
		game_won.emit()


func on_lost_ball():
	lives_count -= 1
	for i in balls_h_box.get_children():
		i.hide()
	for i in lives_count:
		balls_h_box.get_child(i).show()
	if lives_count <= 0:
		game_lost.emit()
	else:
		ball.global_position = ball_marker.global_position
		ball.reset()


func on_princess_hit():
	game_lost.emit()


func _on_game_won():
	game_state = GAME_STATE.WON
	player.collision.call_deferred("set_disabled", true)
	var new_screen = WIN_SCREEN.instantiate()
	add_child(new_screen)
	await get_tree().create_timer(2.0).timeout
	GlobalData.next_level()


func _on_game_lost():
	player.die.emit()
	game_state = GAME_STATE.LOST
	var new_screen = LOSE_SCREEN.instantiate()
	add_child(new_screen)
	await get_tree().create_timer(2.0).timeout
	GlobalData.go_to_level(1)
