extends Node2D

export (String) var color;

var Move_tween;
var matched = false;

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	Move_tween = get_node("Move_animation");
	
func move(target):
	Move_tween.interpolate_property(
	self,
	"position",
	position,
	target,
	.3,
	Tween.TRANS_ELASTIC,
	Tween.EASE_OUT);
	
	Move_tween.start();

func dim():
	var sprite = get_node("Sprite");
	sprite.modulate = Color(1,1,1,.5);
	pass
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
