extends Node2D

var letter_scene = preload("res://letter.tscn")
var letters: Dictionary = {}
var word: String = ""

var cells = {}
var cell_letters = {}

const SIZE = Vector2i(11, 11)

var just = [1.0, 9.0/8.0, 5.0/4.0, 4.0/3.0, 3.0/2.0, 5.0/3.0, 15.0/8.0, 2.0]
var pitches = [0, 2, 4, 1, 3, 5, 2, 4, 6, 3, 5, 7, 4, 6, 8, 5, 7, 9]

var dictionary: Dictionary = {}
var letter_sequences = []
var big_words = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file = FileAccess.open("res://sowpods.txt", FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line()
		dictionary[line] = null
		if len(line) == 9:
			big_words.append(line)

	var start_word = big_words[randi_range(0, len(big_words) - 1)]
	print("Start word: ", start_word)

	var letter_index = {"": []}
	for j in range((SIZE.x - 1) / 2 - 1, (SIZE.x - 1) / 2 + 2):
		for k in range((SIZE.y - 1) / 2 - 1, (SIZE.y - 1) / 2 + 2):
			letter_index[""].append(Vector2i(j, k))
	
	var sequences = get_letter_sequences(start_word, letter_index, 1)
	sequences.shuffle()

	var i = 0
	for location in sequences[0]:
		cell_letters[location] = start_word[i]
		i += 1

	var delay = 0.0
	var count = 0
	for j in range((SIZE.x - 1) / 2 - 1, (SIZE.x - 1) / 2 + 2):
		for k in range((SIZE.y - 1) / 2 - 1, (SIZE.y - 1) / 2 + 2):
			new_letter(Vector2i(j, k), delay, pitches[count % len(pitches)])
			delay += 0.1
			count += 1
	
	
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

	if location in cell_letters:
		letter.set_letter(cell_letters[location])

	if letter.letter in letters:
		letters[letter.letter].append(location)
	else:
		letters[letter.letter] = [location]
	cells[location] = letter


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


const RELATIVES = [
	Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1),
	Vector2i(0, -1), Vector2i(0, 1),
	Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]


func get_neighbours(location: Vector2i) -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = []
	for relative in RELATIVES:
		var new_key = location + relative
		neighbours.append(new_key)
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
				update_with_word(word, letter_sequences)
				word = ""
				$Word.text = word
				return
		else:
			word += s
		
		$Word.text = word
			
		if len(word) == 0:
			return
		
		letter_sequences = get_letter_sequences(word, letters, 10)
		
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
				var letter = cells[letter_sequence[i]]
				if i == len(letter_sequence) - 1:
					letter.set_status(2)
				else:
					letter.set_status(1)


func get_letter_sequences(word: String, letter_index: Dictionary, max_sequences: int) -> Array:
	var sequences = []
	var indexes = []

	var word_letters = []
	for i in range(len(word)):
		var letters_for_word = letter_index.get(word[i], []) + letter_index.get("", [])
		if len(letters_for_word) == 0:
			return []
		word_letters.append(letters_for_word)
		

	while true:
		if len(indexes) < len(word):
			indexes.append(0)
		var i = len(indexes) - 1
		var letter = word[i]
		var new_letter_location = word_letters[i][indexes[i]]
		var skip = false
		if i > 0:
			var old_letter_location = word_letters[i - 1][indexes[i - 1]]
			var neighbours = get_neighbours(old_letter_location)
			
			if new_letter_location not in neighbours:
				skip = true
			#else:
				#for j in range(len(indexes)):
					#if word_letters[j][indexes[j]] == new_letter_location:
						#skip = true

		if not skip and len(indexes) == len(word):
			# We have completed a sequence
			var sequence = []
			for j in range(len(indexes)):
				sequence.append(word_letters[j][indexes[j]])
			sequences.append(sequence)
			skip = true
			if len(sequences) >= max_sequences:
				break

		if skip:
			if len(indexes) == 0:
				break
			indexes[-1] += 1
			while indexes[-1] >= len(word_letters[len(indexes) - 1]):
				indexes.pop_back()
				if len(indexes) == 0:
					print("Found sequences while popping", sequences)
					return sequences
				
				indexes[-1] += 1

	print("Found sequences", sequences)
	return sequences

#func get_letter_sequences_old(word: String, letter_index: Dictionary) -> Array:
	#var word_letters
	#if word[0] in letter_index:
		#word_letters = letter_index[word[0]] + letter_index[""]
	#else:
		#word_letters = letter_index[""]
#
	#var sequences = []
	#for letter in word_letters:
		#sequences.append([letter])
	#
	#print("Letter sequences", sequences)
	#for c in word.substr(1):
		#var new_letter_sequences = []
		#for letter_sequence in sequences:
			#var current: Letter = letter_sequence[-1]
			#var valid_neighbours = []
			#for neighbour in get_neighbours(current.location, cell_index):
				#if neighbour.letter == c or neighbour.letter == "": 
					#var dup = false
					#for letter in letter_sequence:
						#if letter == neighbour:
							#dup = true
					##var dup = neighbour in letter_sequence
					#if not dup:
						#var new_letter_sequence = letter_sequence.duplicate()
						#new_letter_sequence.append(neighbour)
						#new_letter_sequences.append(new_letter_sequence)
		#sequences = new_letter_sequences
	#return sequences



func update_with_word(word: String, letter_sequences: Array):
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
							new_letter(new_key, delay, pitches[pitch % len(pitches)])
							pitch += 1
							delay += 0.1
				if letter.letter == "":
					letter.set_letter(word[i])
					i += 1
