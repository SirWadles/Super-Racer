extends Node

var selected_car_path ="res://scenes/sports_car.tscn"
var customization_data = {}

func set_selected_car(scene_path):
	selected_car_path = scene_path

func get_selected_car():
	if ResourceLoader.exists(selected_car_path):
		return load(selected_car_path)
	else:
		print("Error: Scene not found")
		return load("res://scenes/car.tscn")

func set_value(key, value):
	customization_data[key] = value

func get_value(key, default = null):
	return customization_data.get(key, default)
