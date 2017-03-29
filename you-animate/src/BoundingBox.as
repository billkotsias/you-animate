package
{
	import flare.core.Boundings3D;
	import flare.core.Lines3D;
	
	import flash.geom.Vector3D;
	
	public class BoundingBox extends Lines3D
	{
		private var min:Vector3D;
		private var max:Vector3D;
		
		public function BoundingBox(meshBounds:Boundings3D, name:String="lines")
		{
			super(name);
			castShadows = false; // crash-kaboom if true!
			receiveShadows = false; // crash-kaboom if true!
			updateDrawing(meshBounds);
		}
		
		public function updateDrawing(meshBounds:Boundings3D):void {
			min = meshBounds.min;
			max = meshBounds.max;
			drawXY(min.z);
			drawXY(max.z);
			drawZ(min.x, min.y);
			drawZ(min.x, max.y);
			drawZ(max.x, min.y);
			drawZ(max.x, max.y);
		}
		private function drawXY(zz:Number):void {
			moveTo(min.x, min.y, zz);
			lineTo(max.x, min.y, zz);
			lineTo(max.x, max.y, zz);
			lineTo(min.x, max.y, zz);
			lineTo(min.x, min.y, zz);
		}
		private function drawZ(x:Number, y:Number):void {
			moveTo(x,y,min.z);
			lineTo(x,y,max.z);
		}
	}
}