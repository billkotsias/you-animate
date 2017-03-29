package ui.play
{
	import fanlib.event.ObjEvent;
	import fanlib.text.FTextField;
	import fanlib.tween.TVector1;
	import fanlib.ui.slider.Slider;
	import fanlib.utils.FStr;
	
	import flash.events.Event;
	
	import scene.Character;
	import scene.Scene;
	import scene.camera.anim.ZoomManager;
	
	public class Timeline extends Slider
	{
		public var timeTxt:FTextField;
		
		private var _durationTotal:Number = 0;
		private var _time:Number;
		
		public var zoomMan:ZoomManager;
		
		public function Timeline()
		{
			super();
			Scene.INSTANCE.addEventListener(Scene.SCENE_OBJECTS_CHANGED, sceneChanged, false, 0, true);
		}
		
		private function sceneChanged(e:ObjEvent):void {
			_durationTotal = 0;
			Scene.INSTANCE.characters.forEach(getCharDuration);
			if (_time >= _durationTotal) {
				if (_durationTotal) time = _durationTotal; else value = 0; 
			}
			
			updateText();
//			value = _value; // crash when character created
		}
		private function getCharDuration(char:Character):void {
			const charDur:Number = char.duration;
			if (charDur > _durationTotal) _durationTotal = charDur;
		}
		
		override public function set value(val:Number):void {
			super.value = val;
			_time = _value * _durationTotal;
			updateText();
			Scene.INSTANCE.characters.forEach(setCharTime);
			zoomMan.setTime(_time);
		}
		private function setCharTime(char:Character):void {
			char.setTime(_value * _durationTotal);
		}
		
		public function updateText():void {
			timeTxt.htmlText = FStr.SecsToMins(_time, 1) + '/' + FStr.SecsToMins(_durationTotal, 1);
		}
		
		public function get durationTotal():Number
		{
			return _durationTotal;
		}

		public function get time():Number { return _time }
		public function set time(t:Number):void {
			value = t / _durationTotal;
		}
		
		// tweening
		public function getValue():TVector1 { return new TVector1(_value) }
		public function setValue(t:TVector1):void { value = t.x }
	}
}