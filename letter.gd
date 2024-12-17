# @tool

class_name Letter extends Node2D

@export var font: Font = ThemeDB.fallback_font;
@export var font_size: int = 16
@export var default_background_color: Color
@export var highlighted_color: Color
@export var current_color: Color

@export var unused_color: Color
@export var used_color: Color
@export var used_5_color: Color
@export var used_7_color: Color


var delay: float
var location: Vector2i
var letter: String
var status: int = 0
var used_status: int = 0
var neighbours: Array[Letter] = []

var label_default: LabelSettings
var label_highlight: LabelSettings


const outline_scale = (56.0 + 1.0)/56.0
# print("Outline scale", outline_scale)
const JUST = [1.0, 9.0/8.0, 5.0/4.0, 4.0/3.0, 3.0/2.0, 5.0/3.0, 15.0/8.0, 2.0]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randf() < 0.7:
		letter = "ETAONRISH"[randi_range(0, 8)]
	else:
		letter = "BCDFGJKLMPQUVWXYZ"[randi_range(0, 16)]
	set_status(0)
	set_used_status(0)
	set_letter(letter)
	scale = Vector2(0, 0)
	var tween = create_tween()
	tween.tween_interval(delay)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
	
	rotation = -2*PI
	var tween2 = create_tween()
	tween2.tween_interval(delay)
	tween2.set_trans(Tween.TRANS_SINE)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(self, "rotation", 0.2, 0.5)
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property(self, "rotation", 0, 0.5)
	

func add_neighbour(neighbour: Letter):
	neighbours.append(neighbour)


func set_status(value: int):
	status = value
	var color: Color
	match status:
		0: color = default_background_color
		1: color = highlighted_color
		2: color = current_color
	#$Tile.color = color
	$Sprite2D.self_modulate = color
	
	if status > 0:
		$Label.label_settings = $Label.label_settings.duplicate()
		$Label.label_settings.shadow_offset = Vector2(5, 4)
	else:
		$Label.label_settings.shadow_offset = Vector2(0, 0)
	
	queue_redraw()

func set_used_status(value: int):
	used_status = value
	var color: Color
	match used_status:
		0: color = unused_color
		1: color = used_color
		2: color = used_5_color
		3: color = used_7_color
	z_index = 10 + used_status
	$Outline.self_modulate = color
	queue_redraw()

func set_letter(s: String):
	letter = s
	$Label.text = s
	queue_redraw()


func play_note_delayed(pitch: int, delay: float):
	var tween = create_tween()
	tween.tween_callback(play_note.bind(pitch)).set_delay(delay)

func play_note(pitch: int):
	var pitch_scale = 1.0
	while pitch > 7:
		pitch_scale *= 2
		pitch -= 7
	pitch_scale *= JUST[pitch]
	$AudioStreamPlayer2D.pitch_scale = pitch_scale
	$AudioStreamPlayer2D.play()
