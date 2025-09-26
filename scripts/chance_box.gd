extends Area3D

@export var rotation_speed = 50.0
@export var bounce_height = 0.5
@export var bounce_speed = 2.0

var original_y = 0.0
var time = 0.0
var collected = false

func _ready():
	original_y = global_position.y
	body_entered.connect(_on_body_entered)

func _process(delta):
	if collected:
		return
	rotate_y(deg_to_rad(rotation_speed) * delta)
	time += delta
	var bounce_offset = sin(time * bounce_speed) * bounce_height
	global_position.y = original_y + bounce_offset

func _on_body_entered(body):
	if collected:
		return
	if body.is_in_group("player_car"):
		collect(body)

func collect(car):
	collected = true
	var effect = get_random_effect()
	apply_effect(car, effect)
	play_collection_effects()
	await get_tree().create_timer(0.5).timeout
	queue_free()

func get_random_effect() -> String:
	var effects = [
		"speed_boost",
		"instant_boost",
		#"miniature",
		#"giant",
		"inversion"
	]
	return effects[randi() % effects.size()]

func apply_effect(car, effect: String):
	match effect:
		"speed_boost":
			car.apply_speed_boost(5.0, 3.0)
		"instant_boost":
			car.add_boost(50.0)
		#"miniature":
			#car.apply_size_change(0.5, 4.0)
		#"giant":
			#car.apply_size_change(2.0, 4.0)
		"inversion":
			car.apply_controls_inversion(5.0)

func play_collection_effects():
	var particles = GPUParticles3D.new()
	add_child(particles)
	particles.one_shot = true
	particles.emitting = true

func show_effect_notification(car, effect: String):
	if car.game_ui:
		var effect_names = {
			"speed_boost": "Speed Boost!",
			"instant_boost": "Boost Refill!",
			#"miniature": "Miniature Mode!",
			#"giant": "Giant Mode!",
			"inversion": "Controls Inverted!"
		}
		car.game_ui.show_effect_notification(effect_names[effect])
