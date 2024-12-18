extends Node2D

var letter_scene = preload("res://letter.tscn")
var letters: Dictionary = {}
var word: String = ""

var cells = {}

const SIZE = Vector2i(11, 11)

var just = [1.0, 9.0/8.0, 5.0/4.0, 4.0/3.0, 3.0/2.0, 5.0/3.0, 15.0/8.0, 2.0]
var pitches = [0, 2, 4, 1, 3, 5, 2, 4, 6, 3, 5, 7, 4, 6, 8]

var dictionary: Dictionary = {}
var letter_sequences = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var delay = 0.0
	var pitch = 0
	for i in range((SIZE.x - 1) / 2 - 1, (SIZE.x - 1) / 2 + 2):
		for j in range((SIZE.y - 1) / 2 - 1, (SIZE.y - 1) / 2 + 2):
			new_letter(Vector2i(i, j), delay, pitches[pitch])
			delay += 0.1
			pitch += 1
	
	print("Cells", cells)
	
	var file = FileAccess.open("res://sowpods.txt", FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line()
		dictionary[line] = null
	
	#for key in cells:
		#var i = key.x
		#var j = key.y
		#var letter: Letter = cells[key]
		#for rel_x in [-1, 0, 1]:
			#for rel_y in [-1, 0, 1]:
				#if rel_x == 0 and rel_y == 0:
					#continue
				#var x = i + rel_x
				#var y = j + rel_y
				#var new_key = Vector2i(x, y)
				#if new_key in cells:
					#letter.add_neighbour(cells[new_key])

const WILDCARD_LOCATIONS = {
	Vector2i(1, 1): null, Vector2i(1, 5): null, Vector2i(1, 9): null,
	Vector2i(5, 1): null, Vector2i(5, 5): null, Vector2i(5, 9): null,
	Vector2i(9, 1): null, Vector2i(9, 5): null, Vector2i(9, 9): null,
}

func new_letter(location: Vector2i, delay: float, pitch: int):
	var letter: Letter = letter_scene.instantiate()
	letter.location = location
	letter.delay = delay
	letter.position = Vector2(64 * location.x, 64*location.y)

	add_child(letter)
	
	letter.play_note_delayed(pitch, delay)

	if location in WILDCARD_LOCATIONS:
		print("Wildcard", location)
		letter.set_letter("")

	if letter.letter in letters:
		letters[letter.letter].append(letter)
	else:
		letters[letter.letter] = [letter]
	cells[location] = letter


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


const RELATIVES = [
	Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1),
	Vector2i(0, -1), Vector2i(0, 1),
	Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]

func get_neighbours(location: Vector2i) -> Array[Letter]:
	var neighbours: Array[Letter] = []
	for relative in RELATIVES:
		var new_key = location + relative
		print("New key",location, new_key)
		if new_key in cells:
			neighbours.append(cells[new_key])
	print("Found neighbours", neighbours)
	return neighbours


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var s = event.as_text_keycode()
	
		for key in cells:
			var letter = cells[key]
			letter.set_status(0)
		
		if event.keycode == KEY_BACKSPACE:
			word = word.substr(0, len(word) - 1)
		elif event.keycode == KEY_ENTER:
			if len(letter_sequences) > 0 and word in dictionary:
				$FoundWords.text += word + "\n"
				
				letter_sequences.shuffle()
				var pitch = 0
				var delay = 0.0
				for sequence in letter_sequences:
					var i = 0
					for letter: Letter in sequence:
						if letter.used_status == 0:
							letter.set_used_status(1)
							for relative in RELATIVES:
								var new_key = letter.location + relative
								if new_key not in cells and new_key.x >= 0 and new_key.y >= 0 and new_key.x < SIZE.x and new_key.y < SIZE.y:
									new_letter(new_key, delay, pitches[pitch])
									pitch += 1
									delay += 0.1
						if letter.letter == "":
							letter.set_letter(word[i])
							i += 1

				word = ""
				$Word.text = word
				return
		else:
			word += s
		
		$Word.text = word
			
		if len(word) == 0:
			return
		
		if word[0] not in letters:
			return

		var letters = letters[word[0]]
		letter_sequences = []
		for letter in letters:
			letter_sequences.append([letter])
		
		for c in word.substr(1):
			var new_letter_sequences = []
			for letter_sequence in letter_sequences:
				var current: Letter = letter_sequence[-1]
				var valid_neighbours = []
				for neighbour in get_neighbours(current.location):
					if neighbour.letter == c or neighbour.letter == "": 
						var dup = false
						for letter in letter_sequence:
							if letter == neighbour:
								dup = true
						#var dup = neighbour in letter_sequence
						if not dup:
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
			for i in range(len(letter_sequence)):
				var letter = letter_sequence[i]
				if i == len(letter_sequence) - 1:
					letter.set_status(2)
				else:
					letter.set_status(1)
