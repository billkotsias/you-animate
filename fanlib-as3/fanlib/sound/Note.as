package fanlib.sound {
	
	import fanlib.tween.TVector1;
	import fanlib.utils.FArray;
	import fanlib.utils.Pair;
	import fanlib.utils.Utils;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.sampler.Sample;
	import flash.utils.Dictionary;
	
	public class Note {

		// static
		
		static private var _MasterVolume:Number = 1;
		static private const PlayingNotes:Dictionary = new Dictionary();
		
		static public function set MasterVolume(vol:Number):void {
			_MasterVolume = vol;
			
			for (var playingNote:Object in PlayingNotes) {
				(playingNote as PlayingNote).applyCurrentValues();
			}
		}
		static public function get MasterVolume():Number { return _MasterVolume; }

		static public function StopAll():void {
			for (var playingNote:Object in PlayingNotes) {
				(playingNote as PlayingNote).stop();
				delete PlayingNotes[playingNote];
			}
		}
		
		static public var Path:String = "";

		// static
		
		private var sound:Sound;
		private var playingNote:PlayingNote;
		 
		private var _volume:Number = 1.0;	// } default values for this Note
		public var panning:Number = 0;		// }
		
		public function Note(_file:String = null, _sound:Sound = null) {
			setSound(_sound);
			file = _file;
		}
		
		public function setSound(_sound:Sound):void {
			if (_sound) sound = _sound;
		}
		
		public function set file(_file:String):void {
			//trace(this, PATH + _file);
			if (_file) {
				sound = new Sound();
				sound.addEventListener(IOErrorEvent.IO_ERROR, ioError, false, 0, true);
				sound.load(new URLRequest(Path + _file));
			}
		}
		private function ioError(e:IOErrorEvent):void {
			trace(this + " IOError: " + e.text);
			sound = null;
		}
		
		public function play(loops:int = 0, start:Number = 0):PlayingNote {
			if (!sound) return null;
			playingNote = new PlayingNote(sound.play(start, loops, new SoundTransform(_volume * _MasterVolume, panning)));		
			playingNote._volume = _volume;
			playingNote.panning = panning;
			
			PlayingNotes[playingNote] = true;
			playingNote.addEventListener(Event.SOUND_COMPLETE, playingNoteComplete, false, 0, true);
			
			return playingNote;
		}
		
		public function getLastPlayingNote():PlayingNote { return playingNote; }
		public function stopLastPlayingNote():void { if (playingNote) playingNote.stop(); }
		
		public function isLastNotePlaying():Boolean {
			if (playingNote) return playingNote.isValid();
			return false;
		}

		public function playLooped(start:Number = 0):PlayingNote {
			return play(int.MAX_VALUE, start);
		}
		
		static private function playingNoteComplete(e:Event):void {
			var _playingNote:PlayingNote = e.currentTarget as PlayingNote;
			_playingNote.removeEventListener(Event.SOUND_COMPLETE, playingNoteComplete);
			delete PlayingNotes[_playingNote];
		}

		public function getVolume():Number
		{
			return _volume;
		}

		public function setVolume(value:Number):Note
		{
			_volume = value;
			return this; // cool eh?
		}

	}
	
}
