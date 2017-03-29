package scene
{
	import flare.core.Camera3D;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	public interface IScene3D
	{
		CONFIG::oldFlare {
		function getPointScreenCoords(point:Vector3D, out:Vector3D = null):Vector3D;
		}
		CONFIG::newFlare { 
		function getPointScreenCoords(point:Vector3D, out:Vector3D = null, camera:Camera3D = null, viewport:Rectangle = null):Vector3D;
		}
		function getPointScreenCoordsRelative(point:Vector3D, parent2D:DisplayObject, out:Vector3D = null, camera:Camera3D = null, viewport:Rectangle = null):Point;
		function get camera():Camera3D;
		function set camera(cam:Camera3D):void;
		// Bill
		function getPointOnXYPlane(planeZ:Number, stageX:Number, stageY:Number):Vector3D;
	}
}