package demo {
	import flash.filters.GlowFilter;	
	import flash.display.Sprite;

	/**
	 * @author Antti Kupila
	 */
	public class BufferIcon extends Sprite {

		public function BufferIcon( radius : Number = 20 ) {
			with (graphics) {
				beginFill( 0x000000 );
				lineStyle( 2, 0xFFFFFF, 0.5, false );
				drawCircle( 0, 0, radius );
				beginFill( 0xFFFFFF );
				lineStyle( 0 );
				moveTo( -radius * 0.15, -radius * 0.3 );
				lineTo( -radius * 0.15, 0 );
				lineTo( -radius * 0.35, 0 );
				lineTo( 0, radius * 0.4 );
				lineTo( radius * 0.35, 0 );
				lineTo( radius * 0.15, 0 );
				lineTo( radius * 0.15, -radius * 0.3 );
			}
		}
	}
}