extends Node

var score = 0
var high_score = 0

var file_path = "user://high_score.txt"

var muted = false

func update_score(new_score):
	score = new_score
	if score > high_score:
		high_score = score
		_save_high_score()

func _save_high_score():
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_line(String(high_score))
	file.close()


# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	if file.file_exists(file_path):
		file.open(file_path, File.READ)
		var score_s = file.get_line()
		file.close()
		high_score = int(score_s)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
