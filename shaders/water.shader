shader_type canvas_item;

uniform float initialize = 0.0;
uniform float pos_x = 0.5;
uniform float pos_y = 0.5;

void fragment()
{
	// GET THE HEIGHT AND VELOCITY OF THIS FRAGMENT
	float h = texture( SCREEN_TEXTURE, SCREEN_UV ).r - 0.5;
	float v = texture( SCREEN_TEXTURE, SCREEN_UV ).g - 0.5;
	
	// COMPUTE NEW VELOCITY AND HEIGHT
	vec2 ps = SCREEN_PIXEL_SIZE;
	v -= 0.1 * h; // velocity of a point depends on the height of that point, to have a spring effect
	// velocity of a point also depends on the height of the points around it
	v += ( 
			( texture( SCREEN_TEXTURE, SCREEN_UV + vec2( 0, -ps.y ) ).r - 0.5 ) +
			( texture( SCREEN_TEXTURE, SCREEN_UV + vec2( 0, ps.y ) ).r - 0.5 ) +
			( texture( SCREEN_TEXTURE, SCREEN_UV + vec2( -ps.x, 0 ) ).r - 0.5 ) +
			( texture( SCREEN_TEXTURE, SCREEN_UV + vec2( ps.x, 0 ) ).r - 0.5 ) -
			4.0 * h ) * 0.2;
	v *= 0.98; // Dampen the velocity, otherwise it would oscillate forever
	h += v; // change the height with the new velocity - NOT FRAME RATE INDEPENDENT!
	
	// Generate drops
	if ( mod( TIME, 1.0 ) < .05 && initialize < 0.5 )
	{
		vec2 drop_pos = vec2( pos_x, pos_y );//vec2( 0.5 + 0.5 * sin( floor( TIME * 5.0 ) * 20.0 ), 0.5 );
		if( length( UV - drop_pos ) < 0.01 )
		{
			h = -0.5;
		}
	}
	
	// INITIALIZATION
	if( initialize > 0.5 )
	{
		h *= 0.0;
		v *= 0.0;
	}
	
	// SET FRAGMENT COLOR BASED ON HEIGHT (RED) AND VELOCITY (GREEN)
	COLOR = vec4( h + 0.5, v + 0.5, 0.0, 1.0 );
}