package scene.action.special
{
	import scene.action.ExtraLayerInfo;

	public class PropInfo
	{
		private var _data:Object;
		private var _layers:Vector.<ExtraLayerInfo>;
		
		public function PropInfo(data:Object)
		{
			_data = data;
			
			if (data.layers is String) data.layers = String(data.layers).split("|");
			_layers = ExtraLayerInfo.VectorFromInfo( data.layers, rate );
		}
		
		public function get data():Object { return _data; }
		
		// for convenience
		public function getFullFilePath():String {
			return Walk3D.AppendToPathIfRelative(Walk3D.PROPS_DIR, file);
		}
		
		// generic
		public function get id():String { return _data.id }
		public function get name():String { return _data.name }
		public function get file():String { return _data.url } // NOTE : Andreas-san masta
		public function get from():Number { return int(_data.from) }
		public function get to():Number { return int(_data.to) }
		public function get rate():Number { return _data.rate }
		public function get rest():Boolean { return _data["rest"] }
		public function get layers():Vector.<ExtraLayerInfo> { return _layers }
		
		// vehicle
		/**
		 * vehicle length
		 */
		public function get scale():Number { return _data.scale }
		public function get vLength():Number { return _data.vLength }
		public function get steerAngle():Number { return _data.steerAngle }
		public function get steerAnimFrom():Number { return _data.steerAnimFrom }
		public function get steerAnimTo():Number { return _data.steerAnimTo }
		public function get steerParent():String { return _data.steerPar }
		
		public function get wheels():Array {
			const val:* = _data.wheels;
			if (val is Array) return val;
			if (val === "") return []; // return as empty! Not of length 1, man!
			return String(val).split(",");
		}
		public function get dirWheels():Array {
			var val:* = _data.dirWheels;
			if (val is Array) return val;
			if (val === "") return []; // return as empty! Not of length 1, man!
			return String(val).split(",");
		}
		
		public function get wheelSpeed():Array {
			const _wheelSpeedStr:String = String(_data.wheelSpeed);
			const _wheelSpeed:Array = _wheelSpeedStr.split(",");
			for (var i:int = 0; i <= 2; ++i) {
				var num:Number = Number(_wheelSpeed[i]);
				if (num !== num) num = 0;
				_wheelSpeed[i] = num;
			}
			return _wheelSpeed; 
		}
		
	}
}