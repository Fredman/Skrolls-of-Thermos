extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_kill_count( n ):
	$scaler/Label.text = "RAGE\nKILL: %d" % [n]
