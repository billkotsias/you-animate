package scene.action
{
	import fanlib.utils.Enum;
	
	import scene.CharManager;
	import scene.action.special.PropInfo;

	public class ActionInfo
	{
		static public const STOP_STR:String = "stop";
		static public const LOOP_STR:String = "loop";
		static public const PING_PONG_STR:String = "pingpong";
		
		private var data:Object;
		private var _prop:PropInfo;
		private var _layers:Vector.<ExtraLayerInfo>;
		private var _mode:Enum;
		
		public function ActionInfo(data:Object)
		{
			this.data = data;
			
			if (data.prop) {
				_prop = CharManager.INSTANCE.getPropInfoByID(data.prop);
			}
			_layers = ExtraLayerInfo.VectorFromInfo( data.layers, rate );
			_mode = ParseLoopMode(data.mode);
		}
		
		// generic
		public function get i():String { return data.i }
		public function get id():String { return data.id }
		public function get from():Number { return data.from }
		/**
		 * In script is exclusive!!! Here it is converted (-1) to inclusive!!!
		 */
		public function get to():Number { return data.to - 1 }
		public function get mode():Enum { return _mode }
		public function get rate():Number { return data.rate }
		public function get speed():Number { return data.speed }
		public function get _class():String {
			var _cl:*;
			if ( (_cl = data["class"]) === undefined ) _cl = data["_class"];
			return _cl;
		}
		
		public function get prop():PropInfo {
			return ( _prop || (_prop = CharManager.INSTANCE.getPropInfoByID(data.prop)) );
		}
		
		// drive action
		public function get idleFrom():Number { return data.idleFrom }
		public function get idleTo():Number { return data.idleTo - 1 }
		
		// extra animation layers
		public function get layers():Vector.<ExtraLayerInfo> { return _layers }
		
		static public function ParseLoopMode(str:String):Enum {
			switch (str) {
				case STOP_STR:
					return Action.STOP;
				case PING_PONG_STR:
					return Action.PING_PONG;
			}
			return Action.LOOP;
		}
	}
}