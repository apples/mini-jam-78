extends Node2D

var reset_timer = null

var fruit_scene = preload("res://Fruit/Fruit.tscn")
var fruit_timer = 1.0
var spawn_range_x = 16 * 13
var spawn_range_y = 16 * 6
var spawn_start_x = 16 + 8
var spawn_start_y = 16 + 8

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	Global.score = 0
	if Global.muted:
		$BGM.stop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if reset_timer != null:
		reset_timer -= delta
		if reset_timer <= 0:
			get_tree().reload_current_scene()
	else:
		fruit_timer -= delta
		if fruit_timer <= 0:
			_spawn_fruit()
			fruit_timer = 1.0
	if Input.is_action_just_pressed("mute"):
		Global.muted = not Global.muted
	if Global.muted and $BGM.playing:
		$BGM.stop()
	elif not Global.muted and not $BGM.playing:
		$BGM.play()


func _on_PlayerCharacter_slapped():
	reset_timer = 2.5
	$GameoverSfx.play()

func _spawn_fruit():
	var fruit = fruit_scene.instance()
	fruit.connect("collected", self, "_on_fruit_collected")
	fruit.position.x = rng.randf_range(spawn_start_x, spawn_start_x + spawn_range_x)
	fruit.position.y = rng.randf_range(spawn_start_y, spawn_start_y + spawn_range_y)
	add_child(fruit)

func _on_fruit_collected(fruit, player):
	fruit.queue_free()
	Global.update_score(Global.score + 1)
	$CrunchSfx.play()



func _on_HandCharacter_slap(slapper):
	$SlapSfx.play()
