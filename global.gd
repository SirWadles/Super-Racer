extends Node

var selected_car_path ="res://scenes/car.tscn"

func set_selected_car(scene_path):
	selected_car_path = scene_path

func get_selected_car():
	if ResourceLoader.exists(selected_car_path):
		return load(selected_car_path)
	else:
		print("Error: Scene not found")
		return load("res://scenes/car.tscn")
