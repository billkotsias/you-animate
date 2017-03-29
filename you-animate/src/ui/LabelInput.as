package ui
{
	import fanlib.gfx.FSprite;
	import fanlib.text.FTextField;
	import fanlib.utils.IInit;
	
	import flash.events.Event;
	
	import upload.IUItoObject;
	
	public class LabelInput extends LabeledUI implements IUItoObject
	{
		static public var TabIndex:uint = 1;
		
		static public const INPUT_NAME:String = "input";
		protected var _input:FTextField;
		
		public function LabelInput()
		{
			super();
		}
		
		override public function initLast():void {
			super.initLast();
			if (!_input) _input = findChild(INPUT_NAME);
			if (_input) _input.tabIndex = TabIndex++;
			_input.addEventListener(FTextField.FINALIZED, carryEventOn);
		}
		private function carryEventOn(e:Event):void {
			dispatchEvent(new Event(CHANGE));
		}
		
		public function get inputField():FTextField { return _input }
		
		public function get input():String { return _input.text }
		public function set input(txt:String):void { _input.htmlText = txt }
		
		public function get result():* { return input }
		public function set result(t:*):void { input = (t === null) ? "" : t }
		
		//
		
		public function set inputObj(inp:FTextField):void {
			_input = inp;
		}
		
		override public function copy(baseClass:Class = null):* {
			const linp:LabelInput = super.copy(baseClass);
			if (!linp._input) {
				linp._input = linp.findChild(this._input.name);
				linp.initLast();
			}
			return linp;
		}
	}
}