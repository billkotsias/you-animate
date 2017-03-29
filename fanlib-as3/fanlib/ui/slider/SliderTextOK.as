package fanlib.ui.slider
{
	import fanlib.gfx.TSprite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class SliderTextOK extends SliderText
	{
		static public var FADE:Number = 0.5;
		
		private var _open:Boolean;
		private var _okButton:DisplayObject;
		
		public function SliderTextOK()
		{
			super();
		}
		
		private function okDown(e:MouseEvent):void {
			if (!_open) return; // define hitArea (see DFXML script)
			open = false;
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function get open():Boolean { return _open; }
		public function set open(val:Boolean):void
		{
			_open = val;
			if (_open)
				fadein(FADE, 0, true);
			else
				fadeout(FADE, 0, TSprite.FADE_INVISIBLE);
		}

		public function get okButton():DisplayObject
		{
			return _okButton;
		}

		public function set okButton(value:DisplayObject):void
		{
			if (_okButton) _okButton.removeEventListener(MouseEvent.MOUSE_DOWN, okDown);
			_okButton = value;
			if (_okButton) _okButton.addEventListener(MouseEvent.MOUSE_DOWN, okDown, false, 0, true);
		}


	}
}