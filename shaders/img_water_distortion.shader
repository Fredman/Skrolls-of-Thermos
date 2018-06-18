shader_type canvas_item;

uniform sampler2D image;

void fragment()
{
	vec2 ps = TEXTURE_PIXEL_SIZE;
	//COLOR = vec4( vec3( texture( TEXTURE, UV ).z ), 1.0 );
	//return;
	
	// Stupid displacement
	float dx = texture( TEXTURE, UV + vec2( ps.x, 0.0 ) ).x 
			-texture( TEXTURE, UV + vec2( -ps.x, 0.0 ) ).x;
	float dy = texture( TEXTURE, UV + vec2( 0.0, ps.y ) ).x 
			-texture( TEXTURE, UV+vec2(0.0,-ps.y)).x;
	float sc = 4.0;

	COLOR = vec4( texture( image, ( vec2( sin( sc * dx ), 
			cos( sc * dx ) * cos( sc * dy ) ) ) ).rgba );
	vec4 o = texture( image, UV + vec2( dx, dy ) ).rgba;
	COLOR = mix( COLOR, o, 0.3 );
//	COLOR = texture( TEXTURE, UV ).rgba;
}