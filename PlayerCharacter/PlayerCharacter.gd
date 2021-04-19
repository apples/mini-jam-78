extends KinematicBody2D

export var move_speed = 1

signal slapped

var moving = false
var flip = false
var slapped = false

func get_slapped():
	rotate(PI / 2)
	$Shape.set_deferred("disabled", true)
	slapped = true
	emit_signal("slapped")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if moving and not slapped:
		$AnimatedSprite.play("WalkRight")
		$AnimatedSprite.flip_h = flip
	else:
		$AnimatedSprite.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not slapped:
		var input = Vector2(0, 0)
		if Input.is_action_pressed("walk_left"):
			input.x -= 1
		if Input.is_action_pressed("walk_right"):
			input.x += 1
		if Input.is_action_pressed("walk_down"):
			input.y += 1
		if Input.is_action_pressed("walk_up"):
			input.y -= 1
		move_and_slide(input * move_speed)
		moving = input.length_squared() != 0
		flip = moving and input.x < 0
	else:
		moving = false
		flip = false
