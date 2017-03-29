package fanlib.math {
	
	import flash.geom.Vector3D;

	public class BezierCubic3D
	{
		public const anchor1:Vector3D = new Vector3D();
		public const anchor2:Vector3D = new Vector3D();
		public const control1:Vector3D = new Vector3D();
		public const control2:Vector3D = new Vector3D();
		/**
		 * Gets values from both 'getPointAt' and 'getDirectionAt'
		 */
		public const result:Vector3D = new Vector3D();
		private const previous:Vector3D = new Vector3D(); // temporary (optimization)
		
		// normalization aka arc-parameterization
		public var arcLengths:Vector.<Number> = new Vector.<Number>;
		public var steps:Number = 100;
		
		private var _length:Number;
		
		public function BezierCubic3D()
		{
		}
		
		/**
		 * To get a point between anchor1 and anchor2, pass value [0...1]
		 * @param t
		 */
		public function getPointAt(t:Number):Vector3D {
			const t2:Number = t*t;
			const t3:Number = t*t2;
			const threeT:Number = 3*t;
			const threeT2:Number = 3*t2;
			result.x = getPointAxisAt(anchor1.x, anchor2.x, control1.x, control2.x, t3, threeT, threeT2);
			result.y = getPointAxisAt(anchor1.y, anchor2.y, control1.y, control2.y, t3, threeT, threeT2);
			result.z = getPointAxisAt(anchor1.z, anchor2.z, control1.z, control2.z, t3, threeT, threeT2);
			return result;
		}
		public function getPointAxisAt(a1:Number,a2:Number,c1:Number,c2:Number, t3:Number, threeT:Number, threeT2:Number):Number {
			return	t3		* (a2+3*(c1-c2)-a1) +
					threeT2 * (a1-2*c1+c2) +
					threeT  * (c1-a1) +
					a1;
		}
		
		/**
		 * @param t
		 * @return Un-normalized Vector3D! 
		 */
		public function getDirectionAt(t:Number):Vector3D {
			const threeT2:Number = 3 * t * t;
			const sixT:Number = 6 * t;
			result.x = getDirAxisAt(anchor1.x, anchor2.x, control1.x, control2.x, threeT2, sixT);
			result.y = getDirAxisAt(anchor1.y, anchor2.y, control1.y, control2.y, threeT2, sixT);
			result.z = getDirAxisAt(anchor1.z, anchor2.z, control1.z, control2.z, threeT2, sixT);
			return result;
		}
		public function getDirAxisAt(a1:Number,a2:Number,c1:Number,c2:Number, threeT2:Number, sixT:Number):Number {
			return	threeT2	* (a2+3*(c1-c2)-a1) +
					sixT	* (a1-2*c1+c2) +
					3		* (c1-a1);
		}
		
		public function getDirectionDerivativeAt(t:Number):Vector3D {
			const sixT:Number = 6 * t;
			result.x = getDirDerAxisAt(anchor1.x, anchor2.x, control1.x, control2.x, sixT);
			result.y = getDirDerAxisAt(anchor1.y, anchor2.y, control1.y, control2.y, sixT);
			result.z = getDirDerAxisAt(anchor1.z, anchor2.z, control1.z, control2.z, sixT);
			return result;
		}
		public function getDirDerAxisAt(a1:Number,a2:Number,c1:Number,c2:Number, sixT:Number):Number {
			return	sixT	* (a2+3*(c1-c2)-a1) +
					6		* (a1-2*c1+c2);
		}
		
		/**
		 * Call this after any change to defining points and before accessing normalized points of curve.
		 */
		public function recalc():void {
			arcLengths.length = steps + 1;
			arcLengths[0] = 0;
			const step:Number = 1 / steps;
			
			previous.copyFrom(getPointAt(0));
			_length = 0;
			for (var i:int = 1; i <= steps; ++i) {
				_length += Vector3D.distance(getPointAt(i * step), previous);
				arcLengths[i] = _length;
				previous.copyFrom(result);
			}
		}
		
		/**
		 * 'recalc' must have already been called if any changes were made to any of the defining points 
		 * @param u
		 * @return u normalized/converted to t
		 */
		public function normalizeT(u:Number):Number {
			var targetLength:Number = u * arcLengths[steps];
			var low:int = 0,
				high:int = steps,
				index:int; // TODO : have a look-up table of starting low/high indices for each step!
			while (low < high) {
				index = low + ((high - low) >>> 1);
				if (arcLengths[index] < targetLength) {
					low = index + 1;
				} else {
					high = index;
				}
			}
			if (this.arcLengths[index] > targetLength) {
				--index;
			}
			var lengthBefore:Number = arcLengths[index];
			if (lengthBefore === targetLength) {
				return index / steps;
			} else {
				return (index + (targetLength - lengthBefore) / (arcLengths[index + 1] - lengthBefore)) / steps;
			}
		}
		
		public function getNormalizedPointAt(u:Number):Vector3D {
			return getPointAt(normalizeT(u));
		}
		
		/**
		 * "Normalized" goes for t, not the return Vector3D!!! 
		 * @param u
		 * @return Un-normalized Vector3D!
		 */
		public function getNormalizedDirectionAt(u:Number):Vector3D {
			return getDirectionAt(normalizeT(u));
		}
		
		public function getNormalizedDirectionDerivativeAt(u:Number):Vector3D {
			return getDirectionDerivativeAt(normalizeT(u));
		}
		
		public function get length():Number
		{
			return _length;
		}

	}
}