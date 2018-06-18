extends Node2D

const boxwidth = 128
var fire_shader = preload( "res://shaders/fire_particle.shader" )
var ice_shader = preload( "res://shaders/ice_particle.shader" )

func _ready():
	call_deferred( "set_sprite_viewport_texture" )
	
func set_sprite_viewport_texture():
	$fire_sprite.texture = $Viewport.get_texture()


func _physics_process(delta):
	$fire_sprite.region_rect = Rect2( global_position - boxwidth / 2.0 * Vector2( 1, 1 ), boxwidth * Vector2( 1, 1 ) )
	$Viewport/particles.global_position = global_position


var mat = null
func set_type( type ):
	mat = ShaderMaterial.new()
	if type == 0:
		mat.shader = fire_shader
	else:
		mat.shader = ice_shader
	$AnimationPlayer.stop()
	$AnimationPlayer.play( "start" )

func set_shader():
	$fire_sprite.material = mat
	pass