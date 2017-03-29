package
{
	import fanlib.math.FVector3D;
	import fanlib.math.Maths;
	
	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Pivot3D;
	import flare.system.Input3D;
	import flare.utils.Vector3DUtils;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import scene.IScene3D;
	
	public class Viewer extends AutoResizeScene3D implements IScene3D
	{
		static private const VectorZ:Vector3D = FVector3D.Z_Axis();
		static private const PlaneXY:Vector3D = new Vector3D();
		
		// ray-plane vector
		private const rFrom:Vector3D = new Vector3D();
		private const rDir:Vector3D = new Vector3D();
		private const rOut:Vector3D = new Vector3D();
		
		public function Viewer(container:DisplayObjectContainer, file:String="")
		{
			super(container, file);
//			addEventListener( Scene3D.UPDATE_EVENT, updateEvent, false, 0, true );
			Input3D.rightClickEnabled = true;
		}
		
		public function getPointScreenCoordsRelative(point:Vector3D, parent2D:DisplayObject, out:Vector3D = null, camera:Camera3D = null, viewport:Rectangle = null):Point {
			CONFIG::newFlare { getPointScreenCoords(point, out, camera, viewport); }
			CONFIG::oldFlare { getPointScreenCoords(point, out); }
			const pnt2D:Point = new Point(out.x, out.y);
			return parent2D.globalToLocal(pnt2D); // _point2D.offset.parent === _point2D
		}
		
		public function getPointOnXYPlane(planeZ:Number, stageX:Number, stageY:Number):Vector3D {
			PlaneXY.z = planeZ;
			camera.getPointDir(stageX, stageY, rDir, rFrom);
			FVector3D.RayPlane(VectorZ, PlaneXY, rFrom, rDir, rOut);
			return rOut;
		}
		
		/**
		 * Redundant ! 
		 * @param e
		 */		
		private function updateEvent(e:Event):void 
		{
			if (Input3D.rightMouseDown) {
				if (Input3D.keyDown(Input3D.SHIFT)) {
					camera.translateY(-Input3D.mouseYSpeed/15, false);
					camera.setPosition(camera.x, Maths.bound2(camera.y, 1, 100), camera.z);
					//trace(this,"y",camera.y);
				} else {
					//camera.rotateY( Input3D.mouseXSpeed, false, null );
					var boundRotY:Number = Maths.bound2(camera.getRotation().x + Input3D.mouseYSpeed, -10, 90);
					camera.setRotation(boundRotY, 0, 0);
					//trace(this,"rot",camera.getRotation());
				}
			}
			
			if (Input3D.delta != 0) {
				camera.zoom = Maths.bound2(camera.zoom - Input3D.delta/50, 0.05, 5); // was: 0.4, 2.3
				camera.dispatchEvent(new Event(Pivot3D.UPDATE_TRANSFORM_EVENT)); // ! shit
				//trace(this,"zoom",camera.zoom);
			}
		}
	}
}