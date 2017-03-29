package fanlib.gfx {

	/* REDUNDANT */
	
	import flash.utils.getTimer;
	import flash.events.EventDispatcher;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import fanlib.event.ObjEvent;
	import flash.display.Stage;
	
	// direct linear fader - no generic tweens
	public class Fader extends EventDispatcher {

		private var zeroTime:int;
		private var startTime:int;
		private var duration:int;
		private var startAlpha:Number;
		private var endAlpha:Number;
		private var obj:DisplayObject;
		
		static public var STAGE:Stage;
		
		// constructor
		// => DisplayObject (MUST be in stage)
		//	  startTime (msecs)
		//	  duration (msecs)
		//	  endAlpha [0...1]
		public function Fader(obj:DisplayObject, startTime:uint, duration:uint, endAlpha:Number) {
			zeroTime = getTimer();
			this.startTime = startTime;
			this.duration = duration;
			startAlpha = obj.alpha;
			this.endAlpha = endAlpha;
			this.obj = obj;
			STAGE.addEventListener(Event.ENTER_FRAME, fade);
		}

		public function fade(e:Event):void {
			var timePos:int = (getTimer() - zeroTime) - startTime;
			if (timePos < 0) {
				return;
			} else if (timePos >= duration) {
				obj.alpha = endAlpha;
				STAGE.removeEventListener(Event.ENTER_FRAME, fade);
				dispatchEvent(new ObjEvent(this, Event.COMPLETE)); // LAST!!!
			} else {
				obj.alpha = startAlpha + (endAlpha - startAlpha) * timePos / duration;
			}
		}
		
		public function getObj():DisplayObject {
			return obj;
		}
	}
	
}
