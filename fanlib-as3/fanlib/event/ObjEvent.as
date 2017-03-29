package fanlib.event {
	
	import flash.events.Event
	
	public class ObjEvent extends Event {

		private var obj:*;
		
		public function ObjEvent(o:*, type:String, bubbles:Boolean = false, cancelable:Boolean = false):void {
			super(type, bubbles, cancelable);
			obj = o;
		}
		
		public function getObj():* { return obj; };
		
		public override function clone():Event {
			return new ObjEvent(obj, type, bubbles, cancelable);
		}
	}
}