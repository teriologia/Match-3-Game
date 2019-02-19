extends Node2D

enum{wait, move}
var state

#grid variables
export (int) var width;
export (int) var height;
export (int) var x_start;
export (int) var y_start;
export (int) var offset;
export (int) var y_offset;
export (PoolVector2Array) var spaces;
export (PoolVector2Array) var ice_spaces;
export (PoolVector2Array) var lock_spaces;
export (PoolVector2Array) var concreate_spaces;
export (PoolVector2Array) var slime_spaces;

signal damage_ice;
signal make_ice;
signal make_lock;
signal damage_lock;
signal make_concreate;
signal damage_concreate;
signal make_slime;
signal damage_slime;

var all_possible_pieces = [
preload("res://scenes/Yellow_piece.tscn"),
preload("res://scenes/Blue_piece.tscn"),
preload("res://scenes/Green_Pieces.tscn"),
preload("res://scenes/Green_purple_piece.tscn"),
preload("res://scenes/Purple_yellow_piece.tscn"),
];

var damaged_slime = false;
var piece_one = null;
var piece_two = null;
var last_place = Vector2(0,0);
var last_direction = Vector2(0,0);
var first_touch = Vector2(0,0);
var final_touch = Vector2(0,0);
var controlling = false;

var move_checked = false;
var all_pieces = [];

func _ready():
	state = move;
	randomize();
	all_pieces = make_2d_array();
	spawn_pieces();
	spawn_ice();
	spawn_lock();
	spawn_concreate();
	spawn_slime();
	
func check_non_movable(place):
	if is_in_array(spaces, place):
		return true;
	if is_in_array(concreate_spaces, place):
		return true
	if is_in_array(slime_spaces, place):
		return true;
	return false;
	
func restricted_move(place):
	if is_in_array(lock_spaces,place):
		return true;
	return false;

func is_in_array(array, item):
	for i in array.size():
		if array[i] == item:
			return true
	return false;

func make_2d_array():
	var array = [];
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null);
	return array;
	
func spawn_pieces():
	for i in width:
		for j in height:
			if !check_non_movable(Vector2(i,j)):
				var rand = floor(rand_range(0, all_possible_pieces.size()));
				var piece = all_possible_pieces[rand].instance();
				var loops = 0;
				while(match_at(i,j,piece.color) && loops < 100):
					rand = floor(rand_range(0, all_possible_pieces.size()));
					loops +=1;
					piece = all_possible_pieces[rand].instance();
			
				add_child(piece);
				piece.position = grid_to_pixels(i, j);
				all_pieces [i][j] = piece;

func spawn_ice():
	for i in ice_spaces.size():
		emit_signal("make_ice", ice_spaces[i]);
		

func spawn_lock():
	for i in lock_spaces.size():
		emit_signal("make_lock", lock_spaces[i]);

func spawn_concreate():
	for i in concreate_spaces.size():
		emit_signal("make_concreate", concreate_spaces[i]);
		
func spawn_slime():
	for i in slime_spaces.size():
		emit_signal("make_slime", slime_spaces[i]);

func match_at(i, j, color):
	if i>1:
		if all_pieces[i-1][j] != null && all_pieces[i - 2][j] !=null:
			if all_pieces[i-1][j].color == color && all_pieces[i-2][j].color == color:
				return true;
	if j>1:
		if all_pieces[i][j-1] != null && all_pieces[i][j-2] !=null:
			if all_pieces[i][j-1].color == color && all_pieces[i][j - 2].color == color:
				return true;

func grid_to_pixels(column,row):
	var new_x = x_start + offset * column;
	var new_y = y_start + -offset * row;
	return Vector2(new_x,new_y);
	
func pixels_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset);
	var new_y = round((pixel_y - y_start) / -offset);
	return Vector2(new_x, new_y);
	pass;

func is_in_grid(grid_position):
	if grid_position.x >=0 && grid_position.x <= width:
		if grid_position.y >=0 && grid_position.y <= height:
			return true;
	return false;

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixels_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			first_touch = pixels_to_grid(get_global_mouse_position().x, get_global_mouse_position().y);
			controlling = true;
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixels_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)) && controlling:
			controlling = false;
			final_touch = pixels_to_grid(get_global_mouse_position().x, get_global_mouse_position().y);
			touch_difference(first_touch, final_touch); 
		
			
	pass;

func swap_pieces(column,row,direction):
	var first_piece = all_pieces[column][row];
	var second_piece = all_pieces[column + direction.x][row + direction.y];
	if first_piece != null && second_piece !=null:
		if !restricted_move(Vector2(column, row)) && !restricted_move(Vector2(column, row) + direction):
			store_info(first_piece, second_piece, Vector2(column, row), direction);
			state = wait;
			all_pieces[column][row] = second_piece;
			all_pieces[column + direction.x][row + direction.y] = first_piece;
			first_piece.move(grid_to_pixels(column + direction.x, row + direction.y));
			second_piece.move(grid_to_pixels(column, row));
			
			if !move_checked:
				find_matches(); 
		
func store_info(first_piece, second_piece, currentplace, direction):
	piece_one = first_piece;
	piece_two = second_piece;
	last_place = currentplace;
	last_direction = direction;
	pass;

func reSwap():
	if piece_one !=null && piece_two !=null:
		swap_pieces(last_place.x, last_place.y, last_direction);
	state = move;
	move_checked = false;
	
	pass;

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1;
	if abs(difference.x) > abs (difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1,0));
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1,0));
	if abs(difference.y) > abs (difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0,1));
		if difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0,-1));
	pass;

func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] !=null:
				var currentcolor = all_pieces[i][j].color;
				if i > 0 && i<width-1:
					if !is_piece_null(i-1,j) && !is_piece_null(i+1,j):
						if all_pieces[i - 1][j].color == currentcolor && all_pieces[i+1][j].color == currentcolor:
							match_and_dim(all_pieces[i - 1][j]);
							match_and_dim(all_pieces[i][j]);
							match_and_dim(all_pieces[i + 1][j]);
							
				if j > 0 && j<height-1:
					if !is_piece_null(i,j-1) && !is_piece_null(i,j+1):
						if all_pieces[i][j-1].color == currentcolor && all_pieces[i][j+1].color == currentcolor:
							match_and_dim(all_pieces[i][j-1]);
							match_and_dim(all_pieces[i][j]);
							match_and_dim(all_pieces[i][j+1]); 
	get_parent().get_node("destroy_timer").start();

func is_piece_null(column,row):
	if all_pieces[column][row] ==null:
		return true;
	return false;

func match_and_dim(item):
	item.matched = true;
	item.dim();
	pass;

func destroy_matched():
	var was_matched = false;
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					damage_spacial_block(i,j);
					was_matched = true;
					all_pieces[i][j].queue_free();
					all_pieces[i][j] = null;
	move_checked = true;
	if was_matched:
		get_parent().get_node("Collapse_timer").start();
	else:
		reSwap();

func check_concreate(column, row):
	if column < width - 1:
		emit_signal("damage_concreate", Vector2(column + 1, row));
	if column > 0:
		emit_signal("damage_concreate", Vector2(column - 1, row));
	if row < height - 1:
		emit_signal("damage_concreate", Vector2(column, row + 1));
	if row > 0:
		emit_signal("damage_concreate", Vector2(column, row - 1));
		
func check_slime(column, row):
	if column < width - 1:
		emit_signal("damage_slime", Vector2(column + 1, row));
	if column > 0:
		emit_signal("damage_slime", Vector2(column - 1, row));
	if row < height - 1:
		emit_signal("damage_slime", Vector2(column, row + 1));
	if row > 0:
		emit_signal("damage_slime", Vector2(column, row - 1));

func damage_spacial_block(column, row):
	emit_signal("damage_ice", Vector2(column,row));
	emit_signal("damage_lock",Vector2(column,row));
	check_concreate( column, row );
	check_slime( column,row);
	pass;

func _on_destroy_timer_timeout():
	
	destroy_matched();
	
func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !check_non_movable(Vector2(i,j)):
				for k in range(j+1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixels(i,j));
						all_pieces[i][j] = all_pieces[i][k];
						all_pieces[i][k] = null;
						break;
	get_parent().get_node("Refill_timer").start();
	
func _on_Collapse_timer_timeout():
	collapse_columns();
	pass # replace with function body

func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !check_non_movable(Vector2(i,j)):
				var rand = floor(rand_range(0, all_possible_pieces.size()));
				var piece = all_possible_pieces[rand].instance();
				var loops = 0;
				while(match_at(i,j,piece.color) && loops < 100):
					rand = floor(rand_range(0, all_possible_pieces.size()));
					loops +=1;
					piece = all_possible_pieces[rand].instance();
					
				add_child(piece);
				piece.position = grid_to_pixels(i, j-y_offset);
				piece.move(grid_to_pixels(i,j));
				all_pieces [i][j] = piece;
	after_refill();
	pass

func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i,j, all_pieces[i][j].color):
					find_matches()
					get_parent().get_node("destroy_timer").start();
					return;
	if !damaged_slime:
		generate_slime();
	state = move;
	move_checked = false;
	damaged_slime = false;

func generate_slime():
	if slime_spaces.size() > 0:
		var slime_made = false;
		var slime_tracker = 0;
		while !slime_made and slime_tracker <100:
			var random_number = floor(rand_range(0, slime_spaces.size()));
			var current_x = slime_spaces[random_number].x;
			var current_y = slime_spaces[random_number].y;
			var neighbor = find_normal_neigbor(current_x, current_y);
			
			if neighbor != null:
				all_pieces[neighbor.x][neighbor.y].queue_free();
				all_pieces[neighbor.x][neighbor.y] = null;
				slime_spaces.append(Vector2(neighbor.x, neighbor.y));
				emit_signal("make_slime", Vector2(neighbor.x, neighbor.y));
				slime_made = true;
			slime_tracker += 1;
	pass
	 

func find_normal_neigbor(column, row):
	if is_in_grid(Vector2(column+1, row)):
		if all_pieces[column +1][row] != null:
			return Vector2(column +1, row);
	if is_in_grid(Vector2(column-1, row)):
		if all_pieces[column -1][row] != null:
			return Vector2(column -1, row);
	if is_in_grid(Vector2(column, row+1)):
		if all_pieces[column][row+1] != null:
			return Vector2(column, row+1);
	if is_in_grid(Vector2(column, row-1)):
		if all_pieces[column][row-1] != null:
			return Vector2(column, row-1);
			
	return null;
	pass

func _on_Refill_timer_timeout():
	refill_columns();
	pass # replace with function body
	
func _on_lock_holder_remove_lock(place):
	for i in range(lock_spaces.size() - 1,-1,-1):
		if lock_spaces[i] == place:
			lock_spaces.remove(i);
	pass # replace with function body
	
func _on_concreate_holder_remove_concreate(place):
	for i in range(concreate_spaces.size() - 1,-1,-1):
		if concreate_spaces[i] == place:
			concreate_spaces.remove(i);
	pass # replace with function body
	

func _on_Slime_holder_remove_slime(place):
	damaged_slime = true;
	for i in range(slime_spaces.size() - 1,-1,-1):
		if slime_spaces[i] == place:
			slime_spaces.remove(i);
	pass # replace with function body



func _process(delta):
	if state == move:
		touch_input();

