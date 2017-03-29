package fanlib.tween {
	
	public class TPow extends Tween {

		private var pow:Number;
		
		private var invDuration:Number;
		private var diff:ITweenedData;
		
		public function TPow(_final:ITweenedData, _getf:Function, _setf:Function, _pow:Number, _duration:Number, _delay:Number = 0) {
			super(_final,_getf,_setf,_duration,_delay);
			pow = _pow;
		}

		override public function start():void {
			super.start();
			invDuration = 1 / duration;
			diff = endValue.sub(startValue);
		}
		
		override protected function setCurrentValue(currentTime:Number):void {
			setf( startValue.add( diff.mulN( Math.pow(currentTime * invDuration, pow) ) ) );
		}

	}
	
}
