package fanlib.utils {
	
	import fanlib.utils.ICompare;
	
	public class Pair implements ICompare {

		private var _key:*;
		private var _value:*;
		
		public function get key():* { return _key; }
		public function get value():* { return _value; }
		
		public function Pair(__key:*, __value:* = null) {
			_key = __key;
			_value = __value;
		}
		
		public function equal(obj:ICompare):Boolean {
			if (_key === (obj as Pair)._key) return true;
			return false;
		}
		
		// custom-override this to provide sorting support for 'Map'-type arrays
		public function lessThan(obj:ICompare):Boolean {
			return false;
		}
		
		public function toString():String {
			return "[object Pair: key=" + String(key) + " value=" + String(value) +"]";
		}
	}
	
}
