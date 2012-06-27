package demo {	import flash.display.LineScaleMode;	
	import flash.display.Shape;
	/**	 * @author Antti Kupila	 */	public class Arrow extends Shape {
		public function Arrow() {			super( );						with ( graphics ) {				lineStyle( 1, 0x444444, 1, true );				moveTo( -4, 0 );				lineTo( 4, 0 );				lineTo( 1, -2 );				moveTo( 4, 0 );				lineTo( 1, 2 );			}		}
	}}