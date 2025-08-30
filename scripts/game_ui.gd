extends CanvasLayer

@onready var boost_bar = $MarginContainer/VBoxContainer/BoostBar
@onready var boost_label = $MarginContainer/VBoxContainer/BoostLabel
@onready var timer_label = $MarginContainer/VBoxContainer/TimerLabel
@onready var speed_label = $MarginContainer/VBoxContainer/SpeedLabel

func _ready():
	boost_bar.min_value = 0.0
	boost_bar.max_value = 100.0
	boost_bar.value = 0.0
	
	boost_label.add_theme_font_size_override("font_size", 20)
	boost_label.add_theme_color_override("font_color", Color.BLACK)
	
	$MarginContainer.add_theme_constant_override("margin_right", 50)
	$MarginContainer.add_theme_constant_override("margin_top", 50)

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

func create_stylebox(color: Color) -> StyleBoxFlat:
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = color
	stylebox.corner_radius_top_left = 5
	stylebox.corner_radius_top_right = 5
	stylebox.corner_radius_bottom_left = 5
	stylebox.corner_radius_bottom_left = 5
	return stylebox
