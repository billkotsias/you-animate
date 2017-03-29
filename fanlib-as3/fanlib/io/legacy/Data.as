package fanlib.io.legacy {
	
	public class Data {

		private var data:Array;
		
		// constructor
		public function Data() {
			data = new Array();
		}

		public function push(name:String, val:Object):void {
			data[name] = val;
		}
		
		public function getNumber(name:String):Number {
			return Number(data[name]);
		}
		
		public function getInt(name:String):int {
			return int(data[name]);
		}
		
		public function getBool(name:String):Boolean {
			return Boolean(data[name]);
		}
		
		public function getString(name:String, fixNL:Boolean = true):String {
			if (data[name] == undefined) return ""; // <!!!>
			var s:String = data[name];
			if (fixNL) {
				var exp:RegExp = new RegExp(String.fromCharCode(13,10), "g");
				s = s.replace(exp, String.fromCharCode(10));
			}
			return s;
		}
		
		public function getData(name:String):Data {
			return (data[name] as Data);
		}
		
		public function getObject(name:String):Object {
			return data[name];
		}
	}
	
}
