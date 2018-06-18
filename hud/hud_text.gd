extends Label

signal text_finished

var target_obj = null
var offset_pos = Vector2( 0, -32 )

func _ready():
	set_process_input( false )
	set_physics_process( false )




func set_char_text( obj, msg, duration = 2, wait_for_input = true, offset = Vector2( 0, -32 ) ):
	text = msg
	target_obj = weakref( obj )
	offset_pos = offset
	_set_textpos()
	
	# set timer
	$text_timer.wait_time = duration
	$text_timer.start()
	
	# player input
	set_physics_process( true )
	if wait_for_input:
		$user_input_timer.start()

func _on_user_input_timer_timeout():
	# start taking user input
	set_process_input( true )
	


func _input(event):
	if event is InputEventJoypadButton or event is InputEventMouseButton:
		set_process_input( false )
		set_physics_process( false )
		$text_timer.stop()
		text = ""
		emit_signal( "text_finished" )

func _set_textpos():
	if target_obj.get_ref() == null:
		return false
	var textsize = text.length() * 4
	var textpos = target_obj.get_ref().get_global_transform_with_canvas().origin - \
			get_size() / 2 + offset_pos
	textpos = textpos.round()
	#print( "Text position: ", textpos )
	if textpos.x + get_size().x / 2 + textsize / 2 > get_viewport_rect().size.x:
		textpos.x -= textsize / 2
	elif textpos.x + get_size().x / 2 - textsize / 2 < 2:
		textpos.x =  2 - get_size().x / 2 + textsize / 2
	if textpos.y < 5:
		textpos.y = 5
	self.rect_position = textpos
	return true

func _physics_process(delta):
	if not _set_textpos():
		$text_timer.stop()
		_on_text_timer_timeout()


func _on_text_timer_timeout():
	set_process_input( false )
	set_physics_process( false )
	text = ""
	emit_signal( "text_finished" )
	



