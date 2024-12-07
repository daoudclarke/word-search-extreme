extends Node2D

var letter_scene = preload("res://letter.tscn")
var letters: Dictionary = {}
var word: String = ""

var cells = {}

const SIZE = Vector2i(10, 10)

var just = [1.0, 9.0/8.0, 5.0/4.0, 4.0/3.0, 3.0/2.0, 5.0/3.0, 15.0/8.0, 2.0]


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
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var s = event.as_text_keycode()
		
		if event.keycode == KEY_BACKSPACE:
			word = word.substr(0, len(word) - 1)
		else:
			word += s
		
		$Word.text = word
	
		for key in cells:
			var letter = cells[key]
			letter.set_found(false)
		
		if len(word) == 0:
			return
		
		if word[0] not in letters:
			return

		var letters = letters[word[0]]
		var letter_sequences = []
		for letter in letters:
			letter_sequences.append([letter])
		
		for c in word.substr(1):
			print("Letter sequences ", letter_sequences, " ", c)
			var new_letter_sequences = []
			for letter_sequence in letter_sequences:
				var current: Letter = letter_sequence[-1]
				print("Current ", current, " ", current.neighbours)
				var valid_neighbours = []
				for neighbour in current.neighbours:
					if neighbour.letter == c:
						var new_letter_sequence = letter_sequence.duplicate()
						new_letter_sequence.append(neighbour)
						new_letter_sequences.append(new_letter_sequence)
			letter_sequences = new_letter_sequences
		
		if len(letter_sequences) > 0:
			var pitch = len(word) - 1
			var pitch_scale = 1.0
			while pitch > 7:
				pitch_scale *= 2
				pitch -= 7
			pitch_scale *= just[pitch]
			$AudioStreamPlayer2D.pitch_scale = pitch_scale
			$AudioStreamPlayer2D.play()

		for letter_sequence in letter_sequences:
			for letter in letter_sequence:
				letter.set_found(true)
