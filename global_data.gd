extends Node

@export var levels = [
	"res://levels/level_1.tscn", 
	"res://levels/level_2.tscn", 
	"res://levels/level_3.tscn", 
	"res://levels/level_4.tscn", 
	"res://levels/level_5.tscn"
]

var level : int = 1
var level_index : int = 0


func next_level():
	level += 1
	go_to_level(level)


func go_to_level(new_level):
	level = new_level
	level_index = wrapi(level, 0, levels.size())
	get_tree().change_scene_to_file(levels[level_index - 1])
