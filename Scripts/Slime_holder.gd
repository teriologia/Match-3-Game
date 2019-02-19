extends Node2D

var width = 8;
var height = 10;
var slime_pieces = [];
var slime_block = preload("res://scenes/Slime.tscn");

signal remove_slime;

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


func _on_Grid_make_slime(board_position):
	if slime_pieces.size() == 0:
		slime_pieces = make_2d_array();
	var current = slime_block.instance();
	add_child(current);
	current.position = Vector2(board_position.x * 70 + 42, -board_position.y * 70 + 820);
	slime_pieces[board_position.x][board_position.y] = current;
	pass # replace with function body


func _on_Grid_damage_slime(board_position):
	if slime_pieces[board_position.x][board_position.y] != null:
		slime_pieces[board_position.x][board_position.y].take_damage(1);
		if slime_pieces[board_position.x][board_position.y].health <=0:
			slime_pieces[board_position.x][board_position.y].queue_free();
			slime_pieces[board_position.x][board_position.y] = null;
			emit_signal("remove_slime",board_position);
	pass # replace with function body