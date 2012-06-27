package {
	import com.anttikupila.events.StreamingEvent;
	import com.anttikupila.media.SoundFX;
	import com.anttikupila.media.filters.DelayFilter;
	import com.anttikupila.media.filters.FlangeFilter;
	import com.anttikupila.media.filters.LowpassFilter;
	
	import demo.Arrow;
	import demo.Knob;
	import demo.Overlay;
	import demo.Timeline;
	import demo.Visualization;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;		
	
	[SWF(backgroundColor=0x111111, frameRate=30, width=515, height=330)]	

	public class Main extends Sprite {
		
		//---------------------------------------------------------------------
		//
		//  Variables
		//
		//---------------------------------------------------------------------
		
		public static const WIDTH : int = 515;
		public static const HEIGHT : int = 330;
		public static const DEMO_TRACK : String = "music.mp3";

		private var visualization : Visualization;
		private var soundFx : SoundFX;

		private var knobs : Array;
		private var knob1 : Knob;
		private var knob2 : Knob;
		private var knob3 : Knob;
		private var knob4 : Knob;
		private var knob5 : Knob;
		
		private var lowpass : LowpassFilter;
		private var flanger : FlangeFilter;
		private var delay : DelayFilter;
		
		private var timeline : Timeline;
		private var overlay : Overlay;
		
		private var paused : Boolean;
		
		private var pauseTimer : Timer; // double click will also trigger the single click, let's put a delay on the pause

		
		//---------------------------------------------------------------------
		//
		//  Constructor
		//
		//---------------------------------------------------------------------
		
		function Main() {
			super( );
			
			initStage( );
			initVisualization( );

			soundFx = new SoundFX( );
			soundFx.addEventListener( StreamingEvent.BUFFER_EMPTY, bufferStartHandler );
			soundFx.addEventListener( StreamingEvent.BUFFER_FULL, bufferCompleteHandler );
			soundFx.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			soundFx.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			
			// Add some filters
			lowpass = new LowpassFilter( );
			flanger = new FlangeFilter( );
			delay = new DelayFilter( );
			
			// Similar to sprite.filters = [ new DropShadowFilter() ] etc
			soundFx.filters = [ delay, flanger, lowpass ];
			
			// Initialize some stuff for this demo
			initKnobs( );
			
			timeline = new Timeline( WIDTH );
			timeline.y = visualization.height;
			timeline.addEventListener( MouseEvent.CLICK, timelineClickHandler );
			addChild( timeline );
			
			overlay = new Overlay( WIDTH, HEIGHT );
			overlay.addEventListener( MouseEvent.CLICK, overlayClickHandler );
			overlay.buttonMode = true;
			addChild( overlay );
			
			pauseTimer = new Timer( 100 );
			pauseTimer.addEventListener( TimerEvent.TIMER, pauseTimerHandler );
		}

		protected function initStage() : void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
		}

		protected function initVisualization() : void {
			visualization = new Visualization( 515, 250 );
			visualization.addEventListener( MouseEvent.CLICK, visualizationClickHandler );
			visualization.addEventListener( MouseEvent.DOUBLE_CLICK, visualizationDoubleClickHandler );
			visualization.doubleClickEnabled = true;
			visualization.buttonMode = true;
			addChild( visualization );
		}

		protected function initKnobs() : void {
			knobs = [];
			
			knob1 = new Knob( "echo", 0, 1, 0, "", 7, 0.01 );
			knob1.addEventListener( Event.CHANGE, knobChangeHandler );
			knob1.x = 25;
			knob1.y = 280;
			knobs.push( knob1 );
			addChild( knob1 );
			
			var arrow : Arrow;
			
			arrow = addChild( new Arrow( ) ) as Arrow;
			arrow.x = 50;
			arrow.y = 280;
			
			knob2 = new Knob( "phase", 3, 100, 10, "ms", 7, 1 );
			knob2.addEventListener( Event.CHANGE, knobChangeHandler );
			knob2.x = 75;
			knob2.y = 280;
			knobs.push( knob2 );
			addChild( knob2 );
			
			arrow = addChild( new Arrow( ) ) as Arrow;
			arrow.x = 100;
			arrow.y = 280;
			
			knob3 = new Knob( "feedback", 0, 0.9, 0.25, "", 7, 0.01 );
			knob3.addEventListener( Event.CHANGE, knobChangeHandler );
			knob3.x = 125;
			knob3.y = 280;
			knobs.push( knob3 );
			addChild( knob3 );
			
			arrow = addChild( new Arrow( ) ) as Arrow;
			arrow.x = 150;
			arrow.y = 280;
			
			knob4 = new Knob( "cutoff", 100, 22050, 22050, "hz", 10, 1 );
			knob4.addEventListener( Event.CHANGE, knobChangeHandler );
			knob4.x = 175;
			knob4.y = 280;
			knobs.push( knob4 );
			addChild( knob4 );
			
			arrow = addChild( new Arrow( ) ) as Arrow;
			arrow.x = 200;
			arrow.y = 280;
			
			knob5 = new Knob( "resonance", 0.1, Math.SQRT2, Math.SQRT2, "", 7, 0.01 );
			knob5.addEventListener( Event.CHANGE, knobChangeHandler );
			knob5.x = 225;
			knob5.y = 280;
			knobs.push( knob5 );
			addChild( knob5 );
			
			knobChangeHandler( null );
		}

		
		//---------------------------------------------------------------------
		//
		//  Events
		//
		//---------------------------------------------------------------------
		
		protected function overlayClickHandler( event : MouseEvent ) : void {
			overlay.removeEventListener( MouseEvent.CLICK, overlayClickHandler );
			overlay.buttonMode = false;
			soundFx.load( new URLRequest( LoaderInfo(this.root.loaderInfo).parameters.track || DEMO_TRACK ) );
			soundFx.play( );
			soundFx.addEventListener( Event.SOUND_COMPLETE, soundCompleteHandler ); // Note: This is not added to the sound channel but to the sound itself
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		protected function bufferStartHandler( event : StreamingEvent ) : void {
			overlay.show( Overlay.BUFFER_ICON, "Buffering.." );
		}
		
		protected function soundCompleteHandler( event : Event ) : void {
			overlay.addEventListener( MouseEvent.CLICK, restartHandler );
			overlay.buttonMode = true;
			overlay.show( Overlay.REPEAT_ICON, "Sound finsished. Click to restart" );
		}
		
		protected function restartHandler( event : MouseEvent ) : void {
			overlay.removeEventListener( MouseEvent.CLICK, restartHandler );
			overlay.buttonMode = false;
			soundFx.play( 0 );
		}
		
		protected function ioErrorHandler( event : IOErrorEvent ) : void {
			overlay.show( Overlay.ERROR_ICON, "File '" + DEMO_TRACK + "' not found" );
			removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		protected function securityErrorHandler( event : SecurityErrorEvent ) : void {
			overlay.show( Overlay.ERROR_ICON, "Security error occurred" );
			removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		protected function visualizationClickHandler( event : MouseEvent ) : void {
			pauseTimer.start( );
		}
		
		private function pauseTimerHandler( event : TimerEvent ) : void {
			pauseTimer.stop( );
			soundFx.paused = !soundFx.paused;
		}

		protected function visualizationDoubleClickHandler( event : MouseEvent ) : void {
			pauseTimer.stop( );
			for each (var knob : Knob in knobs) {
				knob.animateToValue( Math.random( ) * ( knob.getMaxValue() - knob.getMinValue() ) + knob.getMinValue() );
			}
			knobChangeHandler( null );
			soundFx.paused = false;
		}

		protected function bufferCompleteHandler( event : StreamingEvent ) : void {
			overlay.hide( );
			visualization.enabled = true;
		}
		
		protected function enterFrameHandler( event : Event ) : void {
			timeline.update( soundFx.bytesLoaded / soundFx.bytesTotal, soundFx.position / soundFx.getLength() );
		}

		protected function knobChangeHandler( event : Event ) : void {
			delay.mix = delay.feedback = knob1.value;
			flanger.delay = knob2.value;
			flanger.feedback = knob3.value;
			lowpass.cutoffFrequency = knob4.value;
			lowpass.resonance = knob5.value;
		}
		
		protected function timelineClickHandler( event : MouseEvent ) : void {
			soundFx.position = timeline.getPosition( ) * soundFx.getLength( );
		}
	}
}