package fanlib.containers {
	import fanlib.utils.Pair;
	import fanlib.utils.Utils;
	
	public class Array2D {

		private var _width:uint;
		private var _height:uint;
		private var _table:Array;
		
		public function Array2D(width:uint, height:uint, table:Array = null) {
			_width = width;
			_height = height;
			_table = table;
			if (!_table) _table = new Array(_width * _height);
		}

		public function get table():Array { return _table; };

		public function get(x:int, y:int):* {
			return _table[y * _width + x];
		};

		public function set(value:*, x:int, y:int):void {
			_table[y * _width + x] = value;
		};

		/// clear to value
		public function clear(value:*):void {
			const size:uint = _width * _height;
			for (var i:uint = 0; i < size; ++i) {
				_table[i] = value;
			}
		};

		// <= x,y position, in a 'Pair'
		public function find(value:*):Pair {
			var index:int = _table.indexOf(value);
			var k:int = Math.floor(index / _width);
			var i:int = index - k * _width;
			return new Pair(i,k);
		}
		
		public function get width():uint { return _width; };
		public function get height():uint { return _height; };

		public function toString():String {
			var string:String = (Utils.GetClass(this)).toString() + "\n";
			for (var j:int = 0; j < _height; ++j) {
				for (var i:int = 0; i < _width; ++i) {
					string += get(i,j) + " ";
				}
				string = string.slice(0,-1) + "\n";
			}
			return string.slice(0,-1);
		}
	}
	
}
