package fanlib.tween {
	
	public class TVector1 implements ITweenedData {

		static public function FromArray(arr:Array):Array {
			var res:Array = [];
			for (var i:int = 0; i < arr.length; ++i) {
				res.push(new TVector1(arr[i]));
			}
			return res;
		}
		
		public var x:Number;
		
		public function TVector1(_x:Number) {
			x = _x;
		}
		
		public function copy():ITweenedData {
			return new TVector1(x);
		}
		
		// math
		// NOTE : use only with same classes!
		public function add(d:ITweenedData):ITweenedData {
			return new TVector1( x + (d as TVector1).x );
		};
		public function sub(d:ITweenedData):ITweenedData {
			return new TVector1( x - (d as TVector1).x );
		};
		public function mul(d:ITweenedData):ITweenedData {
			return new TVector1( x * (d as TVector1).x );
		};
		public function div(d:ITweenedData):ITweenedData {
			return new TVector1( x / (d as TVector1).x );
		};
		public function addN(n:Number):ITweenedData {
			return new TVector1( x + n );
		};
		public function subN(n:Number):ITweenedData {
			return new TVector1( x - n );
		};
		public function mulN(n:Number):ITweenedData {
			return new TVector1( x * n );
		};
		public function divN(n:Number):ITweenedData {
			return new TVector1( x / n );
		};
		public function idivN(n:Number):ITweenedData {
			return new TVector1( n / x );
		};

	}
	
}
