package demo {
	import flash.filters.GlowFilter;	
	import flash.display.Sprite;

	/**
	 * @author Antti Kupila
	 */
	public class ReplayIcon extends Sprite {

		public function ReplayIcon( radius : Number = 20 ) {
			with (graphics) {
				beginFill( 0x000000 );
				lineStyle( 2, 0xFFFFFF, 0.5, false );
				drawCircle( 0, 0, radius );
				beginFill( 0xFFFFFF );
				lineStyle( 0 );
				moveTo( -radius * 0.3, 0 );
				lineTo( 0, -radius * 0.25 );
				lineTo( 0, radius * 0.25 );
				lineTo( -radius * 0.3, 0 );
				moveTo( 0, 0 );
				lineTo( radius * 0.3, -radius * 0.25 );
				lineTo( radius * 0.3, radius * 0.25 );
				lineTo( 0, 0 );
			}
		}
	}
}