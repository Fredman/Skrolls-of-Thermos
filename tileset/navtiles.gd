extends TileMap

onready var posoffset = [ Vector2(), Vector2( cell_size.x, 0 ), cell_size, Vector2( 0, cell_size.y ) ]

func _ready():
	call_deferred( "setup_navtiles" )
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func setup_navtiles():
	var walls = $"../../walls"
	var space_state = get_world_2d().direct_space_state
	for y in range( 64 ):
		for x in range( 64 ):
			# get world position
			var worldpos = walls.map_to_world( Vector2( x, y ) )
			#if x == 0 and y == 0:
			#	print( "Worldpos: ", worldpos )
			# check position in physics engine
			var cell_taken = false
			for offset in posoffset:
				var results = space_state.intersect_point( \
						worldpos + offset, 32, [ ], 1 )
				if not results.empty():
					cell_taken = true
			# place cell
			if not cell_taken:
				set_cell( x, y, 0 )