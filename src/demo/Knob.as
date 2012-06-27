package demo {
	import flash.ui.Keyboard;	
	import flash.events.KeyboardEvent;	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;		

	public class Knob extends Sprite {

		public static const MIN_ROTATION : int = -160;
		public static const MAX_ROTATION : int = 130;
		public static const EASING : int = 3;
		public static const RADIUS : int = 10;
		public static const RESPONSIVNESS : Number = 4;

		private var dial : Shape;
		private var labelField : TextField;
		private var valueField : TextField;

		private var clickPoint : Point;
		private var clickRotation : Number;
		private var targetRotation : Number = 0;

		private var minValue : Number;
		private var maxValue : Number;
		private var unit : String;
		private var outputPreprocessor : Function;
		private var outputProcessorParams : Array;

		private var precision : Number;
		private var defaultValue : Number;

		private var _currentValue : Number;

		private var shift : Boolean;
		private var control : Boolean;

		public function Knob( label : String, minValue : Number = 0, maxValue : Number = 100, defaultValue : Number = 0, unit : String = "", ticks : int = 6, precision : Number = 1, outputPreprocessor : Function = null, ...outputProcessorParams ) {
			super( );
			
			this.minValue = minValue;
			this.maxValue = maxValue;
			this.unit = unit;
			this.defaultValue = Math.min( Math.max( defaultValue, minValue ), maxValue );
			this.outputPreprocessor = outputPreprocessor;
			this.outputProcessorParams = outputProcessorParams;
			
			// hitzone
			graphics.lineStyle( 1, 0x000000, 0.1 );
			graphics.beginFill( 0x000000, 0.15 );
			graphics.drawCircle( 0, 0, RADIUS * 1.5 );
			
			drawTick( MIN_ROTATION, 0x444444 );
			var tickSize : Number = ( MAX_ROTATION - MIN_ROTATION ) / ( ticks + 1 );
			for ( var i : int = 1; i <= ticks ; i++ ) {
				drawTick( MIN_ROTATION + i * tickSize, 0x262626 );
			}
			drawTick( MAX_ROTATION, 0x444444 );	
			
			this.precision = precision;
			
			dial = new Shape( );
			dial.graphics.lineStyle( 2, 0x333333 );
			dial.graphics.beginFill( 0x222222 );
			dial.graphics.drawCircle( 0, 0, RADIUS );
			dial.graphics.lineStyle( 1, 0xDDDDDD );
			dial.graphics.moveTo( 0, 0 );
			dial.graphics.lineTo( 0, -11 );
			addChild( dial );
			
			labelField = new TextField( );
			labelField.defaultTextFormat = new TextFormat( "_sans", 9, 0xBBBBBB );
			labelField.selectable = false;
			labelField.text = label;
			labelField.autoSize = TextFieldAutoSize.LEFT;
			labelField.antiAliasType = AntiAliasType.ADVANCED;
			labelField.x = -labelField.textWidth * 0.5 - 2;
			labelField.y = 15;
			labelField.mouseEnabled = false;
			addChild( labelField );
			
			valueField = new TextField( );
			valueField.defaultTextFormat = new TextFormat( "_sans", 8, 0x444444, null, null, null, null, null, "center" );
			valueField.selectable = false;
			valueField.antiAliasType = AntiAliasType.ADVANCED;
			valueField.x = -50;
			valueField.width = 100;
			valueField.y = 23;
			valueField.mouseEnabled = false;
			addChild( valueField );
			
			doubleClickEnabled = true;
			
			value = defaultValue;
			
			addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			addEventListener( MouseEvent.DOUBLE_CLICK, resetHandler );
			addEventListener( Event.ADDED_TO_STAGE, stageInHandler );
			addEventListener( Event.REMOVED_FROM_STAGE, stageOutHandler );
			
//			filters = [ new DropShadowFilter( 1, 90, 0xFFFFFF, 1, 16, 16, 0.1 ) ];
		}

		private function drawTick( angle : Number, color : uint ) : void {
			graphics.moveTo( 0, 0 );
			graphics.lineStyle( 1, color );
			var deg : Number = ( angle - 90 ) / 180 * Math.PI;
			graphics.lineTo( Math.cos( deg ) * RADIUS * 1.3, Math.sin( deg ) * RADIUS * 1.3 );
		}

		private function calcRotation( value : Number ) : Number {
			return ( value - minValue ) / ( maxValue - minValue ) * ( MAX_ROTATION - MIN_ROTATION ) + MIN_ROTATION;
		}

		private function mouseDownHandler( event : MouseEvent ) : void {
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, changeHandler );
			clickPoint = new Point( mouseX, mouseY );
			clickRotation = dial.rotation;
		}

		private function resetHandler( event : MouseEvent ) : void {
			var v : Number = defaultValue;
			if ( shift && control ){
				v = ( maxValue - minValue ) * 0.5 + minValue;
			} else if ( shift ) {
				v = maxValue;
			} else if (control) {
				v = minValue;
			}
			animateToValue( v );
		}

		private function stageInHandler( event : Event ) : void {
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );
		}

		private function stageOutHandler( event : Event ) : void {
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stage.removeEventListener( KeyboardEvent.KEY_UP, keyDownHandler );
		}

		private function keyDownHandler( event : KeyboardEvent ) : void {
			if ( event.keyCode == Keyboard.SHIFT ) shift = true;
			if ( event.keyCode == Keyboard.CONTROL ) control = true;
		}

		private function keyUpHandler( event : KeyboardEvent ) : void {
			if ( event.keyCode == Keyboard.SHIFT ) shift = false;
			if ( event.keyCode == Keyboard.CONTROL ) control = false;
		}

		private function mouseUpHandler( event : MouseEvent ) : void {
			stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, changeHandler );
		}

		private function changeHandler( event : MouseEvent ) : void {
			var d : Number = clickPoint.y - mouseY;
			targetRotation = Math.min( Math.max( clickRotation + d * RESPONSIVNESS, MIN_ROTATION ), MAX_ROTATION );
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}

		private function enterFrameHandler( event : Event ) : void {
			dial.rotation += ( targetRotation - dial.rotation ) / EASING;
			_currentValue = ( dial.rotation - MIN_ROTATION ) / ( MAX_ROTATION - MIN_ROTATION ) * ( maxValue - minValue ) + minValue;
			if ( outputPreprocessor != null ) _currentValue = outputPreprocessor.apply( _currentValue, outputProcessorParams );
			updateValueField( );
			
			dispatchEvent( new Event( Event.CHANGE ) );
			
			if (Math.abs( targetRotation - dial.rotation ) < 0.01) removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}

		private function updateValueField( ) : void {
			var v : Number = Number( Math.round( _currentValue / precision ) * precision );
			v = Math.round( v * 100 ) / 100;
			valueField.text = v.toString( ) + unit;
		}
		
		public function animateToValue( value : Number ) : void {
			targetRotation = calcRotation( value );
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}

		public function get value() : Number {
			return _currentValue;
		}

		public function set value(value : Number) : void {
			_currentValue = value;
			dial.rotation = targetRotation = calcRotation( value );
			updateValueField( );
		}
		
		public function getMinValue() : Number {
			return minValue;
		}
		
		public function getMaxValue() : Number {
			return maxValue;
		}
	}
}