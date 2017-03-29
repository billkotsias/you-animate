package fanlib.tween {
	
	import fanlib.tween.ITweenedData;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Tween extends EventDispatcher implements ITween {

		public static const TWEEN_COMPLETE:String = "TWEEN_COMPLETE";
		
		protected var startValue:ITweenedData;
		protected var endValue:ITweenedData;
		
		internal var getf:Function;
		internal var setf:Function;
		protected var delay:Number;
		protected var duration:Number;
		
		protected var currentTime:Number;
		
		// =>	_final = final tweened value
		//		_getf = object function to get tweened value
		//		_setf = object function to set tweened value
		//		_duration = tween duration
		//		_delay = intial delay till tween starts
		public function Tween(_final:ITweenedData, _getf:Function, _setf:Function, _duration:Number, _delay:Number = 0) {
			endValue = _final.copy();
			getf = _getf;
			setf = _setf;
			duration = _duration;
			delay = _delay;
		}
		
		// run an amount of time - take delay into account
		// => time units to run
		// <= time units left over; < 0 means none; >= 0, this tween has finished
		final public function run(time:Number):Number {
			if (delay > 0) {
				delay -= time;
				if (delay >= 0) {
					return -1;
				} else {
					time = -delay;
				}
			}
			
			currentTime += time;
			if (currentTime >= duration) {
				// this is the end
				setf(endValue); // set final value
				dispatchEvent(new Event(TWEEN_COMPLETE));
				// die
				startValue = null;
				endValue = null;
				getf = null;
				setf = null;
				// return
				return currentTime - duration;
			}
			setCurrentValue(currentTime);
			return -1;
		}
		
		// override this for initialization
		public function start():void {
			startValue = getf();
			currentTime = 0;
		}

		// override this to tween
		protected function setCurrentValue(currentTime:Number):void {
		}
	}
	
}
