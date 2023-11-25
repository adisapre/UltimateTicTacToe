extends Node

@export var circle_scene : PackedScene
@export var cross_scene : PackedScene
var player : int
var moves: int
var temp_marker
var player_panel_pos : Vector2i
var board_size: int
var cell_size: int
var grid_pos : Vector2i
var grid_data: Array
#big table win condition checker
var row_sum: int
var col_sum: int
var diag1_sum: int
var diag2_sum: int
var winner: int
# Called when the node enters the scene tree for the first time.
func _ready():
	board_size = $MainBoard.texture.get_width()
	#divide board size into cells (3x3)
	cell_size = board_size/3
	
	#get coord of small panel 
	
	player_panel_pos = $PlayerPanel.get_position()
	new_game()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# check if mouse is on board
			if event.position.x < board_size:
				#convert mouse position into grid location
				grid_pos = Vector2i(event.position/cell_size)
				if(grid_data[grid_pos.y][grid_pos.x] == 0):
					moves +=1
					grid_data[grid_pos.y][grid_pos.x] = player
					#place marker of player
					create_marker(player,grid_pos*cell_size + Vector2i(cell_size/2,cell_size/2))
					if check_win() != 0:
						print("Game Over")
						get_tree().paused = true
						$GameOverMenu.show()
						if winner == 1:
							$GameOverMenu.get_node("Result").text = "Player 1 Wins!"
						elif winner == -1:
							$GameOverMenu.get_node("Result").text = "Player 2 Wins!"
					elif(moves == 9):
						get_tree().paused = true
						$GameOverMenu.get_node("Result").text = "Tie!"
						$GameOverMenu.show()
					player *= -1
					#update info panel
					temp_marker.queue_free()
					create_marker(player,player_panel_pos+ Vector2i(cell_size/2,cell_size/2),true)
					print(grid_data)
				
				

func new_game():
	player = 1
	moves = 0
	winner = 0
	grid_data =[
		[0,0,0],
		[0,0,0],
		[0,0,0]
		]
	row_sum = 0
	col_sum = 0
	diag1_sum = 0
	diag2_sum = 0
	#clear markers
	get_tree().call_group("circles","queue_free")
	get_tree().call_group("crosses","queue_free")
		#create marker at starting player turn
	create_marker(player, player_panel_pos + Vector2i(cell_size/2,cell_size/2),true)
	$GameOverMenu.hide()
	get_tree().paused = false
	

func create_marker(player, position, temp = false):
	#create a marker node and add as child
	if player == 1:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if temp: temp_marker = circle
	else:
		var cross =  cross_scene.instantiate()
		cross.position = position
		add_child(cross)
		if temp: temp_marker = cross


func check_win():
	#add markers in each row
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diag1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diag2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
		
	#check player sum
		if row_sum == 3 or col_sum == 3 or diag1_sum == 3 or diag2_sum == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diag1_sum == -3 or diag2_sum == -3:
			winner = -1
	return winner


func _on_game_over_menu_restart():
	new_game()
