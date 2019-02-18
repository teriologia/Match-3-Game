extends Node2D


export (int) var health;

var broken_ice = preload("res://Art/broken_ice.png");
onready var ice_broke = get_node("Sprite");

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
func take_damage(damage):
	health -= damage;
	if health <= 1:
		ice_broke.set_texture(broken_ice);
