extends Node2D

var width = 8;
var height = 10;
var concreate_pieces = [];
var concreate_block = preload("res://scenes/concreate.tscn");

signal remove_concreate;

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


func _on_Grid_make_concreate(board_position):
	if concreate_pieces.size() == 0:
		concreate_pieces = make_2d_array();
	var current = concreate_block.instance();
	add_child(current);
	current.position = Vector2(board_position.x * 70 + 42, -board_position.y * 70 + 820);
	concreate_pieces[board_position.x][board_position.y] = current;
	pass # replace with function body


func _on_Grid_damage_concreate(board_position):
	if concreate_pieces[board_position.x][board_position.y] != null:
		concreate_pieces[board_position.x][board_position.y].take_damage(1);
		if concreate_pieces[board_position.x][board_position.y].health <=0:
			concreate_pieces[board_position.x][board_position.y].queue_free();
			concreate_pieces[board_position.x][board_position.y] = null;
			emit_signal("remove_concreate",board_position);
	pass # replace with function body