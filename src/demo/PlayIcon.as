package demo {	import flash.filters.GlowFilter;	
	import flash.display.Sprite;
	/**	 * @author Antti Kupila	 */	public class PlayIcon extends Sprite {
		public function PlayIcon( radius : Number = 20 ) {			with (graphics) {				beginFill( 0x000000 );				lineStyle( 2, 0xFFFFFF, 0.5, false );				drawCircle( 0, 0, radius );				beginFill( 0xFFFFFF );				lineStyle( 0 );				moveTo( -radius * 0.2, -radius * 0.25 );				lineTo( -radius * 0.2, radius * 0.25 );				lineTo( radius * 0.32, 0 );			}		}
	}}