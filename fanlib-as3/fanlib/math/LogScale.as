package fanlib.math
{
	public class LogScale
	{
		// user set
		private var _min:Number; // The result should be between _min and _max
		private var _max:Number;
		
		private var minv:Number;
		private var maxv:Number;
		private var scale:Number; // adjustment factor
		
		// TODO: Allow any base, not only Math.E!
		
		public function LogScale(minimum:Number = 0, maximum:Number = 1)
		{
			setMinMax(minimum, maximum);
		}
		
		public function setMinMax(minimum:Number, maximum:Number):void {
			_max = maximum;
			maxv = Math.log(_max);
			
			_min = minimum;
			minv = Math.log(_min);
			
			scale = maxv-minv;
		}
		
		/**
		 * @param factor [0 ... 1]
		 * @return [min ... max], in log scale
		 */
		public function getLogValue(factor:Number):Number {
			return Math.exp(minv + scale*factor);
		}
		
		/**
		 * @param logValue [min ... max], in log scale
		 * @return factor [0 ... 1]
		 */
		public function getFactorFromLog(logValue:Number):Number {
			return (Math.log(logValue)-minv)/scale;
		}
		
		public function get max():Number { return _max; }
		public function get min():Number { return _min; }
	}
}