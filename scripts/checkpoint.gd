extends Area3D

@export var checkpoint_number = 1
@export var is_finish_line = false

func _ready():
	body_entered.connect(_on_body_entered)
	collision_layer = 2
	collision_mask = 1

func _on_body_entered(body):
	if body.is_in_group("player_car"):
		body.checkpoint_passed(checkpoint_number, is_finish_line)
		print("Checkpoint ", checkpoint_number, " passed!")
