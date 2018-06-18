extends Area2D

export var altarname = "second"

func _on_body_entered(body):
	if not game.add_event( altarname ):
		return
	if not game.is_event( "ice" ):
		game.play_sfx( game.ALTAR )
		game.player.set_cutscene()
		game.main.set_character_text( $Position2D, "Welcome Theo! ", 2, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "My brother sent word of your coming.", 3, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "I'll inscribe my part of the scrolls in your shield.", 3, false, true )
		yield( game.main, "text_finished" )
		# TODO: GIVE SHIELD
		var explosion_scn = preload( "res://enemies/ice_explosion.tscn" ).instance()
		explosion_scn.global_position = game.player.global_position
		get_parent().get_parent().add_child( explosion_scn )
		game.main.set_character_text( $Position2D, "", 3, false, false )
		game.player.TYPE = 1 # invert shield type
		game.gamestate.type = 1
		#game.player.get_node( "shield_fire" ).set_type( game.player.TYPE )
		game.add_event( "ice" )
		game.add_event( "dash" )
		game.player.has_ice = true
		game.player.has_dash = true
		game.player.set_shield()
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "This shield can deflect ice projectiles!", 3, false, false )
		yield( game.main, "text_finished" )
		game.main.set_character_text( game.player, "An ice shield! How do I switch between fire and ice?", 3, false, true )
		yield( game.main, "text_finished" )
		if game.control_type == game.MOUSE:
			game.main.set_character_text( $Position2D, "Just... Press the space key", 3, false, false )
		else:
			game.main.set_character_text( $Position2D, "Just... Press the any of the A/X/B/Y keys", 3, false, false )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "The shield also gives you the ability to dash or ram into demons", 3, false, false )
		yield( game.main, "text_finished" )
		game.main.set_character_text( game.player, "Finally... Some sort of attack weapon!", 3, false, true )
		yield( game.main, "text_finished" )
		if game.control_type == game.MOUSE:
			game.main.set_character_text( $Position2D, "Use the left mouse button to dash but beware...", 3, false, false )
		else:
			game.main.set_character_text( $Position2D, "Use the L or ZL buttons to dash but beware...", 3, false, false )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "... You must have the right type of shield...", 3, false, false )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "... And dashing costs you energy.", 3, false, false )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "Go! And good luck!", 3, false, true )
		game.player.clear_cutscene()
	elif game.add_event( "complete altar" ):
		game.play_sfx( game.ALTAR )
		game.player.set_cutscene()
		game.main.set_character_text( $Position2D, "Welcome Theo! ", 2, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "My brother sent word of your coming.", 3, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "I'll inscribe my part of the scrolls in your shield.", 3, false, true )
		yield( game.main, "text_finished" )
		var explosion_scn = preload( "res://enemies/ice_explosion.tscn" ).instance()
		explosion_scn.global_position = game.player.global_position
		get_parent().get_parent().add_child( explosion_scn )
		game.main.set_character_text( $Position2D, "", 3, false, false )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "Now go to the first altar.", 3, false, false )
		yield( game.main, "text_finished" )
		game.main.set_character_text( game.player, "Wait... No reward of some sort?!?", 3, false, true )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "We are all out now.", 3, false, false )
		yield( game.main, "text_finished" )
		game.main.set_character_text( $Position2D, "Go! And good luck!", 3, false, true )
		game.player.clear_cutscene()
		









