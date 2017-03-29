package fanlib.gfx {
	
	import fanlib.event.ObjEvent;
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TVector1;
	import fanlib.tween.Tween;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	// NOTE : No Audio allowed! (sync problems)
	public class Clip3 extends TSprite {
		
		static public const REACHED_END:String = "ReachedEnd";
		static public var Player:TPlayer; // must be initialized externally prior to playing
		
		public var loop:Number; // NaN = don't loop, else loop at that frame (1st frame = 1)
		public var frameRate:Number = 1;

		private var _playing:Boolean;
		public function get isPlaying():Boolean { return _playing; }
		public function set isPlaying(p:Boolean):void { _playing = p; }
		
		private var _currentFrame:Number;
		private var list:TList = new TList();
		
		private var clip:MovieClip;
		
		public function Clip3(c:MovieClip) {
			clip = c;
			addChild(clip);
			clip.gotoAndStop(1);
			stop();
			if (clip.loaderInfo) {
				frameRate = clip.loaderInfo.frameRate;
				//clip.loaderInfo.addEventListener(Event.INIT, checkProperties);
			}
		}
//		private function checkProperties(e:Event):void {
//			clip.loaderInfo.removeEventListener(Event.INIT, checkProperties);
//			frameRate = clip.loaderInfo.frameRate;
//		}
		
		public function play():void {
			playFrom();
		}
		public function playFrom(frame:int = 1):void {
			setFrame(new TVector1(frame));
			resume();
		}
		
		public function stop():void {
			pause();
			setFrame(new TVector1(1));
		}
		
		public function resume():void {
			pause();
			isPlaying = true;
			addLoop();
			Player.addPlaylist(list);
		}
		
		private function addLoop():void {
			var end:Number = clip.totalFrames + 0.999;
			var tween:Tween = new TLinear(new TVector1(end), getFrame, setFrame, (end - _currentFrame) / frameRate);
			tween.addEventListener(Tween.TWEEN_COMPLETE, tweenComplete, false, 0, true);
			list.add(tween);
		}
		
		public function pause():void {
			isPlaying = false;
			if (Player) Player.removePlaylist(list, false);
			list.clear();
		}
		
		protected function tweenComplete(e:Event):void {
			(e.currentTarget as Tween).removeEventListener(Tween.TWEEN_COMPLETE, tweenComplete);
			if (!_playing) return; // oops!
			
			dispatchEvent(new ObjEvent(this, REACHED_END));
			if (!isNaN(loop)) {
				setFrame(new TVector1(loop));
				addLoop();
			}
		}
		
		public function setFrame(f:TVector1):void {
			_currentFrame = f.x;
			var newFrame:int = _currentFrame;
			if (newFrame != clip.currentFrame) clip.gotoAndStop(newFrame);
		}
		public function getFrame():TVector1 {
			return new TVector1(_currentFrame);
		}
	}
	
}