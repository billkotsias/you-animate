package scene.action.special
{
	import fanlib.containers.List;
	import fanlib.utils.Utils;
	
	import flare.basic.Scene3D;
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import scene.action.Action;
	import scene.action.Node;
	import scene.action.special.PropOnNode;
	
	import ui.report.ProgressWindow;
	
	public class PropResource {
		
		private var loader:FlareLoader;
		
		// props management
		private const propToActions:Dictionary = new Dictionary(true);
		private const refToProp:Dictionary = new Dictionary(true); // } re-use properties for same references (like Nodes)
		private const propToRef:Dictionary = new Dictionary(true); // }
		
		private const propsToClone:List = new List(); // hold to clone till loaded
		
		public function PropResource(request:*, sceneContext:Scene3D, propName:String) {
			loader = new FlareLoader(request, null, sceneContext);
			ProgressWindow.NewProgress(loader, "Loading object " + propName);
			loader.load();
		}
		
		public function getInstance(action:Action, _class:Class, ref:*):Prop {
			var constructorParams:Array;
			switch (_class) {
				case PropOnNode:
					constructorParams = [action, ref];
					break;
				case PropAttached:
					constructorParams = [action];
					break;
				case Prop:
				case PropVehicle:
					constructorParams = [];
					break;
			}
			
			const prop:Prop = Utils.GetGuaranteedByFunction(refToProp, ref, propConstructor, _class, constructorParams, ref);
			(Utils.GetGuaranteed(propToActions, prop, List) as List).push(action); // register Action with this Prop
			
			return prop;
		}
		private function propConstructor(_class:Class, constructorParams:Array, ref:*):Prop {
			const prop:Prop = Utils.DynamicConstructor(_class, constructorParams) as Prop;
			propToRef[prop] = ref;
			if (loader.complete) {
				prop.loaded(loader); // clone instance
			} else {
				propsToClone.push(prop);
				loader.addEventListener(Event.COMPLETE, loaderComplete);
			}
			return prop;
		}
		
		private function loaderComplete(e:Event):void {
			loader.removeEventListener(Event.COMPLETE, loaderComplete);
			loader.gotoAndPlay(0);
			loader.gotoAndStop(0); // FUCK FLARE
			
			propsToClone.forEach(function (prop:Prop):void {
				prop.loaded(loader);
			});
			propsToClone.clear(true);
		}
		
		public function forgetInstance(action:IPropAction):Boolean {
			const prop:Prop = action.prop;
			
			// delete Action ref
			const propActionsList:List = propToActions[prop];
			propActionsList.remove(action);
			if (propActionsList.isEmpty()) {
				delete propToActions[prop];
				delete refToProp[ propToRef[prop] ];
				delete propToRef[prop];
				prop.destroy();
			}
			
			return Utils.IsEmpty(propToActions); // true = Resource eligible for destruction
		}
		
		public function destroy():void {
			loader.removeEventListener(Event.COMPLETE, loaderComplete);
			loader.close();
			loader = null;
		}
	}
}