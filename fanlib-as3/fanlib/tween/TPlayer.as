package fanlib.tween {
	
	import fanlib.containers.List;
	import fanlib.event.StgEvent;
	import fanlib.gfx.Stg;
	import fanlib.utils.FArray;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class TPlayer {

		public static var DEFAULT:TPlayer = new TPlayer(); // a "standard" tweener for everyone to use, but must be started by the document class
		
		private var lists:List = new List();
		private var timeToRun:Number;
		
		public function TPlayer() {
		}
		
		public function start():void {
			Stg.addEventListener(Event.ENTER_FRAME, run);
		}
		
		public function stop():void {
			Stg.removeEventListener(Event.ENTER_FRAME, run);
		}
		
		public function addPlaylist(list:TList, runImmediately:Boolean = false):void {
			if (lists.push(list, runImmediately)) list.start();
		}
		
		public function addTween(tween:ITween, runNow:Boolean = false):TList {
			var list:TList = new TList();
			list.add(tween);
			addPlaylist(list, runNow);
			return list;
		}
		
		public function removePlaylist(list:TList, reachTarget:Boolean):void {
			if (lists.remove(list) && reachTarget) list.run(Infinity); // reach end
		}
		
		public function run(e:StgEvent):void {
			timeToRun = e.timeSinceLast / 1000; // msecs -> secs
			lists.forEach(runList);
		}
		private function runList(list:TList):void {
			if (list.run(timeToRun)) {
				removePlaylist(list, false);
			}
		}

	}
	
}
