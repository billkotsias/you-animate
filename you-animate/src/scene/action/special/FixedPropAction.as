package scene.action.special
{
	import flare.core.Pivot3D;
	
	import scene.Character;
	import scene.Scene;
	import scene.action.ActionInfo;
	import scene.action.FixedAction;
	import scene.action.Node;
	
	public class FixedPropAction extends FixedAction implements IPropAction
	{
		private var _prop:PropAttached;
		private var seizedChar:Boolean;
		private var propFrom:Number;
		private var propTo:Number;
		private var propRate:Number;
		
		public function FixedPropAction(character:Character, data:ActionInfo, node:Node)
		{
			super(character, data, node);
			propFrom = propInfo.from;
			propTo = propInfo.to;
			propRate = propInfo.rate;
			if (!propRate) propRate = _rate;
			_prop = Properties.INSTANCE.requestProp(this, PropAttached, _character, Scene.INSTANCE.iScene3D) as PropAttached;
		}
		
		override public function seizeCharacter():void {
			if (!seizedChar) super.seizeCharacter();
			seizedChar = _prop.attachToAnimatedParent();
			_prop.visible = true;
		}
		
		override public function surrenderCharacter(endOfAction:Boolean = false):void {
			_prop.detachFromParent();
//			trace(this,"surrenderCharacter",propInfo.rest);
			if (!propInfo.rest) _prop.visible = false;
			seizedChar = false;
		}
		
		override public function setCoordination(time:Number):void {
			if (!seizedChar) seizeCharacter(); // retry
			super.setCoordination(time);
			
			var pivot:Pivot3D;
			if (propFrom === propFrom) {
				for each (pivot in _prop.attachingChildren) {
					const propFrame:Number = CalcLinearFrame(time, propFrom, propTo, _loop, _rate);
					pivot.gotoAndStop(propFrame, 0);
				}
			}
//			trace(this,coordination.frame);
		}
		
		override public function _dispose():void {
			super._dispose();
			Properties.INSTANCE.forgetActionProp(this);
		}
		
		public function get prop():Prop { return _prop }
	}
}