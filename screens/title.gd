extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	call_deferred( "set_sprite_viewport_texture" )

func set_sprite_viewport_texture():
	$Sprite.texture = $Viewport.get_texture()