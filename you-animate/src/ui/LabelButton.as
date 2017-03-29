package ui
{
	import fanlib.ui.FButton2;

	public class LabelButton extends LabeledUI
	{
		static public const BUTTON_NAME:String = "button";
		private var _button:FButton2;
		
		public function LabelButton()
		{
			super();
		}
		
		override public function initLast():void {
			super.initLast();
			_button = findChild(BUTTON_NAME);
		}
		
		public function get button():FButton2 { return _button }
	}
}