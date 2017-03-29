package fanlib.utils {
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class DelayedCall {

		private var data:*;
		private var callback:Function;
		private var timer:Timer;
		
		private var DONT_GC:Dictionary = new Dictionary();
		
		public function DelayedCall(callb:Function = null, seconds:Number = 0, dat:* = undefined, count:int = 1) {
			if (callb == null) return; // dummy
			
			callback = callb;
			data = dat;
			
			timer = new Timer(seconds * 1000, count);
			timer.addEventListener(TimerEvent.TIMER, timeEvent);
			timer.start();
			
			DONT_GC[this] = this;
		}
		
		public function pause():void {
			if (timer) timer.stop();
		}
		
		public function resume():void {
			if (timer) timer.start();
		}
		
		public function dismiss():void {
			if (timer) timer.stop();
			complete();
		}
		
		private function timeEvent(e:TimerEvent):void {
			if (data) callback(data); else callback();
			if (timer && timer.currentCount === timer.repeatCount) complete();
		}
		
		private function complete():void {
			timer = null;
			callback = null;
			data = undefined;
			delete DONT_GC[this];
		}
	}
}
