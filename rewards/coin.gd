extends KinematicBody2D

const MAX_VEL = 100
var vel = Vector2()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_dir( d ):
	vel = d * MAX_VEL

func _physics_process(delta):
	if vel.length() > 0:
		vel *= 0.97
		vel = move_and_slide( vel )
		if vel.length() < 0.1:
			vel *= 0
			set_physics_process( false )

var is_active = false
func _on_Area2D_body_entered(body):
	if not is_active: return
	is_active = false
	game.gamestate.energy += 30
	game.gamestate.coins += 1
	game.play_sfx( game.CHRYSTAL )
	queue_free()
	pass # replace with function body


func _on_Timer_timeout():
	is_active = true
	pass # replace with function body
