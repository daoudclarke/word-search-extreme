@tool

class_name Letter extends Node2D

@export var font: Font = ThemeDB.fallback_font;
@export var font_size: int = 16
@export var default_background_color: Color
@export var highlighted_color: Color


var letter: String
var status: int = 0
var neighbours: Array[Letter] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randf() < 0.7:
		letter = "ETAONRISH"[randi_range(0, 8)]
	else:
		letter = "BCDFGJKLMPQUVWXYZ"[randi_range(0, 16)]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _draw():
	var size = font.get_string_size(letter, 0, -1, font_size)
	var color: Color
	match status:
		0: color = default_background_color
		1: color = highlighted_color
	draw_circle(Vector2.ZERO, 12, color)
	draw_string(font, Vector2(-0.5*size.x, 0.3*size.y), letter, 0, -1, font_size, Color("black"))
	

func add_neighbour(neighbour: Letter):
	neighbours.append(neighbour)


func set_found(found: bool):
	if found:
		status = 1
	else:
		status = 0
	queue_redraw()
