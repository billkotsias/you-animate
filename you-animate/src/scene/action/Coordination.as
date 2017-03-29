package scene.action
{
	import flash.geom.Vector3D;

	/**
	 * Redundant...?! 
	 * @author BillWork
	 */
	public class Coordination
	{
		public var position:Vector3D;
		public var direction:Vector3D;
		public var frame:Number;
		
		public function Coordination()
		{
		}
		
		public function toString():String {
			return "[Coordination] " + position.toString() + "/" + direction.toString() + "/" + frame;
		}
	}
}