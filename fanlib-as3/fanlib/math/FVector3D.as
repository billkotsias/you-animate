package fanlib.math
{
	import flash.geom.Vector3D;
	
	public class FVector3D extends Vector3D
	{
		public function FVector3D(x:Number=0.0, y:Number=0.0, z:Number=0.0, w:Number=0.0)
		{
			super(x, y, z, w);
		}
		
		/**
		 * Infinite Ray to infinite Plane collision
		 * @param pNormal Plane normal
		 * @param pCenter A Plane point
		 * @param rFrom Ray point (camera position)
		 * @param rDir Ray direction
		 * @param out Optional optimization. Don't create new Vector, return result in this one (may also be 'rFrom' or 'rDir').
		 * @return Ray-plane collision point
		 */
		static public function RayPlane(pNormal:Vector3D, pCenter:Vector3D, rFrom:Vector3D, rDir:Vector3D, out:Vector3D = null):Vector3D
		{
			const dist:Number = ( pNormal.dotProduct(pCenter) - pNormal.dotProduct(rFrom) ) / pNormal.dotProduct(rDir);
			if (!out) out = new Vector3D();
			out.x = rFrom.x + rDir.x * dist;
			out.y = rFrom.y + rDir.y * dist;
			out.z = rFrom.z + rDir.z * dist;
			return out;
		}
		
		static public function Zero(out:Vector3D = null):Vector3D {
			return CheckOut(out,0,0,0);
		}
		
		static public function Z_Axis(out:Vector3D = null):Vector3D {
			return CheckOut(out,0,0,1);
		}
		
		static private function CheckOut(out:Vector3D, x:Number, y:Number, z:Number):Vector3D {
			if (out) {
				out.setTo(x,y,z);
			} else {
				out = new Vector3D(x,y,z);
			}
			return out;
		}
		
		/**
		 * Interpolate
		 * @param	v0 Initial vector
		 * @param	v1 Target vector
		 * @param	f factor = [0...1]
		 * @return	Vector
		 */
		static public function Interpolate(v0:Vector3D, v1:Vector3D, f:Number):Vector3D {
			var v:Vector3D = v1.subtract(v0);
			v.scaleBy(f/v.length);
			return v.add(v0);
		}
	}
}