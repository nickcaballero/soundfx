package demo {
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;

	/**
	 * @author Antti Kupila
	 */
	public class ErrorIcon extends Sprite {

		public function ErrorIcon( radius : Number = 20 ) {
			var s : Number = 0.25;
			with (graphics) {
				beginFill( 0x000000 );
				lineStyle( 2, 0xFFFFFF, 0.5, false );
				drawCircle( 0, 0, radius );
				beginFill( 0xFFFFFF );
				lineStyle( 0 );
				lineStyle( 4, 0xEE0000, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE );
				moveTo( -radius * s, -radius * s );
				lineTo( radius * s, radius * s );
				moveTo( radius * s, -radius * s );
				lineTo( -radius * s, radius * s );
			}
		}
	}
}