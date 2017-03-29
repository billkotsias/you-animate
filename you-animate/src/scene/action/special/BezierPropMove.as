package scene.action.special
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.utils.JobsToGo;
	
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	
	import scene.Character;
	import scene.Scene;
	import scene.action.ActionInfo;
	import scene.action.BNode;
	import scene.action.BezierMove;
	import scene.action.Node;
	
	public class BezierPropMove extends BezierMove implements IPropAction
	{
		private var _prop:PropAttached;
		private var seizedChar:Boolean;
		private var propFrom:Number;
		private var propTo:Number;
		private var propRate:Number;
		
		public function BezierPropMove(character:Character, data:ActionInfo, node0:BNode, node1:BNode, referencePivot:Pivot3D, parent2D:FSprite)
		{
			super(character, data, node0, node1, referencePivot, parent2D);
			
			propFrom = propInfo.from;
			propTo = propInfo.to;
			propRate = propInfo.rate;
			if (!propRate) propRate = _rate;
			_prop = Properties.INSTANCE.requestProp(this, PropAttached, _character, Scene.INSTANCE.iScene3D) as PropAttached;
		}
		
		override public function seizeCharacter():void {
			if (!seizedChar) super.seizeCharacter();
			seizedChar = _prop.attachToAnimatedParent();
		}
		
		override public function surrenderCharacter(endOfAction:Boolean = false):void {
			_prop.detachFromParent();
			seizedChar = false;
		}
		
		override public function setCoordination(time:Number):void {
			if (!seizedChar) seizeCharacter(); // retry
			super.setCoordination(time);
			
			var pivot:Pivot3D;
			if (propFrom === propFrom) {
				for each (pivot in _prop.attachingChildren) {
					const propFrame:Number = CalcLinearFrame(time, propFrom, propTo, _loop, propRate);
//					pivot.gotoAndPlay(propFrame, 0);
					pivot.gotoAndStop(propFrame, 0);
				}
			}
		}
		
		override public function _dispose():void {
			super._dispose();
			Properties.INSTANCE.forgetActionProp(this);
		}
		
		public function get prop():Prop { return _prop }
	}
}