package tools.selectChar
{
	import flash.events.Event;
	
	import tools.Tool;
	
	public class SelectCharContext extends Tool
	{
		protected var _selectChar:SelectChar;
		
		public function SelectCharContext()
		{
			super();
		}
		
		public function get selectChar():SelectChar { return _selectChar }
		public function set selectChar(value:SelectChar):void
		{
			_selectChar = value;
			_selectChar.addEventListener(SelectChar.CHAR_SELECTED, charSelected, false, 0, true);
			_selectChar.addEventListener(SelectChar.CHAR_DESELECTED, charDeselected, false, 0, true);
		}
		
		protected function charSelected(e:Event = null):void {
			enabled = true;
		}
		protected function charDeselected(e:Event = null):void {
			enabled = false;
		}
	}
}