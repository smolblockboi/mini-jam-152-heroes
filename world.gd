extends Node2D

signal game_won
signal game_lost

const LOSE_SCREEN = preload("res://lose_screen.tscn")
const WIN_SCREEN = preload("res://win_screen.tscn")

@onready var player = %Player
@onready var level_label = %LevelLabel


enum GAME_STATE {PLAYING, WON, LOST}
var game_state : GAME_STATE = GAME_STATE.PLAYING

var enemy_count : int = 0


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func _input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()


func _process(delta):
	level_label.text = "[%s]" % str(GlobalData.level)
	
	var count = 0
	for i in get_children():
		if i.is_in_group("enemy"):
			count += 1
	enemy_count = count
	
	if enemy_count <= 0:
		game_won.emit()


func _on_player_die():
	game_lost.emit()


func _on_game_won():
	game_state = GAME_STATE.WON
	player.collision.call_deferred("set_disabled", true)
	var new_screen = WIN_SCREEN.instantiate()
	add_child(new_screen)
	await get_tree().create_timer(2.0).timeout
	GlobalData.next_level()


func _on_game_lost():
	game_state = GAME_STATE.LOST
	var new_screen = LOSE_SCREEN.instantiate()
	add_child(new_screen)
	await get_tree().create_timer(2.0).timeout
	GlobalData.go_to_level(1)
