package fanlib.event
{
	import flash.events.Event;

	public class StgEvent extends Event
	{
		public var time:uint;
		public var timeSinceLast:uint;
		
		public function StgEvent(time:uint, timeSinceLast:uint, type:String, bubbles:Boolean = false, cancelable:Boolean = false):void {
			super(type, bubbles, cancelable);
			this.time = time;
			this.timeSinceLast = timeSinceLast;
		}
		
		public override function clone():Event {
			return new StgEvent(time, timeSinceLast, type, bubbles, cancelable);
		}
	}
}