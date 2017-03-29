package ui
{
	import fanlib.ui.TouchMenu;
	
	import flash.events.Event;
	
	import tools.selectChar.SelectChar;
	
	public class CharContext extends TouchMenu
	{
		protected var _selectChar:SelectChar;
		
		public function CharContext()
		{
			super();
			mouseWheel = 10;
		}
		
		public function set selectChar(value:SelectChar):void
		{
			_selectChar = value;
			_selectChar.addEventListener(SelectChar.CHAR_SELECTED, charSelected, false, 0, true);
			_selectChar.addEventListener(SelectChar.CHAR_DESELECTED, charDeselected, false, 0, true);
		}
		
		protected function charSelected(e:Event = null):void {
		}
		protected function charDeselected(e:Event = null):void {
		}
	}
}