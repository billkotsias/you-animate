package fanlib.tween {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class TList extends EventDispatcher {

		public static const TLIST_COMPLETE:String = "TLIST_COMPLETE";
		
		public var data:* = null; /// set carrying "data"
		
		internal var tweens:Array = [];
		
		public function TList() {
		}
		
		public function start():void { tweens[0].start(); };
		public function add(tween:ITween):ITween { tweens.push(tween); return tween; };
		public function get isEmpty():Boolean { return tweens.length == 0; }
		
		public function clear():void { tweens.length = 0; }
		
		public function run(time:Number):Boolean {
			if (isEmpty) return true;
			
			while (time > 0) {

				var tween:ITween = tweens[0];
				time = tween.run(time);
	
				if (time >= 0) {							/// tween finished
	
					tweens.shift();
					
					if (isEmpty) {											// playlist finished?
						dispatchEvent(new Event(TLIST_COMPLETE));
						if (isEmpty) return true;							// a new one may have been added during the above event
					}
					tweens[0].start();						/// "start" next tween
				}
			}
	
			return false;	/// playlist not finished
		}

	}
	
}
