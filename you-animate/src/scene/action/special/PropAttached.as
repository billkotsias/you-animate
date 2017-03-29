package scene.action.special
{
	import fanlib.utils.JobsToGo;
	
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix3D;
	
	import scene.Character;
	import scene.action.Action;
	
	public class PropAttached extends Prop
	{
		static private const IDENTITY:Matrix3D = new Matrix3D();
		
		private const attachingParents:Array = [];		// nodes on 'Character'
		internal const attachingChildren:Array = [];	// nodes on 'Prop' pivot
		
		private var defaultParent:Pivot3D;
		private var action:Action; // only needed for initialization!
		
		public function PropAttached(action:Action)
		{
			super();
			this.action = action;
		}
		
		override internal function loaded(loader:FlareLoader):void {
			super.loaded(loader); // clone Loader (cloned inside Pivot3D)
			action.character.whenInitialized(setParents);
			action = null; // no longer needed
		}
		private function setParents(char:Character):void {
			const charPivot:Pivot3D = char.charPivot;
			defaultParent = charPivot.scene;
			
			// get parents by name: all 1st-level children of loader (cloned inside Pivot3D)
			const children:Vector.<Pivot3D> = pivot3D.children[0].children;
			for (var i:int = children.length - 1; i >= 0; --i) {
				attachingChildren.push(children[i]);
				var parentName:String = children[i].name;
				attachingParents.push(charPivot.getChildByName(parentName));
			}
			
			// NOTE : 'pivot3D' is now redundant!
			
			_initialized = true;
			dispatchEvent(new Event(INITIALIZED));
		}
		
		/**
		 * @return <b>True</b> if attached succesfully
		 */
		public function attachToAnimatedParent():Boolean {
			if (attachingChildren.length) {
				for (var i:int = 0; i < attachingParents.length; ++i) {
					var animatedParent:Pivot3D = attachingParents[i];
					var child:Pivot3D = attachingChildren[i];
					child.transform.copyFrom(IDENTITY);
					animatedParent.addChild(child);
					child.show();
					animatedParent.gotoAndPlay(0);
					animatedParent.gotoAndStop(0);
				}
				return true;
			}
			return false;
		}
		
		public function detachFromParent():void {
			if (attachingChildren.length) {
				for (var i:int = 0; i < attachingParents.length; ++i) {
					var animatedParent:Pivot3D = attachingParents[i];
					var child:Pivot3D = attachingChildren[i];
					defaultParent.addChild(child);
					child.copyTransformFrom(animatedParent, false); // set local resting matrix from parent's global matrix
				}
			}
		}
		
		public function set visible(v:Boolean):void {
			for (var i:int = 0; i < attachingChildren.length; ++i) {
				var child:Pivot3D = attachingChildren[i];
				if (v) child.show(); else child.hide();
			}
		}
		
		override public function destroy():void {
			super.destroy();
			
			for (var i:int = 0; i < attachingChildren.length; ++i) {
				(attachingChildren[i] as Pivot3D).parent = null;
			}
			attachingParents.length = 0;
			attachingChildren.length = 0;
		}
	}
}