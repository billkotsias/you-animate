package fanlib.tween {
	
	public class TCos extends Tween {

		private var step:ITweenedData;
		private var invDuration:Number;
		
		public function TCos(_final:ITweenedData, _getf:Function, _setf:Function, _duration:Number, _delay:Number = 0) {
			super(_final,_getf,_setf,_duration,_delay);
		}

		// cache optimization
		override public function start():void {
			super.start();
			step = endValue.sub(startValue);
			invDuration = Math.PI / 2. / duration;
		}
		
		// linear tween
		override protected function setCurrentValue(currentTime:Number):void {
			setf( startValue.add( step.mulN( 1 - Math.cos(currentTime * invDuration) ) ) );
		}

	}
	
}
