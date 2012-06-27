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

package com.anttikupila.media.filters {
	import com.anttikupila.media.SoundFX;

	public class MoogFilter implements IFilter {

		//---------------------------------------------------------------------
		//
		//  Variables
		//
		//---------------------------------------------------------------------
		
		private var cutoff : Number;
		private var res : Number;
		private var fs : Number = SoundFX.SAMPLE_RATE;

		private var x : Number;
		private var y1 : Number;
		private var y2 : Number;
		private var y3 : Number;
		private var y4 : Number;
		private var oldx : Number;
		private var oldy1 : Number;
		private var oldy2 : Number;
		private var oldy3 : Number;
		private var f : Number;
		private var p : Number;
		private var k : Number;
		private var t : Number;
		private var t2 : Number;
		private var r : Number;
		
		private var channelCopy : MoogFilter;

		
		//---------------------------------------------------------------------
		//
		//  Constructor
		//
		//---------------------------------------------------------------------
		
		public function MoogFilter( cutoffFrequency : Number = 8000, resonance : Number = Math.SQRT2 ) {
			cutoff = cutoffFrequency;
			res = resonance;
			
			init( );
		}


		//---------------------------------------------------------------------
		//
		//  Private methods
		//
		//---------------------------------------------------------------------
		
		private function init( ) : void {
			y1 = y2 = y3 = y4 = oldx = oldy1 = oldy2 = oldy3 = 0;
			calc( );
		}

		private function calc( ) : void {
			f = cutoff * 2 / fs; 
			p = f * ( 1.8 - 0.8 * f );
			k = p + p - 1;
			
			t = ( 1 - p ) * 1.386249;
			t2 = 12 + t * t;
			r = res * ( t2 + 6 * t ) / ( t2 - 6 * t );
		}

		
		//---------------------------------------------------------------------
		//
		//  Public methods
		//
		//---------------------------------------------------------------------
		
		public function process(input : Number ) : Number {
			// process input
			x = input - r * y4;
			
			//Four cascaded onepole filters (bilinear transform)
			y1 = x * p + oldx * p - k * y1;
			y2 = y1 * p + oldy1 * p - k * y2;
			y3 = y2 * p + oldy2 * p - k * y3;
			y4 = y3 * p + oldy3 * p - k * y4;
			
			//Clipper band limited sigmoid
			y4 -= ( y4 * y4 * y4 ) / 6;
			
			oldx = x; 
			oldy1 = y1; 
			oldy2 = y2; 
			oldy3 = y3;
			
			return y4;
		}
		
		public function duplicate() : IFilter {
			channelCopy = new MoogFilter( cutoffFrequency, resonance );
			return channelCopy;
		}

		public function set cutoffFrequency( frequency : Number ) : void {
			if ( frequency < 0 || frequency > SoundFX.SAMPLE_RATE * 0.5 ) throw new RangeError( "Cutoff frequency " + frequency + " is out of range, valid range is 0 - " + ( SoundFX.SAMPLE_RATE * 0.5 ) );
			cutoff = frequency;
			if ( channelCopy ) channelCopy.cutoffFrequency = cutoff;
			calc( );
		}

		public function get cutoffFrequency( ) : Number {
			return cutoff;
		}

		public function set resonance( resonance : Number ) : void {
			if ( resonance < 0.1 || resonance > Math.SQRT2 ) throw new RangeError( "Resonance is out of range, valid range is 0.1 - sqrt(2)" );
			res = resonance;
			if ( channelCopy ) channelCopy.resonance = res;
			calc( );
		}

		public function get resonance( ) : Number {
			return res;
		}
	}
}