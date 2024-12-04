extends TileMap

var grid
enum Layers{hidden,revealed}
var source = 0
const hidden_tile = Vector2(18,0)
const hidden_tile_alt = 1
var reavealed = []
var tile_to_atlas = {}
var score1 = 0
var score2 = 0
var turns = 1
var p1
var p2


func _on_button_2_pressed() -> void:
	grid = 2
	setup()
	updateText()
	$"../CanvasLayer/Control".visible = false
	players()


func _on_button_4_pressed() -> void:
	grid = 4
	setup()
	updateText()
	$"../CanvasLayer/Control".visible = false
	players()

func _on_button_6_pressed() -> void:
	grid = 6
	setup()
	updateText()
	$"../CanvasLayer/Control".visible = false
	players()

func players():
	p1 = $"../CanvasLayer/LineEdit".text
	p2 = $"../CanvasLayer/LineEdit2".text
	$"../CanvasLayer/LineEdit2".visible = false
	$"../CanvasLayer/LineEdit".visible = false
	$"../CanvasLayer/Player1".text = p1
	$"../CanvasLayer/Player2".text = p2
	updateText()


func getTiles():
	var chosen_tile = []
	var options = range(18)
	options.shuffle()
	for i in range(grid * int(grid/2)):
		var current = Vector2(options.pop_back(),0)
		for j in range(2):
			chosen_tile.append(current)
	chosen_tile.shuffle()
	return chosen_tile

func setup():
	var cards = getTiles()
	for y in range(grid):
		for x in range(grid):
			var current_spot = Vector2(x, y)
			placeFaceDown(current_spot)
			var card_atlas_coords = cards.pop_back()
			tile_to_atlas[current_spot] = card_atlas_coords
			self.set_cell(Layers.revealed, current_spot, source, card_atlas_coords)

func placeFaceDown(coords: Vector2):
	self.set_cell(Layers.hidden, coords, source, hidden_tile, hidden_tile_alt)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var global_clicked = event.position
			var pos_clicked = Vector2(local_to_map(to_local(global_clicked)))
			print(pos_clicked)
			var current_tile_alt = get_cell_alternative_tile(Layers.hidden, pos_clicked)
			if current_tile_alt == 1 and reavealed.size() < 2:
				self.set_cell(Layers.hidden, pos_clicked, -1)
				reavealed.append(pos_clicked)
				if reavealed.size() == 2:
					checkPair()

func checkPair():
	if tile_to_atlas[reavealed[0]] == tile_to_atlas[reavealed[1]]:
		if(turns%2==0):
			score2 += 1
		else:
			score1 += 1
		reavealed.clear()
	else:
		putBack()
		turns += 1
	updateText()

func putBack():
	await self.get_tree().create_timer(1.5).timeout
	for spot in reavealed:
		placeFaceDown(spot)
	reavealed.clear()

func updateText():
	$"../CanvasLayer/score_lb".text = " %d" % score1
	$"../CanvasLayer/score_lb2".text = " %d" % score2
	if(turns%2==0):
		$"../CanvasLayer/status".text = str(p2)+"'s turn"
	else:
		$"../CanvasLayer/status".text = str(p1)+"'s turn"
	$"../CanvasLayer/turn_lb".text = "Turn: %d" % turns


func _on_restart_pressed() -> void:
	setup()
	turns = 1
	score1 = 0
	score2 = 0
	updateText()
