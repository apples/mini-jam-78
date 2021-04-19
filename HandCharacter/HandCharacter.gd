extends Node2D

export(float) var initial_delay = 1.0
export(float) var delay_multiplier = 0.95
export(float) var initial_slap_speed = 1.0
export(float) var slap_multiplier = 0.95

export(float) var spawn_range_x = 16 * 14
export(float) var spawn_range_y = 16 * 7

export(float) var spawn_start_x = 16
export(float) var spawn_start_y = 16

export(NodePath) var target_path = null
export(float) var target_radius = 16 * 3

signal slap(slapper)

var target = null

var rng = RandomNumberGenerator.new()

var mode = 0

var delay = initial_delay
var slap_speed = initial_slap_speed

var timer = delay

var physics_processed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	if target_path != null:
		target = get_node(target_path)
	hide()
	$SlapArea/SlapShape.disabled = true
	$Body/BodyShape.disabled = true
	set_physics_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match mode:
		0:
			timer -= delta
			if timer <= 0:
				timer = slap_speed
				mode = 1
				_reveal_hand()
		1:
			var time_scale = timer / slap_speed
			if time_scale == 0:
				time_scale = 0.00001
			timer -= delta / time_scale
			if timer <= 0:
				mode = 2
				_begin_slap()
			scale = Vector2(1.0 + time_scale, 1.0 + time_scale)
		2:
			if physics_processed > 1:
				_slap()
				_end_slap()
				mode = 3
				_begin_wait()
		3:
			timer -= delta
			if timer <= 0:
				mode = 0
				_hide_hand()
			pass

func _physics_process(delta):
	physics_processed += 1

func _reveal_hand():
	show()
	scale = Vector2(2, 2)
	if target != null:
		var target_x = clamp(target.position.x, spawn_start_x + target_radius, spawn_start_x + spawn_range_x - target_radius)
		var target_y = clamp(target.position.y, spawn_start_y + target_radius, spawn_start_y + spawn_range_y - target_radius)
		position.x = -target_radius + target_x + rng.randf_range(0, target_radius) + rng.randf_range(0, target_radius)
		position.y = -target_radius + target_y + rng.randf_range(0, target_radius) + rng.randf_range(0, target_radius)
	else:
		position.x = rng.randf_range(spawn_start_x, spawn_start_x + spawn_range_x)
		position.y = rng.randf_range(spawn_start_y, spawn_start_y + spawn_range_y)

func _hide_hand():
	hide()
	$SlapArea/SlapShape.disabled = true
	$Body/BodyShape.disabled = true
	delay *= delay_multiplier
	slap_speed *= slap_multiplier
	timer = delay

func _begin_slap():
	$SlapArea/SlapShape.disabled = false
	physics_processed = 0
	set_physics_process(true)

func _slap():
	emit_signal("slap", self)
	for b in $SlapArea.get_overlapping_bodies():
		if b.is_in_group("player"):
			b.get_slapped()

func _end_slap():
	$SlapArea/SlapShape.disabled = true
	set_physics_process(false)

func _begin_wait():
	timer = delay
	$Body/BodyShape.disabled = false
	
