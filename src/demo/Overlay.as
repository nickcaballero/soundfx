package demo {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class Overlay extends Sprite
	{
		public static const PLAY_ICON : String = "playIcon";
		public static const BUFFER_ICON : String = "bufferIcon";
		public static const REPEAT_ICON : String = "repeatIcon";
		public static const ERROR_ICON : String = "errorIcon";
		
		private var bg : Sprite;
		private var label : TextField;
		
		private var icons : Sprite;
		private var play : PlayIcon;
		private var buffer : BufferIcon;
		private var repeatIcon : ReplayIcon;
		private var errorIcon : ErrorIcon;
		
		private var targetAlpha : Number = 1;
		
		public function Overlay( width : Number, height : Number ) {
			super();
			
			bg = new Sprite( );
			bg.graphics.beginFill( 0x000000, 0.5 );
			bg.graphics.drawRect( 0, 0, width, height );
			bg.buttonMode = true;
			bg.mouseChildren = false;
			addChild( bg );
			
			label = new TextField( );
			label.defaultTextFormat = new TextFormat( "_sans", 9, 0xBBBBBB, false, false, false, null, null, "center" );
			label.gridFitType = GridFitType.PIXEL;
			label.selectable = false;
			label.width = 300;
			label.x = width * 0.5 - label.width * 0.5;
			label.y = height * 0.5 - label.textHeight * 0.5;
			label.antiAliasType = AntiAliasType.ADVANCED;
			
			play = new PlayIcon( );
			buffer = new BufferIcon( );
			repeatIcon = new ReplayIcon( );
			errorIcon = new ErrorIcon( );
			
			icons = new Sprite( );
			icons.x = width * 0.5;
			icons.y = height * 0.4;
			icons.filters = [ new GlowFilter( 0xFFFFFF, 1, 32, 32, 0.2 ), new DropShadowFilter( 0, 0, 0x000000, 1, 128, 128, 5 ) ];
			icons.addChild( play );
			icons.addChild( buffer );
			icons.addChild( repeatIcon );
			icons.addChild( errorIcon );
			
			addChild( icons );
			addChild( label );
			
			mouseChildren = false;
			
			show( PLAY_ICON );
		}
		
		private function enterFrameHandler( event : Event ) : void {
			alpha += ( targetAlpha - alpha ) * 0.25;
			visible = ( alpha > 0 );
			if ( Math.abs( targetAlpha - alpha ) < 0.01 ) {
				alpha = targetAlpha;
				removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
			}
		}
		
		public function show( icon : String, message : String = "" ) : void {
			play.visible = ( icon == PLAY_ICON );
			buffer.visible = ( icon == BUFFER_ICON );
			repeatIcon.visible = ( icon == REPEAT_ICON );
			errorIcon.visible = ( icon == ERROR_ICON );
			mouseEnabled = true;
			targetAlpha = 1;
			label.text = message;
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		public function hide ( ) : void {
			mouseEnabled = false;
			targetAlpha = 0;
			label.text = "";
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
	}
}