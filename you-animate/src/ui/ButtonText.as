package ui
{
	import fanlib.text.FTextField;
	import fanlib.ui.FButton2;
	
	public class ButtonText extends FButton2
	{
		public function ButtonText()
		{
			super();
		}
		
		public function set textProp(arr:Array):void {
			const propertyName:String = arr[0];
			const value:* = arr[1];
			for each (var s:String in states) {
				const field:FTextField = getChildByName(s) as FTextField;
				if (field) field[propertyName] = value;
			}
		}
	}
}