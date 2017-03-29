package scene.action.special
{
	import fanlib.containers.List;
	import fanlib.utils.Debug;
	import fanlib.utils.Utils;
	
	import flare.basic.Scene3D;
	import flare.core.Pivot3D;
	
	import flash.utils.Dictionary;
	
	import scene.Character;
	import scene.IScene3D;
	import scene.action.Action;
	import scene.action.Node;

	public class Properties
	{
		static public const INSTANCE:Properties = new Properties();
		
		private const fileToResource:Object = {};
		
		public function Properties()
		{ if (INSTANCE) throw this + " is singleton";
		}
		
		public function requestProp(action:Action, _class:Class, ref:*, sceneContext:IScene3D):Prop {
			const propInfo:PropInfo = action.propInfo;
			const file:String = propInfo.file;
			const path:String = propInfo.getFullFilePath();
//			Debug.appendLineMulti(",",this,file,path);
			const propRes:PropResource = Utils.GetGuaranteedByFunction(fileToResource, file,
																	   Utils.DynamicConstructor, PropResource, [path, sceneContext, propInfo.name]);
			return propRes.getInstance(action, _class, ref);
		}
		
		public function forgetActionProp(action:IPropAction):void {
			const file:String = action.propInfo.file;
			const propRes:PropResource = fileToResource[file];
			const destroyResource:Boolean = propRes.forgetInstance(action);
			if (destroyResource) {
				delete fileToResource[file];
				propRes.destroy();
			}
		}
	}
}