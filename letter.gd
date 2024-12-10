@tool

class_name Letter extends Node2D

@export var font: Font = ThemeDB.fallback_font;
@export var font_size: int = 16
@export var default_background_color: Color
@export var highlighted_color: Color
@export var current_color: Color


var location: Vector2i
var letter: String
var status: int = 0
var used_status: int = 0
var neighbours: Array[Letter] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randf() < 0.7:
		letter = "ETAONRISH"[randi_range(0, 8)]
	else:
		letter = "BCDFGJKLMPQUVWXYZ"[randi_range(0, 16)]
	set_status(0)
	set_letter(letter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


#func _draw():
	#var size = font.get_string_size(letter, 0, -1, font_size)
	##draw_rect(Rect2(2, 2, 11, 12), color)
	##draw_circle(Vector2.ZERO, 12, color)
	##if used_status > 0:
		##draw_circle(Vector2.ZERO, 12, Color("black"), false, 2)
	#draw_string(font, Vector2(-10, 10), letter, 0, -1, font_size, Color("black"))
	

func add_neighbour(neighbour: Letter):
	neighbours.append(neighbour)


func set_status(value: int):
	status = value
	var color: Color
	match status:
		0: color = default_background_color
		1: color = highlighted_color
		2: color = current_color
	$ColorRect.color = color
	queue_redraw()

func set_used_status(value: int):
	used_status = value
	queue_redraw()

func set_letter(s: String):
	letter = s
	$Label.text = s
	queue_redraw()
