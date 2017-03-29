package test   
{
	import flare.basic.Scene3D;
	import flare.basic.Viewer3D;
	import flare.core.Camera3D;
	import flare.materials.NullMaterial;
	import flare.primitives.Cube;
	import flare.primitives.Plane;
	import flare.system.Input3D;
	import flare.utils.Vector3DUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;

	/**
	 * @author Ariel Nehmad
	 */
	public class RayPlaneExample extends Sprite
	{
		private var _scene:Scene3D;
		private var cube:Cube;
		
		public function RayPlaneExample() 
		{
			_scene = new Viewer3D( this );
			_scene.camera = new Camera3D();
			_scene.camera.setPosition( 0, 100, -100 );
			_scene.camera.lookAt( 0, 0, 0 );
			
			// just to have a reference.
			_scene.addChild( new Plane( "", 100, 100, 1, new NullMaterial(), "+xz" ) );
			
			cube = new Cube( "cube", 5, 5, 5 );
			cube.parent = _scene;
			
			_scene.addEventListener( Scene3D.UPDATE_EVENT, updateEvent );
		}
		
		private function updateEvent(e:Event):void 
		{
			var from:Vector3D = _scene.camera.getPosition(false);
			var dir:Vector3D = _scene.camera.getPointDir( Input3D.mouseX, Input3D.mouseY );
			var pos:Vector3D = rayPlane( new Vector3D(0,1,0), new Vector3D(0,0,0), from, dir );
			cube.x = pos.x;
			cube.y = pos.y;
			cube.z = pos.z;
		}
		
		static public function rayPlane( pNormal:Vector3D, pCenter:Vector3D, rFrom:Vector3D, rDir:Vector3D ):Vector3D
		{
			var dist:Number = ( pNormal.dotProduct(pCenter) - pNormal.dotProduct(rFrom) ) / pNormal.dotProduct(rDir);
			var out:Vector3D = new Vector3D();
			out.x = rFrom.x + rDir.x * dist;
			out.y = rFrom.y + rDir.y * dist;
			out.z = rFrom.z + rDir.z * dist;
			return out;
		}
	}
}