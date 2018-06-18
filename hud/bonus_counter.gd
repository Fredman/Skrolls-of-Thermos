extends Node2D

const DOUBLE_KILL_INTERVAL = 0.7
var double_kill_active = false
var double_kill_counter = 0
var double_kill_timer = 0

const RAGE_KILL_INTERVAL = 5
var rage_kill_active = false
var rage_kill_counter = 0
var rage_kill_timer = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass


func _physics_process(delta):
	if double_kill_active:
		double_kill_timer += delta
		if double_kill_timer > DOUBLE_KILL_INTERVAL:
			double_kill_active = false
			double_kill_counter = 0
			double_kill_timer = 0
	if rage_kill_active:
		rage_kill_timer += delta
		if rage_kill_timer > RAGE_KILL_INTERVAL:
			rage_kill_active = false
			rage_kill_counter = 0
	pass


func enemy_dead():
	if not double_kill_active:
		double_kill_active = true
		double_kill_timer = 0
		double_kill_counter = 1
	elif double_kill_timer <= DOUBLE_KILL_INTERVAL:
		double_kill_reward()
		double_kill_counter = 0
		double_kill_active = false
		double_kill_timer = 0
	
	
	if not rage_kill_active:
		rage_kill_active = true
		rage_kill_counter = 1
		rage_kill_timer = 0
	elif rage_kill_timer <= RAGE_KILL_INTERVAL:
		rage_kill_counter += 1
		if rage_kill_counter >= 3:
			rage_kill_reward( rage_kill_counter )
		rage_kill_timer = 0
			
	pass

func reset_rewards():
	rage_kill_active = false
	double_kill_active = false
	pass

func double_kill_reward():
	print( "DOUBLE KILL REWARD" )
	game.gamestate.bonus += 5000
	var v = preload( "res://hud/double_kill.tscn" ).instance()
	v.position = $Position2D.position
	add_child( v )
	pass

func rage_kill_reward( n ):
	print( "RAGE KILL ", n )
	game.gamestate.bonus += 500 * n
	var v = preload( "res://hud/rage_kill.tscn" ).instance()
	v.set_kill_count( n )
	v.position = $Position2D2.position
	add_child( v )
	pass