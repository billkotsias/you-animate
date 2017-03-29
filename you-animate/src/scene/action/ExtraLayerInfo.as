package scene.action
{
	import fanlib.utils.Enum;

	public class ExtraLayerInfo
	{
		static public function VectorFromInfo(array:Array, defaultRate:Number):Vector.<ExtraLayerInfo> {
			var layers:Vector.<ExtraLayerInfo>;
			if (array && array.length) {
				layers = new Vector.<ExtraLayerInfo>;
				for each (var arr:* in array) {
					if (arr is String) arr = String(arr).split(",");
					layers.push( new ExtraLayerInfo( arr, defaultRate ) );
				}
			}
			return layers;
		}
		
		//
		
		private var data:Array;
		private var _mode:Enum;
		private var _rate:Number;
		
		public function ExtraLayerInfo(data:Array, defaultRate:Number)
		{
			this.data = data;
			_rate = (data[3] || defaultRate);
			_mode = ActionInfo.ParseLoopMode(data[4]);
		}
		
		public function get bone():String { return data[0] }
		public function get from():Number { return data[1] }
		public function get to():Number { return data[2] - 1 } // exclusive!
		public function get rate():Number { return _rate }
		public function get mode():Enum { return _mode }
	}
}