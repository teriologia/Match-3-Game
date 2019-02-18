extends Node2D


export (int) var health;
onready var lock_broke = get_node("Sprite");
var damaged_lock_1 = preload("res://Art/disable_1.png");
var damaged_lock_2 = preload("res://Art/disable_2.png");
var damaged_lock_3 = preload("res://Art/disable_3.png");

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
func take_damage_lock(damage):
	health -= damage;
	if health == 3:
		lock_broke.set_texture(damaged_lock_1);
	elif health == 2:
		lock_broke.set_texture(damaged_lock_2);
	elif health == 1:
		lock_broke.set_texture(damaged_lock_3);
