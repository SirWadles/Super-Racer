extends CanvasLayer

@onready var boost_bar = $Control/MarginContainer/VBoxContainer/BoostBar
@onready var boost_label = $Control/MarginContainer/VBoxContainer/BoostLabel
@onready var timer_label = $Control/MarginContainer/VBoxContainer/TimerLabel
@onready var speed_label = $Control/MarginContainer/VBoxContainer/SpeedLabel

var race_time: float = 0.0
var is_racing: bool = false

func _ready():
	if boost_label:
		boost_label.add_theme_font_size_override("font_size", 20)
		boost_label.add_theme_color_override("font_color", Color.BLACK)
	if boost_bar:
		boost_bar.min_value = 0.0
		boost_bar.max_value = 100.0
		boost_bar.value = 0.0

func _process(delta):
	if is_racing:
		race_time += delta
		update_timer_display()

func update_boost_display(boost_amount: float, max_boost: float):
	var boost_percentage = (boost_amount / max_boost) * 100
	boost_label.text = "BOOST: %d%%" % boost_percentage
	if boost_percentage > 70:
		boost_bar.add_theme_stylebox_override("fill", create_stylebox(Color.GREEN))
	elif boost_percentage > 30:
		boost_bar.add_theme_stylebox_override("fill", create_stylebox(Color.GOLD))
	else:
		boost_bar.add_theme_stylebox_override("fill", create_stylebox(Color.RED))

func update_speed_display(speed: float, max_speed: float):
	var speed_kmh = abs(speed) * 3.6
	speed_label.text = "SPEED: %.0f km/h" % speed_kmh
	var speed_ratio = abs(speed) / max_speed
	if speed_ratio > 0.8:
		speed_label.add_theme_color_override("font_color", Color.RED)
	elif speed_ratio > 0.5:
		speed_label.add_theme_color_override("font_color", Color.GOLD)
	else:
		speed_label.add_theme_color_override("font_color", Color.WHITE)

func start_race_timer():
	race_time = 0.0
	is_racing = true

func stop_race_timer():
	is_racing = false

func reset_race_timer():
	race_time = 0.0
	update_timer_display()

func update_timer_display():
	var minutes = int(race_time) / 60
	var seconds = int(race_time) % 60
	var milliseconds = int((race_time - int(race_time)) * 100)
	timer_label.text = "TIME: %02d:%02d.%02d" % [minutes, seconds, milliseconds]

func create_stylebox(color: Color) -> StyleBoxFlat:
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = color
	stylebox.corner_radius_top_left = 5
	stylebox.corner_radius_top_right = 5
	stylebox.corner_radius_bottom_left = 5
	stylebox.corner_radius_bottom_left = 5
	return stylebox
