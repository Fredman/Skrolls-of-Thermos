extends Sprite

const BOXWIDTH = 128

func _ready():
	texture = $Viewport.get_texture()
	region_rect = Rect2( global_position - ( BOXWIDTH / 2.0 - 16 ) * Vector2( 1, 1 ), BOXWIDTH * Vector2( 1, 1 ) )
	$Viewport/particles.global_position = global_position
	if game.camera: game.camera.shake( 0.35, 30, 2 )
	game.play_sfx( game.EXPLOSION, rand_range( 0.9, 1.1 ) )


func set_xplosion_position( ):
	region_rect = Rect2( global_position - ( BOXWIDTH / 2.0 - 16 ) * Vector2( 1, 1 ), BOXWIDTH * Vector2( 1, 1 ) )
	$Viewport/particles.global_position = global_position

