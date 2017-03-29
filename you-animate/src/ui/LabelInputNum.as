package ui
{
	import fanlib.text.FTextField;
	
	import flash.events.Event;

	public class LabelInputNum extends LabelInput
	{
		public var min:Number;
		public var max:Number;
		public var def:Number = 0; // default value if none set
		
		public function LabelInputNum()
		{
			super();
		}
		
		override public function initLast():void {
			super.initLast();
			_input.addEventListener(FTextField.FINALIZED, checkInput);
		}
		private function checkInput(e:Event):void {
			var value:Number = Number(_input.text);
			if (min === min && value < min) value = min;
			if (max === max && value > max) value = max;
			_input.htmlText = value.toString();
		}
		
		// make sure it's not a NaN
		override public function get result():* {
			var res:Number = Number(input);
			if (res !== res || input === "") res = def;
			return res;
		}
	}
}