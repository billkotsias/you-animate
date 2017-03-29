package fanlib.io {

	import fanlib.event.ObjEvent;
	import fanlib.utils.DelayedCall;
	import fanlib.utils.Pausable;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	public class BackLoader extends EventDispatcher {

		private var files:Array = new Array();
		private var currentLoading:uint = 0;
		private var lastLoadTime:Number = 0;
		private var nextLoadDelay:DelayedCall;
		
		public static const BACKLOADER_GROUP:String = "BackLoader";
		
		public var simultaneousFiles:uint = 2;
		public var minimumTimePerLoad:Number = 1.0 / 100; // default = 1 csec
		
		private const pauser:Pausable = new Pausable();
		
		public function BackLoader(f:Array = null) {
			super();
			if (f !== null) insertFiles(f);
		}

		public function insertFile(f:String):void {
			files.push(f);
			loadFiles();
		}
		
		public function insertFiles(f:Array):void {
			files = files.concat(f);
			loadFiles();
		}
		
		private function loadFiles():void {
			if (nextLoadDelay) nextLoadDelay.dismiss();
			
			var timeToNextLoad:Number = minimumTimePerLoad - (getTimer() - lastLoadTime) / 1000;
			if (timeToNextLoad <= 0) {
				loadFiles2();
			} else {
				nextLoadDelay = new DelayedCall(loadFiles2, timeToNextLoad);
			}
		}
		
		private function loadFiles2():void {
			if (checkFinished() || pauser.paused) return; // don't load
			
			var numToLoad:int = Math.min(simultaneousFiles - currentLoading, files.length);
			if (numToLoad <= 0) return; // can't load now
			
			var toLoad:Array = files.splice(0, numToLoad);
			currentLoading += numToLoad;
			lastLoadTime = getTimer();
			new MLoader(toLoad, loaded, undefined, BACKLOADER_GROUP);
		}
		
		private function loaded(l:MLoader):void {
			currentLoading -= l.files.length;
			dispatchEvent(new ObjEvent(l, Event.ADDED));
			loadFiles();
		}
		
		private function checkFinished():Boolean {
			if (files.length == 0) {
				dispatchEvent(new Event(Event.COMPLETE));
				return true;
			}
			return false;
		}
		
		public function unload():void {
			MLoader.UnloadGroup(BACKLOADER_GROUP);
		}
		
		public function get remaining():uint { return files.length; };
		
		public function pause(pausingObj:*):void {
			pauser.pause(pausingObj);
		}
		
		public function unpause(pausingObj:*):Boolean {
			if (pauser.unpause(pausingObj)) return true; // still paused
			if (files.length > 0) loadFiles();
			return false;
		}
	}
	
}
