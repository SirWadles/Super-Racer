extends Node

var selected_car_path ="res://scenes/car.tscn"

func get_selected_car():
	return load(selected_car_path)
