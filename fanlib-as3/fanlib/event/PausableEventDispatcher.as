package fanlib.event
{
	import fanlib.utils.Pausable;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class PausableEventDispatcher extends EventDispatcher
	{
		protected const eventsPauser:Pausable = new Pausable();
		
		public function PausableEventDispatcher(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		override public function dispatchEvent(e:Event):Boolean {
			if (eventsPauser.paused) {
				trace(this, "event not dispatched:", e);
				return false;
			}
			return super.dispatchEvent(e);
		}
	}
}