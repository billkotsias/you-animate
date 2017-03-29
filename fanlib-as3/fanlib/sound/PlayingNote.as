package fanlib.sound {
	
	import flash.media.SoundTransform;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.media.SoundChannel;
	import fanlib.tween.TVector1;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	
	public class PlayingNote extends EventDispatcher {
		
		private var soundChannel:SoundChannel;
		private var _isValid:Boolean = true;
		
		internal var _volume:Number;
		internal var panning:Number;
		
		protected var fadeList:TList = null;	// handle fading "collisions"

		// TODO : handle pause/unpause internally, here (must have pointer to original Note)
		
		public function PlayingNote(_soundChannel:SoundChannel) {
			soundChannel = _soundChannel;
			soundChannel.addEventListener(Event.SOUND_COMPLETE, channelComplete, false, 0, true);
		}
		
		private function channelComplete(e:Event = null):void {
			if (fadeList) {
				fadeList.removeEventListener(TList.TLIST_COMPLETE, channelComplete);
				TPlayer.DEFAULT.removePlaylist(fadeList, false);
				fadeList = null;
			}
			
			soundChannel.removeEventListener(Event.SOUND_COMPLETE, channelComplete);
			stop();
		}
		
		public function isValid():Boolean { return _isValid; }
		
		public function stop():void {
			soundChannel.stop();
			_isValid = false;
			dispatchEvent(new Event(Event.SOUND_COMPLETE));
		}
		
		// duration = time to go from volume = 1 down to 0!
		public function fadeAndStop(dur:Number, delay:Number = 0):void {
			TPlayer.DEFAULT.removePlaylist(fadeList, false);
			fadeList = TPlayer.DEFAULT.addTween(new TLinear(new TVector1(0),
												 getVolume, setVolume,
												 Math.abs(dur * _volume), delay));
			fadeList.addEventListener(TList.TLIST_COMPLETE, channelComplete, false, 0, true);
		}
		
		// for convenience
		public function set volume(vol:Number):void {
			setVolume(new TVector1(vol));
		}
		public function get volume():Number {
			return _volume;
		}
		
		public function setVolume(vol:TVector1):void {
			_volume = vol.x;
			applyCurrentValues();
		}
		public function getVolume():TVector1 {
			return new TVector1(_volume);
		}
		
		public function setPanning(pan:TVector1):void {
			panning = pan.x;
			applyCurrentValues();
		}
		public function getPanning():TVector1 {
			return new TVector1(panning);
		}
		
		internal function applyCurrentValues():void {
			// best tactic is to have a "SceneGraph" for volume : root (master) -> parent -> ... -> local ('NoteContainer')
			soundChannel.soundTransform = new SoundTransform(_volume * Note.MasterVolume, panning);
		}

		public function get position():Number {
			return soundChannel.position;
		}
	}
	
}
