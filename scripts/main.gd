extends Node3D

func _ready():
	var car_scene = Global.get_selected_car()
	if car_scene:
		var car_instance = car_scene.instantiate()
		car_instance.position = Vector3(0, 1, -40)
		add_child(car_instance)
	else:
		var default_car = load("res://scenes/car.tscn")
		if default_car:
			var car_instance = default_car.instantiate()
			car_instance.postion = Vector3(0, 1, -40)
			add_child(car_instance)
