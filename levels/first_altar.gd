extends Area2D




func _on_give_player_shield_body_entered(body):

	if not game.is_event( "shield" ):
		game.play_sfx( game.ALTAR )
		game.player.set_cutscene()
		game.main.set_character_text( $Position2D, "Welcome Theo! ", 2, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "I summon you here to assign you a task...", 3, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "Travel to the other 2 alters and bring me...", 3, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "the Scrolls of Thermos", 3, false, true )
		# something dramatic here
		yield( game.main, "text_finished" )
		game.main.set_character_text( game.player, "I have no weapons...", 3, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "Take my most powerfull weapon!", 3, false, true )
		# TODO: GIVE SHIELD
		var explosion_scn = preload( "res://enemies/explosion.tscn" ).instance()
		explosion_scn.global_position = game.player.global_position
		get_parent().get_parent().add_child( explosion_scn )
		game.main.set_character_text( $Position2D, "", 3, false, false )
		game.add_event( "shield" )
		game.player.set_shield()
		yield( game.main, "text_finished" )
		game.main.set_character_text( game.player, "A shield???", 2, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "Its my most powerfull weapon!!!", 3, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( game.player, "Seriouslly. Don't you have a sword?", 2, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "It can deflect fire projectiles!!!!!!", 3, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "But not ice projectiles!!!!!!", 3, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( game.player, "A knife?", 2, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( game.player, "A pocket knife?", 2, false, true )
		yield( game.main, "text_finished" )
		if game.control_type == game.MOUSE:
			game.main.set_character_text( $Position2D, "Use the right mouse button to defend.", 3, false, false )
		else:
			game.main.set_character_text( $Position2D, "Use the R or ZR buttons to defend.", 3, false, false )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "Go! And good luck!", 3, false, true )
		game.player.clear_cutscene()
	elif game.is_event( "complete altar" ):
		game.player.set_cutscene()
		game.main.set_character_text( $Position2D, "Well done! You've finished the game!", 3, false, false )
		yield( game.main, "text_finished" )
		game.gamestate.level = "res://screens/end_screen.tscn"
		game.main._load_scene()
		pass

