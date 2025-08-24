extends CharacterBody3D
#Comments are for those who were smart and call me timothy cause im sending coal to a coal mine

@export_category("Car Properties")
@export var max_speed = 35.0
@export var acceleration = 15.0
@export var braking_force = 25.0
@export var reverse_speed = 15.0
@export var steering_angle = 25.0
@export var steering_speed = 3.0

@export_category("Drift Properties")
@export var can_drift = true
@export var drift_steering_multiplier = 1.5
@export var drift_acceleration_multiplier = 1.2
@export var min_drift_speed = 15.0

@export_category("Boost Properties")
@export var max_boost = 100.0
@export var boost_regen_rate = 10.0
@export var boost_consumption_rate = 25.0
@export var boost_multiplier = 1.5

var current_speed = 0.0
var current_steering = 0.0
var is_drifting = false
var current_boost = 100.0
var is_boosting = false

@onready var front_left_wheel: MeshInstance3D = $Wheels/FrontLeft
@onready var front_right_wheel: MeshInstance3D = $Wheels/FrontRight
@onready var rear_left_wheel: MeshInstance3D = $Wheels/RearLeft
@onready var rear_right_wheel: MeshInstance3D = $Wheels/RearRight
@onready var drift_particles: GPUParticles3D = $DriftParticles
@onready var boost_particles: GPUParticles3D = $BoostParticles

func _ready():
	current_boost = max_boost
	
	setup_particles()
	
	if drift_particles:
		drift_particles.emitting = false
		drift_particles.one_shot = false
	
	if boost_particles:
		boost_particles.emitting = false
		boost_particles.one_shot = false

func setup_particles():
	if drift_particles:
		var drift_material = ParticleProcessMaterial.new()
		drift_material.direction = Vector3(0, -1, 0)
		drift_material.spread = 45
		drift_material.initial_velocity_min = 1.5
		drift_material.initial_velocity_max = 2.5
		drift_material.gravity = Vector3(0, -2, 0)
		drift_material.linear_accel_min = -0.5
		drift_material.linear_accel_max = -1.5
		drift_material.damping_min = 1.5
		drift_material.damping_max = 2.5
		drift_particles.process_material = drift_material
		drift_particles.amount = 100
		drift_particles.lifetime = 1.0
		
		var drift_quad = QuadMesh.new()
		drift_quad.size = Vector2(0.5, 0.5)
		drift_particles.draw_pass_1 = drift_quad
	if boost_particles:
		var boost_material = ParticleProcessMaterial.new()
		boost_material.direction = Vector3(0, 0, -1)
		boost_material.spread = 15
		boost_material.initial_velocity_min = 8.0
		boost_material.initial_velocity_max = 12.0
		boost_material.linear_accel_min = 3.0
		boost_material.linear_accel_max = 7.0
		boost_material.damping_min = 0.5
		boost_material.damping_max = 1.5
		boost_particles.process_material = boost_material
		boost_particles.amount = 50
		boost_particles.lifetime = 0.5
		
		var boost_quad = QuadMesh.new()
		boost_quad.size = Vector2(0.3, 0.3)
		boost_particles.draw_pass_1 = boost_quad

func _physics_process(delta):
	handle_input(delta)
	apply_movement(delta)
	apply_visual_effects()
	handle_boost(delta)
	
	move_and_slide()

func handle_input(delta):
	var throttle_input = Input.get_action_strength("accelerate") - Input.get_action_strength("brake")
	var steering_input = Input.get_axis("steer_right", "steer_left")
	var drift_input = Input.is_action_pressed("drift") if can_drift else false
	
	is_boosting = Input.is_action_pressed("boost") and current_boost > 0 and abs(current_speed) > 5.0
	
	handle_throttle(throttle_input, delta)
	handle_steering(steering_input, drift_input, delta)
	handle_drift(drift_input)
	
func handle_throttle(throttle_input: float, delta: float):
	if throttle_input > 0:
		var effective_acceleration = acceleration
		if is_drifting:
			effective_acceleration *= drift_acceleration_multiplier
		current_speed += throttle_input * effective_acceleration * delta
	elif throttle_input < 0:
		if current_speed > 0:
			current_speed += throttle_input * braking_force * delta
		else:
			current_speed += move_toward(current_speed, 0, acceleration * 0.7 * delta)
	else:
		current_speed = move_toward(current_speed, 0, acceleration * 0.3 * delta)
	
	var speed_multiplier = boost_multiplier if is_boosting else 1.0
	var effective_max_speed = max_speed * speed_multiplier
	
	if current_speed > 0:
		current_speed = clamp(current_speed, 0, effective_max_speed)
	else:
		current_speed = clamp(current_speed, -reverse_speed, 0)

func handle_steering(steer_input: float, is_drifting_input: bool, delta: float):
	var target_steering = steer_input * steering_angle
	var steering_speed_multiplier = drift_steering_multiplier if is_drifting else 1.0
	
	current_steering = move_toward(
		current_steering,
		target_steering * steering_speed_multiplier,
		steering_speed * delta * steering_speed_multiplier
	)

func handle_drift(drift_input: bool):
	var was_drifting = is_drifting
	is_drifting = drift_input and abs(current_speed) > min_drift_speed and abs(current_steering) > 5.0
	
	if drift_particles:
		if is_drifting and not was_drifting:
			drift_particles.emitting = true
		elif not is_drifting and was_drifting:
			drift_particles.emitting = false

func apply_movement(delta):
	var turn_radians = deg_to_rad(current_steering) * delta * (1.0 + abs(current_speed) / max_speed * 0.5)
	rotate_y(turn_radians)
	var direction = -transform.basis.z
	velocity = direction * current_speed
	if not is_on_floor():
		velocity.y -= 30.0 * delta
	else:
		velocity.y = 0

func handle_boost(delta):
	if is_boosting:
		current_boost -= boost_consumption_rate * delta
		if current_boost <= 0:
			current_boost = 0
			is_boosting = false
	else:
		current_boost = min(current_boost + boost_regen_rate * delta, max_boost)
	if boost_particles:
		boost_particles.emitting = is_boosting

func apply_visual_effects():
	if front_left_wheel and front_right_wheel:
		var wheel_steer_angle = deg_to_rad(current_steering)
		front_left_wheel.rotation.y = wheel_steer_angle
		front_right_wheel.rotation.y = wheel_steer_angle

# Made the wheels spin in uninteded ways. Uncomment if you want to see something funny when turning
	#var wheel_spin_angle = fmod(get_physics_process_delta_time() * current_speed * 10.0, TAU)
	#set_wheel_spin(front_left_wheel, wheel_spin_angle)
	#set_wheel_spin(front_right_wheel, wheel_spin_angle)
	#set_wheel_spin(rear_left_wheel, wheel_spin_angle)
	#set_wheel_spin(rear_right_wheel, wheel_spin_angle)
#
#func set_wheel_spin(wheel: MeshInstance3D, angle: float):
	#if wheel:
		#var current_steer = wheel.rotation.y
		#wheel.rotation = Vector3(90, current_steer, angle)

func add_boost(amount: float):
	current_boost = min(current_boost + amount, max_boost)

func get_speed_ratio() -> float:
	return abs(current_speed) / max_speed

func is_car_drifting() -> bool:
	return is_drifting

func get_boost_ratio() -> float:
	return current_boost / max_boost
