package fanlib.gfx.f3d
{
	import fanlib.utils.Pair;
	
	import flash.display.DisplayObject;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	public class F3DCont extends Sort3D
	{
		private const toSort:Array = [];
		
		public function F3DCont()
		{
			super();
		}
		
		// all children are assumed to be 'Sort3D' type
		public function sort3D():void {
			var children:Array = [];
			var perspective:PerspectiveProjection = root.transform.perspectiveProjection;
			var camera2DPos:Point = perspective.projectionCenter;
			var cameraPos:Vector3D = new Vector3D(camera2DPos.x, camera2DPos.y, -2*perspective.focalLength);
			
			for (var i:int = 0; i < numChildren; ++i) {
				var obj:Sort3D = getChildAt(i) as Sort3D;
				if (!obj) continue;
				var distance:Number = Vector3D.distance(
					cameraPos, obj.sortBy.transform.getRelativeMatrix3D(root).position);
				children.push(new Pair(obj, distance));
			}
			children.sortOn("value", Array.NUMERIC|Array.DESCENDING);
			
			for (i = 0; i < children.length; ++i) {
				obj = (children[i] as Pair).key;
				setChildIndex(obj, i);
			}
		}
	}
}