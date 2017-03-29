package ui
{
	import fanlib.gfx.FSprite;
	import fanlib.text.FTextField;
	import fanlib.ui.CheckButton;
	import fanlib.utils.IInit;
	import fanlib.utils.Parser;
	
	import flash.events.Event;
	
	import upload.IUItoObject;
	
	public class LabelCheck extends LabeledUI implements IUItoObject
	{
		static public const BUTTON_NAME:String = "checkButton";
		private var _button:CheckButton;
		
		public var invert:Boolean = false;
		
		public function LabelCheck()
		{
			super();
		}
		
		override public function initLast():void {
			super.initLast();
			_button = findChild(BUTTON_NAME);
			_button.addEventListener(CheckButton.CHANGE, carryEventOn);
		}
		private function carryEventOn(e:Event):void {
			dispatchEvent(new Event(CHANGE));
		}
		
		public function get button():CheckButton { return _button }
		
		public function get state():Boolean { return _button.state }
		public function set state(e:Boolean):void { _button.state = e }
		
		public function get enabled():Boolean { return _button.enabled }
		public function set enabled(e:Boolean):void { _button.enabled = e }
		
		public function set result(b:*):void {
			b = Parser.toBool(b);
			if (invert) {
				state = !b;
			} else {
				state = b;
			}
		}
		public function get result():* {
			if (invert) return !state;
			return state;
		}
	}
}