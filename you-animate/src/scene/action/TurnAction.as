package scene.action
{
	import fanlib.math.FVector3D;
	
	import flash.geom.Vector3D;
	
	import scene.Character;

	public class TurnAction extends FixedAction
	{
		protected var _finalDirection:Vector3D;
		
		public function TurnAction(character:Character, data:ActionInfo, node:Node)
		{
			super(character, data, node);
		}
		
		override public function getDirection(time:Number):Vector3D {
			return FVector3D.Interpolate(super.getDirection(0), _finalDirection, time/_duration);
		}
	}
}