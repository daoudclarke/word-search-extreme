@tool

class_name Letter extends Node2D

@export var font: Font = ThemeDB.fallback_font;

var letter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[randi_range(0, 25)]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _draw():
	var size = font.get_string_size(letter)
	draw_string(font, -0.5*size, letter)
	
