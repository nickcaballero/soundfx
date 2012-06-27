package com.anttikupila.events {	import flash.events.Event;
	
	/**	 * @author Antti Kupila	 */	public class StreamingEvent extends Event {				public static const BUFFER_EMPTY : String = "bufferEmpty"; 		public static const BUFFER_FULL : String = "bufferFull"; 		
		public function StreamingEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {			super( type, bubbles, cancelable );		}
	}}