extends Node3D

func _ready():
	var car_scene = load("res://scenes/car.tscn")
	var car_instance = car_scene.instantiate()
	car_instance.position = Vector3(0, 1, -40)
	add_child(car_instance)
