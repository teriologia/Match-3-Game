extends Node2D

export (int) var health;
var broken_concreate = preload("res://Art/concreate_broken.png");

onready var concreate_broke = get_node("Sprite");

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
func take_damage(damage):
	health -= damage;
	if health <= 1:
		concreate_broke.set_texture(broken_concreate);
