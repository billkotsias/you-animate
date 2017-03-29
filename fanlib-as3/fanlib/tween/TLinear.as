package fanlib.tween {
	
	public class TLinear extends Tween {

		private var step:ITweenedData;
		
		public function TLinear(_final:ITweenedData, _getf:Function, _setf:Function, _duration:Number, _delay:Number = 0) {
			super(_final,_getf,_setf,_duration,_delay);
		}

		// cache optimization
		override public function start():void {
			super.start();
			step = endValue.sub(startValue).divN(duration);
		}
		
		// linear tween
		override protected function setCurrentValue(currentTime:Number):void {
			setf( startValue.add( step.mulN( currentTime ) ) );
		}
	}
	
}
