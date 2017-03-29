package fanlib.tween {
	
	// http://timotheegroleau.com/Flash/experiments/easing_function_generator.htm
	public class TPoly extends Tween {

		private var diff:ITweenedData;
		private var invDuration:Number;
		private var factors:Array = [0.3975, -1.5275, 2.095, -2.065, 2.1];
		
		public function TPoly(_final:ITweenedData, _getf:Function, _setf:Function, _duration:Number, _factors:Array = null, _delay:Number = 0) {
			super(_final,_getf,_setf,_duration,_delay);
			if (_factors) factors = _factors;
		}

		// cache optimization
		override public function start():void {
			super.start();
			diff = endValue.sub(startValue);
			invDuration = 1 / duration;
		}
		
		override protected function setCurrentValue(t:Number):void {
			t *= invDuration;
			setf( startValue.add( diff.mulN(factors[0]*t*t*t*t*t +
											factors[1]*t*t*t*t +
											factors[2]*t*t*t +
											factors[3]*t*t +
											factors[4]*t ) ) );
		}

	}
	
}
