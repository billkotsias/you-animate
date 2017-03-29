package fanlib.tween {
	
	public class TVector3 implements ITweenedData {

		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function TVector3(_x:Number = 0,_y:Number = 0, _z:Number = 0) {
			x = _x;
			y = _y;
			z = _z;
		}
		
		public function copy():ITweenedData {
			return new TVector3(x,y,z);
		}
		
		// math
		// NOTE : use only with same classes!
		public function add(d:ITweenedData):ITweenedData {
			return new TVector3( x + (d as TVector3).x, y + (d as TVector3).y, z + (d as TVector3).z );
		};
		public function sub(d:ITweenedData):ITweenedData {
			return new TVector3( x - (d as TVector3).x, y - (d as TVector3).y, z - (d as TVector3).z );
		};
		public function mul(d:ITweenedData):ITweenedData {
			return new TVector3( x * (d as TVector3).x, y * (d as TVector3).y, z * (d as TVector3).z );
		};
		public function div(d:ITweenedData):ITweenedData {
			return new TVector3( x / (d as TVector3).x, y / (d as TVector3).y, z / (d as TVector3).z );
		};
		public function addN(n:Number):ITweenedData {
			return new TVector3( x + n, y + n , z + n );
		};
		public function subN(n:Number):ITweenedData {
			return new TVector3( x - n, y - n , z - n );
		};
		public function mulN(n:Number):ITweenedData {
			return new TVector3( x * n, y * n , z * n );
		};
		public function divN(n:Number):ITweenedData {
			return new TVector3( x / n, y / n , z / n );
		};
		public function idivN(n:Number):ITweenedData {
			return new TVector3( n/ x, n / y , n / z );
		};

		public function toString():String {
			return "[TVector3:"+x+","+y+","+z+"]";
		}
		
		// for convenience
		// <= swaps signs and return self
		public function negative():TVector3 {
			return new TVector3(- x, - y, - z);
		}
	}
	
}
