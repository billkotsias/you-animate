package fanlib.math {
	
	import fanlib.utils.Pair;
	
	import flash.geom.Point;
	
	public class Maths {

		static public function moduloPositive(dividend:int, divisor:uint):int {
			var modulo:Number = dividend % divisor;
			if (modulo < 0) modulo += divisor;
			return modulo;
		}
		
		static public const RadToDeg:Number = 180 / Math.PI;
		static public const DegToRad:Number = Math.PI / 180;
		
		// random in [min,max)
		static public function random(min:Number, max:Number):Number {
			return Math.random() * (max - min) + min;
		}
		
		// random int in [0,max)
		static public function randomUInt(max:uint):uint {
			return uint(Math.floor(Math.random() * max));
		}
		
		// bound n in [-b,b]
		static public function bound(n:Number, b:Number):Number {
			if (n > b) {
				n = b;
			} else if (n < -b) {
				n = -b;
			}
			return n;
		}
		// bound n in [bmin,bmax]
		static public function bound2(n:Number, bmin:Number, bmax:Number):Number {
			if (n > bmax) {
				n = bmax;
			} else if (n < bmin) {
				n = bmin;
			}
			return n;
		}

		// => array of values, or direct comma-separated values
		static public function getMinMax(...args):Pair {
			if (args.length == 1 && args[0] is Array) args = args[0];
			
			var min:Number = Infinity;
			var max:Number = -Infinity;
			for (var i:int = args.length - 1; i >= 0; --i) {
				const val:Number = args[i];
				if (min > val) min = val;
				if (max < val) max = val;
			}
			return new Pair(min, max);
		}
		
		[Inline]
		static public function sum(arr:Object):Number {
			var sumy:Number = 0;
			for (var i:int = arr.length-1; i >= 0; --i) {
				sumy += arr[i];
			}
			return sumy;
		}
		
		static public function maxAbs(...args):Number {
			if (args.length === 1 && args[0] is Array) args = args[0];
			
			var max:Number = -Infinity;
			for each (var val:Number in args) {
				if (val < 0) val = -val;
				if (max < val) max = val;
			}
			
			return max;
		}
		
		// 'roundTo' can be < 1, e.g "0.01"
		static public function roundTo(value:Number, roundTo:Number):Number {
			return Math.round(value / roundTo) * roundTo;
		}
		
		// Fastest isNaN function
		// NOTE : if speed is super-critical, don't call this function but instead use directly inline comparison below! (C++ style)
		[Inline]
		static public function IsNaN(val:Number):Boolean
		{
			return val !== val;
		}
		
		[Inline]
		static public function LERP(from:Number, to:Number, factor:Number):Number {
			return from + (to - from) * factor;
		}
		
		static public function AngleBetweenPoints(point1:Point, point2:Point):Number {
			const dx:Number = point2.x - point1.x;
			const dy:Number = point2.y - point1.y;
			const a:Number = Math.atan2(dy, dx);
			return a;
		}
	}
	
}
