extends TileMap

onready var sourcemap = get_parent()

func _ready():
	call_deferred( "set_shadows" )



func set_shadows():
	var cellrect = sourcemap.get_used_rect()
	for y in range( 128 ):
		for x in range( 128 ):
			var cur_cell = sourcemap.get_cell( x, y )
			if cur_cell >= 0 and cur_cell < 9: continue
			var cell_above = sourcemap.get_cell( x, y - 1 )
			#if cell_above >= 0:
			#	print( cell_above )
			var cell_right = sourcemap.get_cell( x + 1, y )
			var has_above = false
			var has_right = false
			
			#print( cur_cell )
			
			if cell_above >= 0 and cell_above < 9: has_above = true
			if cell_right >= 0 and cell_right < 9: has_right = true
			
			if has_above and has_right: set_cell( x, y, 2 )
			elif has_above and not has_right: set_cell( x, y, 1 )
			elif not has_above and has_right: set_cell( x, y, 0 )

