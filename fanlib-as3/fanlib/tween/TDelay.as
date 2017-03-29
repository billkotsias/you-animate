package fanlib.tween
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class TDelay extends EventDispatcher implements ITween
	{
		protected var delay:Number;
		
		public function TDelay(_delay:Number)
		{
			delay = _delay;
		}
		
		// run an amount of time - take delay into account
		// => time units to run
		// <= time units left over; < 0 means none; >= 0, this tween has finished
		public function run(time:Number):Number {
			delay -= time;
			if (delay > 0) {
				return -1; // not finished yet
			}
			
			// this is the end
			dispatchEvent(new Event(Tween.TWEEN_COMPLETE));
			return -delay; // finished; remaining time still available for next tween
		}
		
		public function start():void {}
	}
}