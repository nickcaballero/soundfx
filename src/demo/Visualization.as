package demo {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;		

	public class Visualization extends Sprite {
		
		private var line : Shape;
		private var _enabled:Boolean;
		private var _width:int;
		private var _height:int;
		
		public function Visualization(width:int, height:int) {
			super();
			
			line = new Shape( );
			addChild( line );
			
			graphics.beginFill( 0x000000 );
			graphics.drawRect( 0, 0, width, height );
			graphics.lineStyle( 1, 0x222222 );
			graphics.moveTo( 0, height + 1 );
			graphics.lineTo( width, height + 1 );
			
			_width = width;
			_height = height;
		}
		
		private function enterFrameHandler(event:Event):void {
			var ba : ByteArray = new ByteArray( );
			SoundMixer.computeSpectrum( ba, false );
			var off : Number = 0;
			var i : int = 0;
			with ( line.graphics ) {
				clear( );
				moveTo( 0, _height >> 1 );
				lineStyle( 1, 0xEEEEFF, 0.6 );
				for ( i = 0; i < 512; i++ ) {
					if ( i >= 0xFF && off == 0 ) {
						off = _width;
						lineTo( _width, _height >> 1 );
						lineStyle( 3, 0xEEEEFF, 0.2 );
						moveTo( 0, 0 );
					}
					lineTo( i / 256 * _width - off, -ba.readFloat() * 125 + (_height >> 1) );
				}
			}
		}
		
		public function set enabled(enabled:Boolean):void {
			_enabled = enabled;
			if (_enabled) {
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			} else {
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
	}
}