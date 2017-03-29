package upload
{
	import fanlib.utils.Utils;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import ui.LabelThumb;
	import ui.LabeledUI;

	public class UItoObject
	{
		static public function GetAllIUI(destination:Object, parent:DisplayObjectContainer, childrenDepth:uint = 0):void {
			for (var i:int = 0; i < parent.numChildren; ++i) {
				var dobj:DisplayObject = parent.getChildAt(i);
				
				var uiElem:IUItoObject = dobj as IUItoObject;
				if (uiElem) destination[uiElem.name] = uiElem;
				
				if (childrenDepth && dobj is DisplayObjectContainer) GetAllIUI(destination, dobj as DisplayObjectContainer, childrenDepth-1);
			}
		}
		
		static public function ExtractData(parent:DisplayObjectContainer):Object {
			const obj:Object = {};
			
			for (var i:int = 0; i < parent.numChildren; ++i) {
				var uiElem:IUItoObject = parent.getChildAt(i) as IUItoObject;
				if (!uiElem) continue;
				
				obj[ uiElem.name ] = uiElem.result;
			}
			
			return obj;
		}
		
		static public function CopyPropertiesFromUI(destination:Object, cont:DisplayObjectContainer):void {
			const data:Object = UItoObject.ExtractData(cont);
			for (var n:String in data) {
				destination[n] = data[n];
			}
		}
		
		static public function CopyPropertiesToUI(source:Object, cont:DisplayObjectContainer):void {
			for each (var n:String in Utils.GetWritableVars(source)) {
				CopyPropertyToUI(cont, n, source[n]);
			}
		}
		static public function CopyPropertyToUI(cont:DisplayObjectContainer, propName:String, value:String):void {
			var uiElem:IUItoObject = cont.getChildByName(propName) as IUItoObject;
			if (uiElem) uiElem.result = value;
		}
	}
}