shader_type canvas_item;


void fragment()
{
	vec2 px = TEXTURE_PIXEL_SIZE;
	
//	float a = texture( TEXTURE, UV ).a +
//		texture( TEXTURE, UV + vec2( px.x, 0.0 ) ).a +
//		texture( TEXTURE, UV - vec2( px.x, 0.0 ) ).a +
//		texture( TEXTURE, UV + vec2( 0.0, px.y ) ).a +
//		texture( TEXTURE, UV - vec2( 0.0, px.y ) ).a +
//		texture( TEXTURE, UV + vec2( px.x, px.y ) ).a +
//		texture( TEXTURE, UV - vec2( px.x, px.y ) ).a +
//		texture( TEXTURE, UV + vec2( px.x, -px.y ) ).a +
//		texture( TEXTURE, UV + vec2( -px.x, px.y ) ).a;
	
//	float a = texture( TEXTURE, UV ).a +
//		texture( TEXTURE, UV + vec2( px.x, 0.0 ) ).a +
//		texture( TEXTURE, UV - vec2( px.x, 0.0 ) ).a +
//		texture( TEXTURE, UV + vec2( 0.0, px.y ) ).a +
//		texture( TEXTURE, UV - vec2( 0.0, px.y ) ).a;
//	a /= 9.0;
	
	float a = texture( TEXTURE, UV ).a;
	
	
	vec4 c = vec4( 0.0 );
	/*
	if( a > 0.9999991 )
	{
		c = vec4( 1.0, 1.0, 1.0, 1.0 )
	}
	else */if( a > 0.99999 )
	{
		c = vec4( 1.0, 1.0, 0.5, 1.0 )
	}
	else if( a > 0.9 )
	{
		c = vec4( 1.0, 0.8, 0.0, 1.0 )
	}
	else if( a > 0.5 )
	{
		c = vec4( 1.0, 0.0, 0.0, 1.0 )
	}
	COLOR = c;
}