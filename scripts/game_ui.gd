extends CanvasLayer

@onready var boost_bar = $MarginContainer/VBoxContainer/BoostBar
@onready var boost_label = $MarginContainer/VBoxContainer/BoostLabel
@onready var speed_label = $MarginContainer/VBoxContainer/SpeedLabel
@onready var timer_label = $MarginContainer/VBoxContainer/TimerLabel

var current_time = 0.0
var is_timer_running = false
var best_lap_time = 0.0
var current_lap_time = 0.0
var lap_count = 0

const SAVE_PATH = "user://best_lap.txt"

func _ready():
	boost_bar.min_value = 0.0
	boost_bar.max_value = 100.0
	boost_bar.value = 0.0
	
	boost_label.add_theme_font_size_override("font_size", 20)
	boost_label.add_theme_color_override("font_color", Color.BLACK)
	
	$MarginContainer.add_theme_constant_override("margin_right", 0)
	$MarginContainer.add_theme_constant_override("margin_top", 0)
	
	load_best_lap()

func _process(delta):
	if is_timer_running:
		current_time += delta
		current_lap_time += delta
		update_timer_display()

func update_boost_display(boost_amount: float, max_boost: float):
	var boost_percentage = (boost_amount / max_boost) * 100
	boost_bar.value = boost_percentage
	if boost_percentage > 70:
		boost_bar.add_theme_stylebox_override("fill", create_stylebox(Color.GREEN))
	elif boost_percentage > 30:
		boost_bar.add_theme_stylebox_override("fill", create_stylebox(Color.GOLD))
	else:
		boost_bar.add_theme_stylebox_override("fill", create_stylebox(Color.RED))
	boost_label.text = "BOOST: %d%%" % boost_percentage

func update_speed_display(current_speed: float, max_speed: float):
	var speed_mph = abs(current_speed) * 2.5
	speed_label.text = "SPEED: %d MPH" % speed_mph
	var speed_ratio = abs(current_speed) / max_speed
	print(speed_ratio)
	if not speed_ratio <= 1:
		speed_label.add_theme_color_override("font_color", Color.RED)
	else:
		speed_label.add_theme_color_override("font_color", Color.GOLDENROD)

func update_timer_display():
	timer_label.text = "TIME: %.2fs\nLAP: %d\nBEST: %s" % [
		current_lap_time,
		lap_count,
		format_time(best_lap_time) if best_lap_time > 0 else "--"
	]

func format_time(seconds: float) -> String:
	return "%.2fs" % seconds

func start_timer():
	is_timer_running = true
	current_time = 0.0
	current_lap_time = 0.0
	lap_count = 0
	print("Timer started!")

func stop_timer():
	is_timer_running = false
	print("Timer stoped! Final time: ", current_lap_time)

func complete_lap():
	if is_timer_running:
		lap_count += 1
		print("Lap %d completed: %.2fs" % [lap_count, current_lap_time])
		if best_lap_time == 0.0 or current_lap_time < best_lap_time:
			best_lap_time = current_lap_time
			save_best_lap()
			print("Best Lap! ", best_lap_time)
	current_lap_time = 0.0

func pause_timer():
	is_timer_running = false

func resume_timer():
	is_timer_running = true

func get_current_time() -> float:
	return current_time

func get_current_lap_time() -> float:
	return current_lap_time

func get_best_lap_time() -> float:
	return best_lap_time

func get_lap_count() -> float:
	return lap_count


func create_stylebox(color: Color) -> StyleBoxFlat:
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = color
	stylebox.corner_radius_top_left = 5
	stylebox.corner_radius_top_right = 5
	stylebox.corner_radius_bottom_left = 5
	stylebox.corner_radius_bottom_left = 5
	return stylebox

func save_best_lap():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.storage_float(best_lap_time)
		file.close()

func load_best_lap():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			best_lap_time = file.get_float()
			file.close()
