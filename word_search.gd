extends Node2D

var letter_scene = preload("res://letter.tscn")
var letters: Dictionary = {}
var word: String = ""

var cells = {}

const SIZE = Vector2i(10, 10)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in SIZE.x:
		for j in SIZE.y:
			var letter = letter_scene.instantiate()
			letter.position = Vector2(i * 25, j * 25)
			add_child(letter)
			if letter.letter in letters:
				letters[letter.letter].append(letter)
			else:
				letters[letter.letter] = [letter]
			cells[Vector2i(i, j)] = letter
	
	for i in SIZE.x:
		for j in SIZE.y:
			var letter: Letter = cells[Vector2i(i, j)]
			if i > 0:
				letter.add_neighbour(cells[Vector2i(i-1, j)])
			if j > 0:
				letter.add_neighbour(cells[Vector2i(i, j-1)])
			if i < SIZE.x - 1:
				letter.add_neighbour(cells[Vector2i(i+1, j)])
			if j < SIZE.y - 1:
				letter.add_neighbour(cells[Vector2i(i, j+1)])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var s = event.as_text_keycode()
		word += s
		var letters = letters[word[0]]
		var letter_sequences = []
		for letter in letters:
			letter_sequences.append([letter])
		
		for letter_sequence in letter_sequences:
			var current: Letter = letter_sequence[0]
			for c in word.substr(1):
				var valid_neighbours = []
				for neighbour in current.neighbours:
					if neighbour.letter == c:
						letter_seque.append()
				var new_letters = []
				if s in letters:
					var found = letters[s]
					for f in found:
						f.set_found()
