package fanlib.tween {
	
	public class TCubic extends Tween {

		private var diff:ITweenedData;
		private var invDuration:Number;
		private var factor:Number;
		
		public function TCubic(_final:ITweenedData, _getf:Function, _setf:Function, _duration:Number, _factor:Number = 2.8, _delay:Number = 0) {
			super(_final,_getf,_setf,_duration,_delay);
			factor = _factor;
		}

		// cache optimization
		override public function start():void {
			super.start();
			diff = endValue.sub(startValue);
			invDuration = 1 / duration;
		}
		
		override protected function setCurrentValue(t:Number):void {
			t *= invDuration;
			setf( startValue.add( diff.mulN( t*t*t -factor*t*t +factor*t ) ) );
		}

	}
	
}
