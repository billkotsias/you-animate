package fanlib.sound {
	import fanlib.utils.DelayedCall;
	
	public class MusicManager {
		
		static public const DEFAULT:MusicManager = new MusicManager();
		
		static public var Path:String = "mus/";
		static public var Extension:String = ".mp3";
		
		private var _masterVolume:Number = 1;
		public var fadeOutTime:Number = 1.5;
		public var delayToStart:Number = 0.7;
		
		private var note:Note = new Note();
		private var currentMusic:String;
		private var delayedStart:DelayedCall; 
		
		public function MusicManager() {
		}
		
		public function play(file:String, startAt:Number = 0):void {
			if (currentMusic == file) return;
			stop();
			currentMusic = file;
			if (!file) return;
			
			note.file = Path + file + Extension;
			note.setVolume(masterVolume);
			if (delayedStart) delayedStart.dismiss();
			delayedStart = new DelayedCall(note.playLooped, delayToStart, startAt);
		}
		
		public function stop():void {
			if (note.isLastNotePlaying()) {
				note.getLastPlayingNote().fadeAndStop(fadeOutTime);
			}
		}

		public function get masterVolume():Number
		{
			return _masterVolume;
		}
		public function set masterVolume(value:Number):void
		{
			_masterVolume = value;
			if (note.isLastNotePlaying()) {
				note.getLastPlayingNote().volume = _masterVolume;
			}
		}


	}
	
}
