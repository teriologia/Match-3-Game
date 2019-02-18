extends Node2D

var width = 8;
var height = 10;
var ice_pieces = [];
var ice_block = preload("res://scenes/ice.tscn");
var broken_ice = preload("res://Art/broken_ice.png");

func _ready():
	pass;
	
func make_2d_array():
	var array = [];
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null);
	return array;
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Grid_make_ice(board_position):
	if ice_pieces.size() == 0:
		ice_pieces = make_2d_array();
	var current = ice_block.instance();
	add_child(current);
	current.position = Vector2(board_position.x * 70 + 42, -board_position.y * 70 + 820);
	ice_pieces[board_position.x][board_position.y] = current;
	pass # replace with function body


func _on_Grid_damage_ice(board_position):
	if ice_pieces[board_position.x][board_position.y] != null:
		ice_pieces[board_position.x][board_position.y].take_damage(1);
		if ice_pieces[board_position.x][board_position.y].health <=0:
			ice_pieces[board_position.x][board_position.y].queue_free();
			ice_pieces[board_position.x][board_position.y] = null;
	pass # replace with function body
