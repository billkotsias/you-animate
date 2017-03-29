package fanlib.ui.slider
{
	import fanlib.math.Maths;
	import fanlib.text.FTextField;
	import fanlib.utils.FStr;

	public class SliderText extends Slider
	{
		private var _min:int;
		private var _max:int;
		private var _valueNum:Number;
		
		public var text:FTextField;
		public var decimals:Number = 1;
		
		public function SliderText()
		{
			super();
		}
		
		override public function set value(val:Number):void {
			super.value = val;
			_valueNum = _min + value * (_max - _min);
			text.htmlText = FStr.RoundToString(_valueNum, decimals);
		}
		
		public function get max():uint { return _max; }
		public function set max(val:uint):void
		{
			_max = val;
			value = value;
		}
		
		public function get min():uint { return _min; }
		public function set min(val:uint):void
		{
			_min = val;
			value = value;
		}
		
		public function set valueNum(val:Number):void {
			value = (val - _min) / (_max - _min);
		}
		public function get valueNum():Number
		{
			return _valueNum;
		}
		
		override public function copy(baseClass:Class = null):* {
			var obj:SliderText = super.copy(baseClass);
			obj.decimals = decimals;
			obj._min = _min;
			obj._max = _max;
			value = value;
			return obj;
		}
	}
}