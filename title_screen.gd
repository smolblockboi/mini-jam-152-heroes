extends CanvasLayer


func _on_play_pressed():
	get_tree().change_scene_to_file("res://levels/level_1.tscn")
