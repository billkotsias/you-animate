package scene.action.special
{
	import fanlib.utils.JobsToGo;
	import fanlib.utils.Utils;
	
	import flare.core.Pivot3D;
	import flare.utils.Pivot3DUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import scene.CharManager;
	import scene.Character;
	import scene.action.AbstractNode;
	import scene.action.Action;
	import scene.action.Node;

	/**
	 * Semi-redundant and un-updated Class (use PropAttached instead) 
	 * @author BillWork
	 * 
	 */
	public class PropOnNode extends Prop
	{
		static private const IDENTITY:Matrix3D = new Matrix3D();
		
		private var parentNames:Array;
//		private var animatedParentNames:Array;
//		internal const animatedParents:Array = [];
		
		private const attachingParents:Array = [];
		internal const attachingChildren:Array = [];
		
		private var jobs:JobsToGo;
		
		internal var restingNode:AbstractNode;
//		private const origMatrices:Array = [];
		private const restMatrices:Array = [];

		public function PropOnNode(action:Action, node:Node) {
			super();
			
			// jobs -> set to non-null before ANYTHING else
			jobs = new JobsToGo(inited);
			jobs.newJob(/*setParents*/);
			jobs.newJob(/*loaded*/);
			jobs.allJobsSet();
			
			// set-up
			const propInfo:PropInfo = action.propInfo;
			
			// NOTE : REDUNDANT!!!
//			parentNames = propInfo.parentNames;
			
//			animatedParentNames = propInfo.animatedParentNames; // NOTE : optional! May be ommited in script file.
			action.character.whenInitialized(this.setParents);
			
			if (propInfo.rest) restingNode = node;
		}
		
		override internal function loaded(loader:FlareLoader):void {
			super.loaded(loader); // clone Loader
			jobs.jobDone();
		}
		
		private function setParents(char:Character):void {
			const charPivot:Pivot3D = char.charPivot;
			var parentName:String;
			
			// - attaching parents
			for each (parentName in parentNames) {
				attachingParents.push(charPivot.getChildByName(parentName));
			}
			
			// - animated parents
//			if (animatedParentNames) {
//				for each (parentName in animatedParentNames) {
//					animatedParents.push(charPivot.getChildByName(parentName));
//				}
//			} else {
//				for each (var pivot:Pivot3D in attachingParents) {
//					animatedParents.push(pivot.parent); // by default, the attachingParent's parent is the animated one!
//				}
//			}
			
			if (jobs) jobs.jobDone(); // put last in case we need to reset the parents (in the future)
		}
		
		private function inited():void {
			// now that both 'Character' and 'Prop' meshes are loaded, we can match "attachingParents" to "attachingChildren"
			for (var i:int = 0; i < attachingParents.length; ++i) {
				var animatedParent:Pivot3D = attachingParents[i];
				attachingChildren[i] = pivot3D.getChildByName(animatedParent.name); // attached objects have same name as attaching parents!
//				origMatrices[i] = attachingChildren[i].transform.clone();
				restMatrices[i] = new Matrix3D(); // to be modified
			}
			
			jobs = null;
			_initialized = true;
			dispatchEvent(new Event(INITIALIZED));
		}
		
		/**
		 * Character must be set to parent Action's start! 
		 */
		public function setRestCoords():void {
			const isResting:Boolean = Boolean(pivot3D.children.length);
			
			// get default rest coordination
			if (restingNode) {
				restingNode.mesh3D.addChild(pivot3D); // pretend we are in "rest mode"
				for (var i:int = 0; i < attachingParents.length; ++i) {
					var animatedParent:Pivot3D = attachingParents[i];
					var child:Pivot3D = attachingChildren[i];
					pivot3D.addChild(child);
					child.copyTransformFrom(animatedParent, false); // set local resting matrix from parent's global matrix
					const restMatrix:Matrix3D = restMatrices[i];
					restMatrix.copyFrom(child.transform); // save local matrix
				}
			}
			
			if (isResting) rest(); else attachToAnimatedParent();
		}
		
		public function rest():void {
			for (var i:int = 0; i < attachingChildren.length; ++i) {
				var child:Pivot3D = attachingChildren[i];
				pivot3D.addChild(child);
				child.transform.copyFrom(restMatrices[i]);
				child.dirty = true;
			}
			if (restingNode) {
				restingNode.mesh3D.addChild(pivot3D);
//				_pivot3D.gotoAndStop(0); // NOTE : needed???
			} else {
				pivot3D.hide();
			}
		}
		
		/**
		 * @return <b>True</b> if attached succesfully
		 */
		public function attachToAnimatedParent():Boolean {
			if (_initialized) {
				for (var i:int = 0; i < attachingParents.length; ++i) {
					var animatedParent:Pivot3D = attachingParents[i];
					var child:Pivot3D = attachingChildren[i];
//					trace(this,child.name);
//					child.animationEnabled = false;
//					child.forEach(function(p:Pivot3D):void { trace(p,p.name); p.animationEnabled = false; }, null, null, true);
//					child.transform.copyFrom(origMatrices[i]);
					child.transform.copyFrom(IDENTITY);
					animatedParent.addChild(child);
					child.show();
				}
			}
			return _initialized;
		}
		
		override public function destroy():void {
			super.destroy();
			
			for (var i:int = 0; i < attachingChildren.length; ++i) {
				(attachingChildren[i] as Pivot3D).parent = null;
			}
			attachingParents.length = 0;
			attachingChildren.length = 0;
			restMatrices.length = 0;
			parentNames = null;
		}
	}
}