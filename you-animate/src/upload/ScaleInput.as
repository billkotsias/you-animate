package upload
{
	import fanlib.utils.FStr;
	
	import ui.LabelInputNum;
	
	public class ScaleInput extends LabelInputNum
	{
		public function ScaleInput()
		{
			super();
		}
		
		override public function get result():* {
			return super.result * 0.07; // super.result makes sure it's not a NaN
		}
		override public function set result(t:*):void { input = FStr.RoundToString(t / 0.07, 3) }
	}
}