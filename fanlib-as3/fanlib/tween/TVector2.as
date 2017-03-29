package fanlib.tween {
	
	import flash.geom.Point;
	
	public class TVector2 implements ITweenedData {
		
		static public function FromUniformArray(arr:Array):Array {
			var res:Array = [];
			for (var i:int = 0; i < arr.length; ++i) {
				res.push(new TVector2(arr[i], arr[i]));
			}
			return res;
		}

		public var x:Number;
		public var y:Number;
		
		public function TVector2(_x:Number = 0,_y:Number = 0) {
			x = _x;
			y = _y;
		}
		
		public function copy():ITweenedData {
			return new TVector2(x,y);
		}
		
		static public function FromPoint(p:Point):TVector2 {
			return new TVector2(p.x, p.y);
		}
		static public function ToPoint(t:TVector2):Point {
			return new Point(t.x, t.y);
		}
		
		// math
		// NOTE : use only with same classes!
		public function add(d:ITweenedData):ITweenedData {
			return new TVector2( x + (d as TVector2).x, y + (d as TVector2).y );
		};
		public function sub(d:ITweenedData):ITweenedData {
			return new TVector2( x - (d as TVector2).x, y - (d as TVector2).y );
		};
		public function mul(d:ITweenedData):ITweenedData {
			return new TVector2( x * (d as TVector2).x, y * (d as TVector2).y );
		};
		public function div(d:ITweenedData):ITweenedData {
			return new TVector2( x / (d as TVector2).x, y / (d as TVector2).y );
		};
		public function addN(n:Number):ITweenedData {
			return new TVector2( x + n, y + n );
		};
		public function subN(n:Number):ITweenedData {
			return new TVector2( x - n, y - n );
		};
		public function mulN(n:Number):ITweenedData {
			return new TVector2( x * n, y * n );
		};
		public function divN(n:Number):ITweenedData {
			return new TVector2( x / n, y / n );
		};
		public function idivN(n:Number):ITweenedData {
			return new TVector2( n/ x, n / y );
		};

		public function toString():String {
			return "[TVector2:"+x+","+y+"]";
		}
		
		// to be added to interface!
		public function equals(t:TVector2):Boolean {
			if (x == t.x && y == t.y) return true;
			return false;
		}
		
		// <= swaps signs and return self
		public function negative():TVector2 {
			return new TVector2(- x, - y);
		}
	}
	
}
