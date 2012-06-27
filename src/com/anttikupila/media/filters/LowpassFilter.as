/*
The MIT License

Copyright (c) <year> <copyright holders>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/*
 * Ported from http://www.musicdsp.org/archive.php?classid=3#38
 *
 * @author Antti Kupila
 */
package com.anttikupila.media.filters {
	import com.anttikupila.media.SoundFX;	

	public class LowpassFilter implements IFilter {

		//---------------------------------------------------------------------
		//
		//  Variables
		//
		//---------------------------------------------------------------------
		
		protected var f : Number = 0;
		protected var r : Number = Math.SQRT2;
		protected var fs : Number = SoundFX.SAMPLE_RATE;

		protected var a1 : Number;
		protected var a2 : Number;
		protected var a3 : Number;
		protected var b1 : Number;
		protected var b2 : Number;
		protected var c : Number;

		protected var in1 : Number;
		protected var in2 : Number;
		protected var out1 : Number;
		protected var out2 : Number;
		protected var output : Number;

		private var channelCopy : LowpassFilter;

		
		//---------------------------------------------------------------------
		//
		//  Constructor
		//
		//---------------------------------------------------------------------
		
		public function LowpassFilter( cutoffFrequency : Number = 8000, resonance : Number = Math.SQRT2 ) {
			f = cutoffFrequency;
			r = resonance;
			
			in1 = in2 = out1 = out2 = 0;
			
			calculateParameters( );
		}

		
		//---------------------------------------------------------------------
		//
		//  Protected methods
		//
		//---------------------------------------------------------------------
		
		protected function calculateParameters( ) : void {
			c = 1 / Math.tan( Math.PI * f / fs );
			a1 = 1.0 / ( 1.0 + r * c + c * c);
			a2 = 2 * a1;
			a3 = a1;
			b1 = 2.0 * ( 1.0 - c * c) * a1;
			b2 = ( 1.0 - r * c + c * c) * a1;
		}

		
		//---------------------------------------------------------------------
		//
		//  Public methods
		//
		//---------------------------------------------------------------------
		
		public function process( input : Number ) : Number {
			output = a1 * input + a2 * in1 + a3 * in2 - b1 * out1 - b2 * out2;
			
			in2 = in1;
			in1 = input;
			out2 = out1;
			out1 = output;
			
			return output;
		}

		public function duplicate() : IFilter {
			channelCopy = new LowpassFilter( cutoffFrequency, resonance );
			return channelCopy;
		}

		public function set cutoffFrequency( frequency : Number ) : void {
			f = frequency;
			if ( f >= SoundFX.SAMPLE_RATE * 0.5 ) f = SoundFX.SAMPLE_RATE * 0.5 - 1; 
			if ( channelCopy ) channelCopy.cutoffFrequency = f;
			calculateParameters( );
		}

		public function get cutoffFrequency( ) : Number {
			return f;
		}

		public function set resonance( resonance : Number ) : void {
			r = resonance;
			if ( channelCopy ) channelCopy.resonance = r;
			calculateParameters( );
		}

		public function get resonance( ) : Number {
			return r;
		}
	}
}