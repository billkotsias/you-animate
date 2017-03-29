package fanlib.ui.loading {
	
	import fanlib.io.MLoader;
	import flash.events.Event;
	import fanlib.gfx.StagedSprite;
	
	// Tracks 'MLoader' progress
	public class MLTracker extends StagedSprite {

		public var stopWhenComplete:Boolean = false;
		
		public function MLTracker(b:Boolean = true) {
			if (b) trackProgress();
		}
		
		public function trackProgress(dummy:* = undefined):void {
			MLoader.Events.addEventListener(MLoader.PROGRESS, progress);
			MLoader.Events.addEventListener(Event.COMPLETE, complete);
		}

		public function stopTracking(dummy:* = undefined):void {
			MLoader.Events.removeEventListener(MLoader.PROGRESS, progress);
			MLoader.Events.removeEventListener(Event.COMPLETE, complete);
		}
		
		// to be overriden
		public function progress(e:Event):void {
		}
		
		public function complete(e:Event):void {
			if (stopWhenComplete) stopTracking();
			dispatchEvent(e);
		}
	}
	
}
