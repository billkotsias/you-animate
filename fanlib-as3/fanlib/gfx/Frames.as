package fanlib.gfx
{
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TVector1;
	
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class Frames extends TSprite
	{
		private var timings:Array;
		private var playhead:int = 0;
		private var _currentTime:Number = 0;
		private var tlist:TList;
		private var currentFrame:String;
		
		public var timeScale:Number = 1; // set before durations!!!
		public var frames:Array;
		public var loop:Boolean = true;
		
		public function Frames()
		{
			super();
		}
		
		public function play(fromStart:Boolean):void {
			stop();
			var final:Number = timings[timings.length-1];
			if (fromStart || currentTime == final) currentTime = 0; // loop if at end
			tlist = TPlayer.DEFAULT.addTween(new TLinear(new TVector1(final), getCurrentTime, setCurrentTime, final - currentTime));
			tlist.addEventListener(TList.TLIST_COMPLETE, playComplete, false, 0, true);
		}
		private function playComplete(e:Event):void {
			stop();
			if (loop) play(true);
		}
		
		public function stop():void {
			if (tlist) {
				tlist.removeEventListener(TList.TLIST_COMPLETE, playComplete);
				TPlayer.DEFAULT.removePlaylist(tlist, false);
				tlist = null;
			}
		}
		
		// => durations in msecs
		public function set durations(d:Array):void {
			timings = [];
			timings[0] = timeScale * d[0] / 1000;
			for (var i:int = 1; i < d.length; ++i) {
				timings[i] = timings[i-1] + timeScale * d[i] / 1000;
			}
		}
		
		public function set frame(f:String):void {
			if (currentFrame == f) return; // optimize
			currentFrame = f;
			var obj:DisplayObject;
			
			for (var i:int = numChildren - 1; i >= 0; --i) {
				getChildAt(i).visible = false;
			}
			
			obj = getChildByName(f);
			if (obj) obj.visible = true;
		}

		public function get currentTime():Number { return _currentTime; }
		public function set currentTime(t:Number):void {
			if (t < _currentTime) playhead = 0;
			_currentTime = t;
			while (_currentTime >= timings[playhead]) {
				if (++playhead >= timings.length) {
					playhead = timings.length - 1;
					break;
				}
			}
			frame = frames[playhead];
		}
		
		// used only by TPlayer
		private function getCurrentTime():TVector1
		{
			return new TVector1(currentTime);
		}
		private function setCurrentTime(value:TVector1):void
		{
			currentTime = value.x;
		}

	}
}