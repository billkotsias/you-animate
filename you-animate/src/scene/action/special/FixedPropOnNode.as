package scene.action.special
{
	import fanlib.event.Unlistener;
	import fanlib.utils.JobsToGo;
	
	import flare.basic.Scene3D;
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	
	import scene.Character;
	import scene.Scene;
	import scene.action.ActionInfo;
	import scene.action.Coordination;
	import scene.action.FixedAction;
	import scene.action.Node;
	
	public class FixedPropOnNode extends FixedAction implements IPropAction
	{
		private var _prop:PropOnNode;
		private var seizedChar:Boolean;
		private var propFrom:Number;
		private var propTo:Number;
		
		private var jobs:JobsToGo;
		protected const unlistener:Unlistener = new Unlistener();
		
		/**
		 * Redundant !? 
		 * @param character
		 * @param data
		 * @param node
		 */
		public function FixedPropOnNode(character:Character, data:ActionInfo, node:Node)
		{
			super(character, data, node);
			
			propFrom = propInfo.from;
			propTo = propInfo.to;
			_prop = Properties.INSTANCE.requestProp(this, PropOnNode, node, Scene.INSTANCE.iScene3D) as PropOnNode;
			
			// jobs till prop initialization
			jobs = new JobsToGo(jobsDone);
			jobs.newJob(_prop.whenInitialized(jobs.jobDone));
			jobs.newJob(); // wait for indexParentVector to be set
			jobs.allJobsSet();
			
			unlistener.addListener(character, Character.SCALE_CHANGED, charScaleChanged, false, 0, true);
		}
		
		override public function seizeCharacter():void {
			if (!seizedChar) super.seizeCharacter();
			seizedChar = _prop.attachToAnimatedParent();
		}
		
		override public function surrenderCharacter(endOfAction:Boolean = false):void {
			_prop.rest();
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
		}
		
		override public function _dispose():void {
			unlistener.removeAll();
			Properties.INSTANCE.forgetActionProp(this);
		}
		
		override public function set indexParentVector(value:int):void {
			_indexParentVector = value;
			if (jobs) jobs.jobDone();
		}
		private function jobsDone():void {
			jobs = null;
			setPropRestCoords();
		}
		
		private function setPropRestCoords():void {
			if (jobs) return; // not ready to set rest coords yet
			const restoreTime:Number = character.currentTime;
			character.setTime( getTimeOffset() ); // 'getTimeOffset()' won't work unless 'indexParentVector' is set
			_prop.setRestCoords();
			character.setTime( restoreTime );
			
			if (seizedChar) seizeCharacter(); // re-seize
		}
		
		override public function nodeChanged(node:Node):void {
			super.nodeChanged(node);
			setPropRestCoords();
		}
		private function charScaleChanged(e:Event):void {
			setPropRestCoords();
		}
		
		public function get prop():Prop { return _prop }
	}
}