extends TileMap

var WIDTH : int = 14
var HEIGHT : int = 16
const PIXEL_SIZE : int = 16

#note:  new blocks can't be bigger then 3x3
#		don't question i know you don't remember
#note:  add line deletion you lazy bastard

const Square = [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]
const Corner = [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1)]
const L_Shape = [Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),Vector2i(1,2)]
const Zig = [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(2,1)]
const Poll = [Vector2i(0,0),Vector2i(0,1),Vector2i(0,2)]
const T_Shape = [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(1,1)]
const Dot = [Vector2i(0,0)]

const Blocks = [L_Shape,Corner,Square,Poll,Zig,T_Shape,Dot]

var need_new_block : bool = true
var current_block_offset : Vector2i
var current_block_color : int = 0
var current_block

var input_enabled : bool = false

func Set_Block(pos : Vector2i,BlockColor : int) -> void:
	set_cell(0,pos,0,Vector2i(BlockColor,0))
func Get_Block_Color(pos : Vector2i) -> int:
	return get_cell_atlas_coords(0,pos).x
func Copy_TileMap() -> Array[int]:
	var copy : Array[int] = []
	copy.resize(WIDTH*HEIGHT)
	for y in range(0,HEIGHT):
		for x in range(0,WIDTH):
			copy[(y * WIDTH) + x] = get_cell_atlas_coords(0,Vector2i(x,y)).x
	return copy
func Update_Border(dir : bool):
	for x in range(1,WIDTH-1):
		erase_cell(0,Vector2i(x,0))
	var offset = 0
	if !dir:
		offset = WIDTH-1
	for y in range(HEIGHT):
		Set_Block(Vector2i(offset,y),7)
func rotate_matrix(matrix: Array) -> Array:
	var rows = matrix.size()
	if rows == 0:
		return []
	var cols = matrix[0].size()
	var rotated = []
	for j in range(cols):
		rotated.append([])
		for i in range(rows):
			rotated[j].append(matrix[rows - i - 1][j])
	return rotated
func rotate_block() -> void:
	var tile_array : Array = [[0,0,0],[0,0,0],[0,0,0]]
	for tile in current_block:
		tile_array[tile.y][tile.x] = 1
	tile_array = rotate_matrix(tile_array)
	var rotated_block : Array
	for y in range(tile_array.size()):
		for x in range(tile_array[0].size()):
			if tile_array[y][x] == 1:
				rotated_block.append(Vector2i(x,y))
	current_block = rotated_block
func rotate_point(point: Vector2i, array_size: Vector2i) -> Vector2i:
	var rows = array_size.x
	var cols = array_size.y
	var rotated_x = point.y
	var rotated_y = cols - point.x - 1
	return Vector2i(rotated_y, rotated_x)
func load_tilemap_data() -> Array:
	var used_cells: Array = get_used_cells(0)
	var tilemap_data := []

	for row in range(WIDTH):
		tilemap_data.append([])
		for col in range(HEIGHT):
			var tile_id: int = Get_Block_Color(Vector2i(row,col))
			tilemap_data[row].append(tile_id)
	return tilemap_data
func _input(event):
	if !input_enabled:
		return;
	var event_str = event.as_text()
	if event_str == "E" and !(event.is_released()) and !(event.is_echo()):
		var data = load_tilemap_data()
		var new_data = rotate_matrix(data)
		var rows := new_data.size()
		var cols = new_data[0].size()
		clear()
		for row in range(rows):
			for col in range(cols):
				var tile_id: int = new_data[row][col]
				Set_Block(Vector2i(row,col),tile_id)
		data[current_block_offset.x][current_block_offset.y] = 8
		new_data = rotate_matrix(data)
		for x in range(WIDTH):
			for y in range(HEIGHT):
				if new_data[y][x] == 8:
					current_block_offset = Vector2i(y,x)
					break
		rotate_block()
		rotate_block()
		rotate_block()
		current_block_offset.y -= 2
		var tmp = WIDTH
		WIDTH = HEIGHT
		HEIGHT = tmp
		Update_Border(true)
	elif event_str == "Q" and !(event.is_released()) and !(event.is_echo()):
		var data = load_tilemap_data()
		var new_data = rotate_matrix(rotate_matrix(rotate_matrix(data)))
		var rows := new_data.size()
		var cols = new_data[0].size()
		clear()
		for row in range(rows):
			for col in range(cols):
				var tile_id: int = new_data[row][col]
				Set_Block(Vector2i(row,col),tile_id)
		data[current_block_offset.x][current_block_offset.y] = 8
		new_data = rotate_matrix(data)
		new_data = rotate_matrix(new_data)
		new_data = rotate_matrix(new_data)
		for x in range(WIDTH):
			for y in range(HEIGHT):
				if new_data[y][x] == 8:
					current_block_offset = Vector2i(y-2,x)
					break
		rotate_block()
		var tmp = WIDTH
		WIDTH = HEIGHT
		HEIGHT = tmp
		Update_Border(false)
	elif event_str == "D" and !(event.is_released()) and !(event.is_echo()):
		if Check_Bounds(Vector2i(1,0)):
			for tile in current_block:
				Set_Block(tile + current_block_offset,current_block_color)
			return;
		for tile in current_block:
			erase_cell(0,tile + current_block_offset)
		current_block_offset.x += 1
		for tile in current_block:
			Set_Block(tile + current_block_offset,current_block_color)
	elif event_str == "A" and !(event.is_released()) and !(event.is_echo()):
		if Check_Bounds(Vector2i(-1,0)):
			for tile in current_block:
				Set_Block(tile + current_block_offset,current_block_color)
			return;
		for tile in current_block:
			erase_cell(0,tile + current_block_offset)
		current_block_offset.x -= 1
		for tile in current_block:
			Set_Block(tile + current_block_offset,current_block_color)
	elif event_str == "S" and !(event.is_released()) and !(event.is_echo()):
		if Check_Bounds(Vector2i(0,1)):
			for tile in current_block:
				Set_Block(tile + current_block_offset,current_block_color)
			return;
		for tile in current_block:
			erase_cell(0,tile + current_block_offset)
		current_block_offset.y += 1
		for tile in current_block:
			Set_Block(tile + current_block_offset,current_block_color)
	elif event_str == "R" and !(event.is_released()) and !(event.is_echo()):
		for tile in current_block:
			erase_cell(0,tile + current_block_offset)
		rotate_block()
		for tile in current_block:
			Set_Block(tile + current_block_offset,current_block_color)
func _process(delta):
	var window = get_window().size
	var x_offset = (window.x / 2) - (WIDTH*PIXEL_SIZE)
	var y_offset = (window.y / 2) - (HEIGHT*PIXEL_SIZE)
	position = Vector2(x_offset,y_offset)
func Spawn_New_Block(block,color):
	var offset = Vector2i((WIDTH/2)-1,1)
	for tile in block:
		set_cell(0,tile + offset,0,Vector2i(color,0))
func AttemptUpdateBlock() -> bool:
	for tile in current_block:
		var loc = Vector2i(tile.x,tile.y+1)
		if loc in current_block:
			continue
		elif Get_Block_Color(loc + current_block_offset) != -1:
			return false
	for tile in current_block:
		var new_loc = tile + current_block_offset
		erase_cell(0,new_loc)
	for tile in current_block:
		var new_loc = tile + current_block_offset + Vector2i(0,1)
		Set_Block(new_loc,current_block_color)
		
	current_block_offset.y += 1
	return true
func _on_block_fall_timer_timeout():
	if need_new_block:
		var block = Blocks[randi_range(0,Blocks.size()-1)]
		var color = randi_range(0,6)
		Spawn_New_Block(block,color)
		current_block_color = color
		current_block_offset = Vector2i((WIDTH/2)-1,1)
		current_block = block
		need_new_block = false
		input_enabled = true
		var fill_layers : Array[int] = []
		for col in range(HEIGHT-1):
			if Check_For_Fill(col):
				fill_layers.append(col)
		print(fill_layers)
	else:
		need_new_block = !AttemptUpdateBlock()
		if need_new_block:
			input_enabled = false
func Check_Bounds(dir : Vector2i) -> bool:
	for tile in current_block:
		erase_cell(0,tile + current_block_offset)
	var copy = load_tilemap_data()
	for col in range(copy.size()):
		for row in range(copy[col].size()):
			for tile in current_block:
				var tmp = tile + current_block_offset + dir
				if copy[tmp.x][tmp.y] != -1:
					return true
	return false
func Check_For_Fill(col : int) -> bool:
	var offset = Vector2i(1,col)
	for x in range(WIDTH-1):
		var pos = offset + Vector2i(x,0)
		if Get_Block_Color(pos) == -1:
			return false
	return true
