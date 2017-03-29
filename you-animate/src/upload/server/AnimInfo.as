package upload.server
{
	import fanlib.utils.Utils;

	public class AnimInfo
	{
		public var i:String;	// id
		public var id:String;	// name (f*ck)
		
		public var from:Number;
		/**
		 * Is exclusive!!!
		 */
		public var to:Number;
		public var mode:String;
		public var rate:Number;
		public var speed:Number = 0;
		public var _class:String = "";
		
		// layers parsing
		private const _layers:Array = [];
		public function set layers(data:Object):void {
			const str1:String = String(data);
			_layers.length = 0;
			for each (var str2:String in str1.split("|")) {
				const newLayer:Array = str2.split(",");
				_layers.push( newLayer );
			}
			trace(this,Utils.PrettyString(layers));
		}
		public function get layers():Object {
			return _layers;
		}
		
		// special
		public var prop:String;
		
		// drive action
		public var idleFrom:Number;
		public var idleTo:Number;
		
		public function AnimInfo() {
		}
		
		public function toString():String {
			return "[AnimInfo: " + id.toString() + "," + from.toString() + "," + to.toString() + "]";
		}
	}
}