package fanlib.ui.slider
{
	import fanlib.math.Maths;
	import fanlib.text.FTextField;
	import fanlib.utils.FStr;

	/**
	 * @author http://stackoverflow.com/questions/846221/logarithmic-slider
	 */
	public class SliderTextLog extends Slider
	{
		private var _min:Number; // The result should be between _min and _max
		private var _max:Number;
		private var minv:Number;
		private var maxv:Number;
		private var scale:Number; // adjustment factor
		private var _valueLog:Number;
		
		public var text:FTextField;
		public var decimals:Number = 2;
		
		public function SliderTextLog()
		{
			super();
		}
		
		override public function set value(val:Number):void {
			super.value = val;
			_valueLog = Math.exp(minv + scale*value);
			if (text) text.htmlText = FStr.RoundToString(_valueLog, decimals);
		}
		
		public function get valueLog():Number { return _valueLog; }
		public function set valueLog(val:Number):void {
			value = (Math.log(val)-minv)/scale;
		}
		
		public function get max():Number { return _max; }
		public function set max(val:Number):void
		{
			_max = val;
			maxv = Math.log(_max);
			scale = maxv-minv;
			value = value;
		}
		
		public function get min():Number { return _min; }
		public function set min(val:Number):void
		{
			_min = val;
			minv = Math.log(_min);
			scale = maxv-minv;
			value = value;
		}
		
		override public function copy(baseClass:Class = null):* {
			var obj:SliderTextLog = super.copy(baseClass);
			obj.decimals = decimals;
			obj._min = _min;
			obj.max = _max;
			return obj;
		}
	}
}